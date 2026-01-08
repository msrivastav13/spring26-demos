import { LightningElement } from 'lwc';
// @ts-ignore
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Spring '26: Import type definitions from @salesforce/lightning-types npm package
// These provide full TypeScript support for all Lightning base components
import LightningInput from 'lightning/input';
import LightningButton from 'lightning/button';
import LightningCombobox from 'lightning/combobox';

// Define interfaces for our component data
interface LanguageOption {
    label: string;
    value: string;
}

interface TableRow {
    id: string;
    component: string;
    typeImport: string;
    status: string;
}

interface RowAction {
    label: string;
    name: string;
}

interface TableColumn {
    label?: string;
    fieldName?: string;
    type: string;
    typeAttributes?: {
        rowActions: RowAction[];
        menuAlignment?: string;
    };
}

export default class TypescriptDemo extends LightningElement {
    // Reactive properties - class fields are reactive by default in modern LWC
    inputValue: string = '';
    selectedLanguage: string = 'typescript';
    clickCount: number = 0;

    // Computed property for button variant
    get buttonVariant(): string {
        return this.clickCount > 5 ? 'success' : 'brand';
    }

    // Typed options array for combobox
    get languageOptions(): LanguageOption[] {
        return [
            { label: 'TypeScript', value: 'typescript' },
            { label: 'JavaScript', value: 'javascript' },
            { label: 'Apex', value: 'apex' },
            { label: 'HTML', value: 'html' }
        ];
    }

    // Row actions for datatable
    get rowActions(): RowAction[] {
        return [
            { label: 'View Details', name: 'view_details' },
            { label: 'Copy Import', name: 'copy_import' }
        ];
    }

    // Typed table columns for datatable
    get tableColumns(): TableColumn[] {
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
    get tableData(): TableRow[] {
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
    handleInputChange(event: Event): void {
        const input = event.target as LightningInput;
        this.inputValue = input.value ?? '';
    }

    /**
     * Handle combobox change event with typed event target
     * The LightningCombobox type provides IntelliSense for:
     * - value, options, disabled, required, etc.
     */
    handleLanguageChange(event: Event): void {
        const combobox = event.target as LightningCombobox;
        this.selectedLanguage = combobox.value as string;

        this.showToast(
            'Language Selected',
            `You selected: ${this.selectedLanguage}`,
            'success'
        );
    }

    /**
     * Handle button click event
     * Demonstrates querying a typed component from the template
     */
    handleButtonClick(): void {
        this.clickCount++;

        // Example: Query a typed component from template
        const button = this.template?.querySelector(
            'lightning-button'
        ) as (HTMLElement & LightningButton) | null;

        if (button) {
            // IntelliSense works here - try typing "button." to see available properties
            console.log('Button label:', button.label);
            console.log('Button variant:', button.variant);
        }

        if (this.clickCount === 5) {
            this.showToast(
                'Achievement Unlocked!',
                'You clicked 5 times! Button variant changed to success.',
                'success'
            );
        }
    }

    /**
     * Handle row action from datatable
     * The event.detail contains both action and row information
     */
    handleRowAction(event: CustomEvent): void {
        const actionName = event.detail.action.name as string;
        const row = event.detail.row as TableRow;

        switch (actionName) {
            case 'view_details':
                this.showToast(
                    'Component Details',
                    `${row.component} - Import as: ${row.typeImport}`,
                    'info'
                );
                break;
            case 'copy_import':
                this.showToast(
                    'Import Statement',
                    `import ${row.typeImport} from '${row.component.replace('lightning-', 'lightning/')}';`,
                    'success'
                );
                break;
            default:
                this.showToast('Action', `Unknown action: ${actionName}`, 'warning');
        }
    }

    /**
     * Helper method to show toast notifications
     * Demonstrates TypeScript's type safety with ShowToastEvent
     */
    showToast(
        title: string,
        message: string,
        variant: 'success' | 'error' | 'warning' | 'info'
    ): void {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
