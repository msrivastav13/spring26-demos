import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EmptyStateDemo extends LightningElement {
    @track currentView = 'emptyCart';

    // Getters for view visibility
    get isEmptyCart() {
        return this.currentView === 'emptyCart';
    }

    get isNoTasks() {
        return this.currentView === 'noTasks';
    }

    get isNoResults() {
        return this.currentView === 'noResults';
    }

    get isIllustrationOnly() {
        return this.currentView === 'illustrationOnly';
    }

    // Getters for button variants (to highlight active button)
    get emptyCartVariant() {
        return this.currentView === 'emptyCart' ? 'brand' : 'neutral';
    }

    get noTasksVariant() {
        return this.currentView === 'noTasks' ? 'brand' : 'neutral';
    }

    get noResultsVariant() {
        return this.currentView === 'noResults' ? 'brand' : 'neutral';
    }

    get illustrationOnlyVariant() {
        return this.currentView === 'illustrationOnly' ? 'brand' : 'neutral';
    }

    // View toggle handlers
    showEmptyCart() {
        this.currentView = 'emptyCart';
    }

    showNoTasks() {
        this.currentView = 'noTasks';
    }

    showNoResults() {
        this.currentView = 'noResults';
    }

    showIllustrationOnly() {
        this.currentView = 'illustrationOnly';
    }

    // CTA button handlers
    handleBrowseProducts() {
        this.showToast(
            'Browse Products',
            'Navigating to product catalog...',
            'info'
        );
    }

    handleCreateTask() {
        this.showToast(
            'Create Task',
            'Opening task creation form...',
            'info'
        );
    }

    handleClearFilters() {
        this.showToast(
            'Filters Cleared',
            'All search filters have been reset.',
            'success'
        );
    }

    handleNewSearch() {
        this.showToast(
            'New Search',
            'Ready for a new search query.',
            'info'
        );
    }

    // Helper method to show toast notifications
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
