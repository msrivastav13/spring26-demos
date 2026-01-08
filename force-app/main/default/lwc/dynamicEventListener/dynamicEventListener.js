import { LightningElement, track } from 'lwc';

/**
 * Simple Hello World demo for lwc:on directive
 * Shows how to dynamically attach event listeners
 */
export default class DynamicEventListener extends LightningElement {
    @track message = 'Interact with the box!';
    @track eventMode = 'click'; // 'click' or 'hover'

    /**
     * 🔥 THE KEY FEATURE: Returns an object of event handlers
     * The lwc:on directive uses this to attach listeners dynamically
     */
    get boxEventHandlers() {
        const handlers = {};

        if (this.eventMode === 'click') {
            handlers.click = () => {
                this.message = '🖱️ You clicked!';
            };
        }

        if (this.eventMode === 'hover') {
            handlers.mouseenter = () => {
                this.message = '✨ Mouse entered!';
            };
            handlers.mouseleave = () => {
                this.message = '👋 Mouse left!';
            };
        }

        return handlers;
    }

    setClickMode() {
        this.eventMode = 'click';
        this.message = 'Now using CLICK mode';
    }

    setHoverMode() {
        this.eventMode = 'hover';
        this.message = 'Now using HOVER mode';
    }

    get clickVariant() {
        return this.eventMode === 'click' ? 'brand' : 'neutral';
    }

    get hoverVariant() {
        return this.eventMode === 'hover' ? 'brand' : 'neutral';
    }
}

