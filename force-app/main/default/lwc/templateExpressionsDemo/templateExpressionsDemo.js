import { LightningElement } from 'lwc';

export default class TemplateExpressionsDemo extends LightningElement {
    // User info
    firstName = 'John';
    lastName = 'Doe';
    isLoggedIn = true;

    // Form input
    inputName = '';

    // Numeric values for calculations
    price = 99.99;
    quantity = 3;
    discountPercent = 15;

    // Status tracking
    status = 'active';
    score = 85;

    // User profile with nested data
    user = {
        profile: {
            name: 'Jane Smith',
            settings: {
                theme: 'dark'
            }
        }
    };

    // Items for list processing
    items = [
        { id: 1, name: 'Laptop', price: 999.99, inStock: true },
        { id: 2, name: 'Mouse', price: 29.99, inStock: true },
        { id: 3, name: 'Keyboard', price: 79.99, inStock: false },
        { id: 4, name: 'Monitor', price: 299.99, inStock: true }
    ];

    // Contacts for iteration demo
    contacts = [
        { id: 1, firstName: 'Alice', lastName: 'Johnson', email: 'alice@example.com', age: 28 },
        { id: 2, firstName: 'Bob', lastName: 'Smith', email: null, age: 16 },
        { id: 3, firstName: 'Charlie', lastName: 'Brown', email: 'charlie@example.com', age: 35 }
    ];

    // Handle input change
    handleInput(event) {
        this.inputName = event.detail.value;
    }

    // Toggle login status
    handleToggleLogin() {
        this.isLoggedIn = !this.isLoggedIn;
    }

    // Increment quantity
    handleIncrement() {
        this.quantity++;
    }

    // Decrement quantity
    handleDecrement() {
        if (this.quantity > 0) {
            this.quantity--;
        }
    }

    // Format currency
    formatCurrency(amount) {
        return `$${amount.toFixed(2)}`;
    }

    // Get current date formatted
    formatDate(timestamp) {
        return new Date(timestamp).toLocaleDateString();
    }

    // Get in-stock items
    getInStockItems() {
        return this.items.filter(item => item.inStock);
    }
}
