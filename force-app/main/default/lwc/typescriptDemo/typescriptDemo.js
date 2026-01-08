import { LightningElement } from 'lwc';
// @ts-ignore
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TypescriptDemo extends LightningElement {
    // Reactive properties - class fields are reactive by default in modern LWC
    inputValue = '';
    selectedLanguage = 'typescript';
    clickCount = 0;
    // Computed property for button variant
    get buttonVariant() {
        return this.clickCount > 5 ? 'success' : 'brand';
    }
    // Typed options array for combobox
    get languageOptions() {
        return [
            { label: 'TypeScript', value: 'typescript' },
            { label: 'JavaScript', value: 'javascript' },
            { label: 'Apex', value: 'apex' },
            { label: 'HTML', value: 'html' }
        ];
    }
    // Row actions for datatable
    get rowActions() {
        return [
            { label: 'View Details', name: 'view_details' },
            { label: 'Copy Import', name: 'copy_import' }
        ];
    }
    // Typed table columns for datatable
    get tableColumns() {
        return [
            { label: 'Component', fieldName: 'component', type: 'text' },
            { label: 'Type Import', fieldName: 'typeImport', type: 'text' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: this.rowActions,
                    menuAlignment: 'right'
                }
            }
        ];
    }
    // Typed table data for datatable
    get tableData() {
        return [
            {
                id: '1',
                component: 'lightning-input',
                typeImport: 'LightningInput',
                status: 'Available'
            },
            {
                id: '2',
                component: 'lightning-button',
                typeImport: 'LightningButton',
                status: 'Available'
            },
            {
                id: '3',
                component: 'lightning-combobox',
                typeImport: 'LightningCombobox',
                status: 'Available'
            },
            {
                id: '4',
                component: 'lightning-datatable',
                typeImport: 'LightningDatatable',
                status: 'Available'
            }
        ];
    }
    /**
     * Handle input change event with typed event target
     * The LightningInput type provides full IntelliSense for properties like:
     * - value, validity, checkValidity(), reportValidity(), etc.
     */
    handleInputChange(event) {
        const input = event.target;
        this.inputValue = input.value ?? '';
    }
    /**
     * Handle combobox change event with typed event target
     * The LightningCombobox type provides IntelliSense for:
     * - value, options, disabled, required, etc.
     */
    handleLanguageChange(event) {
        const combobox = event.target;
        this.selectedLanguage = combobox.value;
        this.showToast('Language Selected', `You selected: ${this.selectedLanguage}`, 'success');
    }
    /**
     * Handle button click event
     * Demonstrates querying a typed component from the template
     */
    handleButtonClick() {
        this.clickCount++;
        // Example: Query a typed component from template
        const button = this.template?.querySelector('lightning-button');
        if (button) {
            // IntelliSense works here - try typing "button." to see available properties
            console.log('Button label:', button.label);
            console.log('Button variant:', button.variant);
        }
        if (this.clickCount === 5) {
            this.showToast('Achievement Unlocked!', 'You clicked 5 times! Button variant changed to success.', 'success');
        }
    }
    /**
     * Handle row action from datatable
     * The event.detail contains both action and row information
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view_details':
                this.showToast('Component Details', `${row.component} - Import as: ${row.typeImport}`, 'info');
                break;
            case 'copy_import':
                this.showToast('Import Statement', `import ${row.typeImport} from '${row.component.replace('lightning-', 'lightning/')}';`, 'success');
                break;
            default:
                this.showToast('Action', `Unknown action: ${actionName}`, 'warning');
        }
    }
    /**
     * Helper method to show toast notifications
     * Demonstrates TypeScript's type safety with ShowToastEvent
     */
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
