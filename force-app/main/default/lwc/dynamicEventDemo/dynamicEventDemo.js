import { LightningElement, api, track } from 'lwc';

/**
 * 🎵 Dynamic Beat Pad Machine
 * Demonstrates the lwc:on={eventHandlers} directive for dynamic event binding
 * 
 * This component showcases:
 * - Dynamic event listener attachment using lwc:on
 * - Computed event types passed via @api
 * - Interactive visual feedback with Web Audio API
 * - Configurable trigger modes (click, hover, touch, keyboard)
 */
export default class DynamicEventDemo extends LightningElement {
    
    // Allow parent components to configure which events trigger the pads
    @api triggerMode = 'click'; // 'click', 'hover', 'touch', 'all'
    
    @track pads = [];
    @track activeNotes = new Set();
    @track currentMode = 'click';
    @track visualizerBars = [];
    @track isPlaying = false;
    @track bpm = 120;
    @track sequencerStep = 0;
    @track isSequencerRunning = false;
    
    audioContext;
    sequencerInterval;
    
    // Pad configuration with musical notes, colors, and frequencies
    padConfig = [
        { id: 1, note: 'C4', frequency: 261.63, color: '#FF6B6B', label: 'KICK', emoji: '🥁' },
        { id: 2, note: 'D4', frequency: 293.66, color: '#4ECDC4', label: 'SNARE', emoji: '🪘' },
        { id: 3, note: 'E4', frequency: 329.63, color: '#45B7D1', label: 'HI-HAT', emoji: '🎩' },
        { id: 4, note: 'F4', frequency: 349.23, color: '#96CEB4', label: 'CLAP', emoji: '👏' },
        { id: 5, note: 'G4', frequency: 392.00, color: '#FFEAA7', label: 'TOM', emoji: '🎯' },
        { id: 6, note: 'A4', frequency: 440.00, color: '#DDA0DD', label: 'CYMBAL', emoji: '🔔' },
        { id: 7, note: 'B4', frequency: 493.88, color: '#98D8C8', label: 'BASS', emoji: '🎸' },
        { id: 8, note: 'C5', frequency: 523.25, color: '#F7DC6F', label: 'SYNTH', emoji: '🎹' },
        { id: 9, note: 'D5', frequency: 587.33, color: '#BB8FCE', label: 'PERC', emoji: '🎤' },
    ];

    // Keyboard mappings for each pad
    keyMap = ['q', 'w', 'e', 'a', 's', 'd', 'z', 'x', 'c'];

    connectedCallback() {
        this.initializePads();
        this.initializeVisualizer();
        this.initializeAudio();
        // Add keyboard listener at document level
        this.boundKeyHandler = this.handleKeyPress.bind(this);
        document.addEventListener('keydown', this.boundKeyHandler);
        document.addEventListener('keyup', this.handleKeyUp.bind(this));
    }

    disconnectedCallback() {
        document.removeEventListener('keydown', this.boundKeyHandler);
        document.removeEventListener('keyup', this.handleKeyUp.bind(this));
        if (this.sequencerInterval) {
            clearInterval(this.sequencerInterval);
        }
        if (this.audioContext) {
            this.audioContext.close();
        }
    }

    initializePads() {
        this.pads = this.padConfig.map((pad, index) => ({
            ...pad,
            key: this.keyMap[index],
            isActive: false,
            sequencerSteps: Array(8).fill(false),
            // 🔥 THIS IS THE KEY FEATURE: Dynamic event handlers object
            // The lwc:on directive will use this to attach event listeners
            eventHandlers: this.computeEventHandlers(pad.id)
        }));
    }

    initializeVisualizer() {
        this.visualizerBars = Array(16).fill(0).map((_, i) => ({
            id: i,
            height: 10,
            style: `height: 10px; background: linear-gradient(to top, #667eea, #764ba2);`
        }));
    }

