import { LightningElement, track } from 'lwc';

/**
 * 🎛️ Dynamic Event Container
 * 
 * This parent component demonstrates how you can pass event configuration
 * to child components via @api properties, showcasing the dynamic nature
 * of the lwc:on directive when event types are computed from parent props.
 * 
 * Use Case: Building configurable UI libraries where event behavior
 * is determined by the consuming component.
 */
export default class DynamicEventContainer extends LightningElement {
    
    @track selectedMode = 'click';
    @track customEventConfig = {};
    @track showAdvancedConfig = false;
    
    // Predefined interaction presets
    presets = [
        {
            id: 'desktop',
            name: '🖥️ Desktop Mode',
            description: 'Optimized for mouse interactions',
            mode: 'click',
            events: ['mousedown', 'mouseup', 'mouseleave']
        },
        {
            id: 'mobile',
            name: '📱 Mobile Mode',
            description: 'Touch-first interactions',
            mode: 'touch',
            events: ['touchstart', 'touchend', 'touchcancel']
        },
        {
            id: 'hover',
            name: '✨ Hover Mode',
            description: 'Trigger on mouse hover',
            mode: 'hover',
            events: ['mouseenter', 'mouseleave']
        },
        {
            id: 'accessibility',
            name: '♿ Accessible Mode',
            description: 'Full keyboard & focus support',
            mode: 'all',
            events: ['focus', 'blur', 'keydown', 'click']
        },
        {
            id: 'gaming',
            name: '🎮 Gaming Mode',
            description: 'All input methods active',
            mode: 'all',
            events: ['mousedown', 'mouseup', 'touchstart', 'touchend', 'keydown']
        }
    ];

    get currentPreset() {
        return this.presets.find(p => p.mode === this.selectedMode) || this.presets[0];
    }

    handlePresetChange(event) {
        const presetId = event.currentTarget.dataset.preset;
        const preset = this.presets.find(p => p.id === presetId);
        if (preset) {
            this.selectedMode = preset.mode;
        }
    }

    toggleAdvancedConfig() {
        this.showAdvancedConfig = !this.showAdvancedConfig;
    }

    get presetCards() {
        return this.presets.map(preset => ({
            ...preset,
            isSelected: preset.mode === this.selectedMode,
            cardClass: `preset-card ${preset.mode === this.selectedMode ? 'selected' : ''}`
        }));
    }
}