    initializeAudio() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
        } catch (e) {
            console.log('Web Audio API not supported');
        }
    }

    /**
     * 🎯 CORE FEATURE: Compute dynamic event handlers based on configuration
     * This method returns an object where keys are event names and values are handler functions
     * The lwc:on directive will automatically attach these listeners
     */
    computeEventHandlers(padId) {
        const handlers = {};
        
        // Always include these for visual feedback
        handlers.mousedown = (event) => this.handlePadTrigger(event, padId);
        handlers.mouseup = (event) => this.handlePadRelease(event, padId);
        handlers.mouseleave = (event) => this.handlePadRelease(event, padId);
        
        // Dynamically add handlers based on trigger mode
        if (this.currentMode === 'hover' || this.currentMode === 'all') {
            handlers.mouseenter = (event) => this.handlePadTrigger(event, padId);
        }
        
        if (this.currentMode === 'touch' || this.currentMode === 'all') {
            handlers.touchstart = (event) => {
                event.preventDefault();
                this.handlePadTrigger(event, padId);
            };
            handlers.touchend = (event) => this.handlePadRelease(event, padId);
        }

        // Add focus events for accessibility
        handlers.focus = (event) => this.handlePadFocus(event, padId);
        handlers.blur = (event) => this.handlePadBlur(event, padId);
        
        return handlers;
    }

    /**
     * Recalculate all pad event handlers when mode changes
     */
    updateEventHandlers() {
        this.pads = this.pads.map(pad => ({
            ...pad,
            eventHandlers: this.computeEventHandlers(pad.id)
        }));
    }

    // Mode change handlers
    handleModeChange(event) {
        this.currentMode = event.target.value;
        this.updateEventHandlers();
    }

    setModeClick() {
        this.currentMode = 'click';
        this.updateEventHandlers();
    }

    setModeHover() {
        this.currentMode = 'hover';
        this.updateEventHandlers();
    }

    setModeTouch() {
        this.currentMode = 'touch';
        this.updateEventHandlers();
    }

    setModeAll() {
        this.currentMode = 'all';
        this.updateEventHandlers();
    }

    // Pad interaction handlers
    handlePadTrigger(event, padId) {
        event.stopPropagation();
        const pad = this.pads.find(p => p.id === padId);
        if (pad && !pad.isActive) {
            this.activatePad(padId);
            this.playSound(pad.frequency, pad.id);
            this.animateVisualizer();
        }
    }

    handlePadRelease(event, padId) {
        if (this.currentMode !== 'hover') {
            this.deactivatePad(padId);
        }
    }

    handlePadFocus(event, padId) {
        // Visual indicator for keyboard navigation
        const pad = this.pads.find(p => p.id === padId);
        if (pad) {
            this.pads = this.pads.map(p => ({
                ...p,
                hasFocus: p.id === padId
            }));
        }
    }

    handlePadBlur(event, padId) {
        this.pads = this.pads.map(p => ({
            ...p,
            hasFocus: false
        }));
    }

    // Keyboard handling
    handleKeyPress(event) {
        const keyIndex = this.keyMap.indexOf(event.key.toLowerCase());
        if (keyIndex !== -1) {
            event.preventDefault();
            const pad = this.pads[keyIndex];
            if (pad && !pad.isActive) {
                this.activatePad(pad.id);
                this.playSound(pad.frequency, pad.id);
                this.animateVisualizer();
            }
        }
        // Space bar toggles sequencer
        if (event.key === ' ') {
            event.preventDefault();
            this.toggleSequencer();
        }
    }

    handleKeyUp(event) {
        const keyIndex = this.keyMap.indexOf(event.key.toLowerCase());
        if (keyIndex !== -1) {
            const pad = this.pads[keyIndex];
            if (pad) {
                this.deactivatePad(pad.id);
            }
        }
    }

    activatePad(padId) {
        this.pads = this.pads.map(p => ({
            ...p,
            isActive: p.id === padId ? true : p.isActive
        }));
        this.activeNotes.add(padId);
    }

    deactivatePad(padId) {
        this.pads = this.pads.map(p => ({
            ...p,
            isActive: p.id === padId ? false : p.isActive
        }));
        this.activeNotes.delete(padId);
    }

    playSound(frequency, padId) {
        if (!this.audioContext) return;
        
        // Resume audio context if suspended (required by browsers)
        if (this.audioContext.state === 'suspended') {
            this.audioContext.resume();
        }

        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();
        
        // Different wave types for variety
        const waveTypes = ['sine', 'square', 'sawtooth', 'triangle'];
        oscillator.type = waveTypes[(padId - 1) % 4];
        oscillator.frequency.setValueAtTime(frequency, this.audioContext.currentTime);
        
        gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + 0.5);
        
        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);
        
        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + 0.5);
        
        this.isPlaying = true;
        setTimeout(() => { this.isPlaying = false; }, 100);
    }

    animateVisualizer() {
        this.visualizerBars = this.visualizerBars.map(bar => ({
            ...bar,
            height: Math.random() * 80 + 20,
            style: `height: ${Math.random() * 80 + 20}px; background: linear-gradient(to top, #667eea, #764ba2); transition: height 0.1s ease;`
        }));
        
        setTimeout(() => {
            this.visualizerBars = this.visualizerBars.map(bar => ({
                ...bar,
                height: 10,
                style: `height: 10px; background: linear-gradient(to top, #667eea, #764ba2); transition: height 0.3s ease;`
            }));
        }, 150);
    }

    // Sequencer functionality
    toggleSequencer() {
        this.isSequencerRunning = !this.isSequencerRunning;
        if (this.isSequencerRunning) {
            this.startSequencer();
        } else {
            this.stopSequencer();
        }
    }

    startSequencer() {
        const stepDuration = (60 / this.bpm) * 1000 / 2; // 8th notes
        this.sequencerInterval = setInterval(() => {
            this.sequencerStep = (this.sequencerStep + 1) % 8;
            this.playSequencerStep();
        }, stepDuration);
    }

    stopSequencer() {
        if (this.sequencerInterval) {
            clearInterval(this.sequencerInterval);
            this.sequencerInterval = null;
        }
        this.sequencerStep = 0;
    }

    playSequencerStep() {
        this.pads.forEach(pad => {
            if (pad.sequencerSteps[this.sequencerStep]) {
                this.activatePad(pad.id);
                this.playSound(pad.frequency, pad.id);
                setTimeout(() => this.deactivatePad(pad.id), 100);
            }
        });
        this.animateVisualizer();
    }

    toggleSequencerStep(event) {
        const padId = parseInt(event.currentTarget.dataset.padId, 10);
        const step = parseInt(event.currentTarget.dataset.step, 10);
        
        this.pads = this.pads.map(pad => {
            if (pad.id === padId) {
                const newSteps = [...pad.sequencerSteps];
                newSteps[step] = !newSteps[step];
                return { ...pad, sequencerSteps: newSteps };
            }
            return pad;
        });
    }

    handleBpmChange(event) {
        this.bpm = parseInt(event.target.value, 10);
        if (this.isSequencerRunning) {
            this.stopSequencer();
            this.startSequencer();
        }
    }

    // Computed getters for template
    get modeOptions() {
        return [
            { label: '🖱️ Click', value: 'click', selected: this.currentMode === 'click' },
            { label: '✨ Hover', value: 'hover', selected: this.currentMode === 'hover' },
            { label: '👆 Touch', value: 'touch', selected: this.currentMode === 'touch' },
            { label: '🎯 All Events', value: 'all', selected: this.currentMode === 'all' }
        ];
    }

    get sequencerButtonLabel() {
        return this.isSequencerRunning ? '⏹️ Stop' : '▶️ Play';
    }

    get sequencerSteps() {
        return Array(8).fill(0).map((_, i) => ({
            id: i,
            isActive: i === this.sequencerStep && this.isSequencerRunning
        }));
    }

    get sequencerRows() {
        return this.pads.map(pad => ({
            padId: pad.id,
            emoji: pad.emoji,
            steps: pad.sequencerSteps.map((isActive, index) => ({
                index,
                isActive,
                isCurrent: index === this.sequencerStep && this.isSequencerRunning
            }))
        }));
    }

    get modeClickClass() {
        return `mode-btn ${this.currentMode === 'click' ? 'active' : ''}`;
    }

    get modeHoverClass() {
        return `mode-btn ${this.currentMode === 'hover' ? 'active' : ''}`;
    }

    get modeTouchClass() {
        return `mode-btn ${this.currentMode === 'touch' ? 'active' : ''}`;
    }

    get modeAllClass() {
        return `mode-btn ${this.currentMode === 'all' ? 'active' : ''}`;
    }

    // Button variant getters for SLDS lightning-button
    get clickButtonVariant() {
        return this.currentMode === 'click' ? 'brand' : 'neutral';
    }

    get hoverButtonVariant() {
        return this.currentMode === 'hover' ? 'brand' : 'neutral';
    }

    get touchButtonVariant() {
        return this.currentMode === 'touch' ? 'brand' : 'neutral';
    }

    get allButtonVariant() {
        return this.currentMode === 'all' ? 'brand' : 'neutral';
    }

    get codeExample() {
        return `<!-- The lwc:on directive accepts an object of event handlers -->
<div lwc:on={pad.eventHandlers}></div>

// In JavaScript, compute handlers dynamically:
computeEventHandlers(padId) {
    const handlers = {}; 
    
    // Add handlers based on mode
    handlers.mousedown = (e) => this.handleTrigger(e);
    
    if (this.mode === 'hover') {
        handlers.mouseenter = (e) => this.handleTrigger(e);
    }
    
    if (this.mode === 'touch') {
        handlers.touchstart = (e) => this.handleTrigger(e);
    }
    
    return handlers;
}`;
    }

    // Boolean getters for template conditionals
    get isModeHover() {
        return this.currentMode === 'hover';
    }

    get isModeTouch() {
        return this.currentMode === 'touch';
    }

    get isModeAll() {
        return this.currentMode === 'all';
    }

    // Helper to get pad classes
    getPadClass(pad) {
        let classes = 'beat-pad';
        if (pad.isActive) classes += ' active';
        if (pad.hasFocus) classes += ' focused';
        return classes;
    }

    // Helper to get pad style
    getPadStyle(pad) {
        return `--pad-color: ${pad.color}; --pad-glow: ${pad.color}40;`;
    }
}

