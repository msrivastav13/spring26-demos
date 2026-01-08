# 🚀 Salesforce Spring '26 Developer Features

<div align="center">

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![LWC](https://img.shields.io/badge/LWC-TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Apex](https://img.shields.io/badge/Apex-API%20v66.0-FF6B6B?style=for-the-badge)

**A comprehensive demo project showcasing the exciting new Spring '26 features for Salesforce developers**

[LWC Features](#-lwc-features) • [Apex Features](#-apex-features) • [Getting Started](#-getting-started) • [Resources](#-resources)

</div>

---

## ✨ What's New in Spring '26

This repository contains working examples of the most impactful Spring '26 features for Salesforce developers. Each demo is fully functional and ready to deploy to your scratch org or sandbox.

### 📋 Feature Overview

| Category | Feature | Status |
|----------|---------|--------|
| 🎨 LWC | [TypeScript Support](#1--typescript-support) | ✅ GA |
| 🎯 LWC | [Dynamic Event Binding (lwc:on)](#2--dynamic-event-binding-lwcon) | ✅ GA |
| 📝 LWC | [Complex Template Expressions](#3--complex-template-expressions) | 🧪 Beta |
| 🖼️ LWC | [Empty State Components](#4--empty-state-components) | 🧪 Beta |
| 🔄 LWC | [GraphQL Mutations](#5--graphql-mutations) | ✅ GA |
| 🔀 LWC | [Flow Navigation](#6--flow-navigation) | ✅ GA |
| ⚙️ Apex | [Picklist Values by Record Type](#7--picklist-values-by-record-type) | ✅ GA |
| 📄 Apex | [Visualforce PDF Rendering](#8--visualforce-pdf-rendering) | ✅ GA |

---

## 🎨 LWC Features

### 1. 📘 TypeScript Support

**Location:** [`force-app/main/default/lwc/typescriptDemo/`](force-app/main/default/lwc/typescriptDemo/)

Spring '26 brings native TypeScript support to Lightning Web Components! Write type-safe code with full IntelliSense for Lightning base components.

#### Key Features
- 🎯 Full type definitions via `@salesforce/lightning-types` npm package
- 🔍 IntelliSense for all Lightning base components
- ✅ Compile-time type checking
- 📖 Better documentation through types

#### Example

```typescript
import { LightningElement } from 'lwc';
import LightningInput from 'lightning/input';
import LightningButton from 'lightning/button';

export default class TypescriptDemo extends LightningElement {
    inputValue: string = '';
    clickCount: number = 0;

    // Typed event handler with full IntelliSense
    handleInputChange(event: Event): void {
        const input = event.target as LightningInput;
        this.inputValue = input.value ?? '';
    }

    // Computed property with explicit return type
    get buttonVariant(): string {
        return this.clickCount > 5 ? 'success' : 'brand';
    }
}
```

#### Setup Required
```bash
npm install @salesforce/lightning-types --save-dev
```

---

### 2. 🎯 Dynamic Event Binding (lwc:on)

**Location:** [`force-app/main/default/lwc/dynamicEventDemo/`](force-app/main/default/lwc/dynamicEventDemo/)

The new `lwc:on` directive allows you to dynamically attach multiple event listeners using a computed object. Perfect for building configurable, interactive components!

#### Key Features
- 🔄 Dynamic event listener attachment
- ⚡ Computed event handlers based on state
- 🎮 Perfect for games, interactive UIs, and accessibility
- 📱 Easily switch between touch/click/hover modes

#### Example

```html
<!-- Template: Attach dynamic handlers -->
<div lwc:on={pad.eventHandlers} class="beat-pad">
    {pad.label}
</div>
```

```javascript
// JavaScript: Compute handlers dynamically
computeEventHandlers(padId) {
    const handlers = {};
    
    // Always include base handlers
    handlers.mousedown = (e) => this.handleTrigger(e, padId);
    handlers.mouseup = (e) => this.handleRelease(e, padId);
    
    // Conditionally add hover handlers
    if (this.mode === 'hover') {
        handlers.mouseenter = (e) => this.handleTrigger(e, padId);
    }
    
    // Conditionally add touch handlers
    if (this.mode === 'touch') {
        handlers.touchstart = (e) => this.handleTrigger(e, padId);
        handlers.touchend = (e) => this.handleRelease(e, padId);
    }
    
    return handlers;
}
```

#### Demo Included
🎵 **Interactive Beat Pad Machine** - A fun drum machine that demonstrates dynamic event binding with different trigger modes (click, hover, touch, all).

---

### 3. 📝 Complex Template Expressions

**Location:** [`force-app/main/default/lwc/templateExpressionsDemo/`](force-app/main/default/lwc/templateExpressionsDemo/)

Write JavaScript expressions directly in your templates! No more getter methods for simple logic.

#### Key Features
- 📐 **Ternary operators:** `{isActive ? 'Active' : 'Inactive'}`
- 📝 **Template literals:** `` {`Hello, ${name}!`} ``
- ➕ **Arithmetic:** `{price * quantity}`
- 🔗 **Optional chaining:** `{user?.profile?.name}`
- ❓ **Nullish coalescing:** `{value ?? 'default'}`
- 🔢 **Array methods:** `{items.filter(i => i.active).length}`
- 📞 **Function calls:** `{formatCurrency(total)}`
- 🖱️ **Inline handlers:** `{() => count++}`

#### Example

```html
<template>
    <!-- Template Literals -->
    <p>{`Welcome, ${firstName} ${lastName}!`}</p>
    
    <!-- Ternary Operators -->
    <p>{isLoggedIn ? 'Welcome back!' : 'Please log in'}</p>
    <p>{score > 80 ? 'Excellent' : score > 60 ? 'Good' : 'Needs Work'}</p>
    
    <!-- Optional Chaining + Nullish Coalescing -->
    <p>Theme: {user?.profile?.settings?.theme ?? 'light'}</p>
    
    <!-- Arithmetic & Function Calls -->
    <p>Total: {formatCurrency(price * quantity * (100 - discount) / 100)}</p>
    
    <!-- Array Methods -->
    <p>In Stock: {items.filter(item => item.inStock).length} items</p>
    
    <!-- Inline Event Handlers -->
    <lightning-button onclick={() => quantity++} label="Add" />
    
    <!-- Dynamic Classes -->
    <div class={isActive ? 'slds-text-color_success' : 'slds-text-color_error'}>
        Status
    </div>
</template>
```

---

### 4. 🖼️ Empty State Components

**Location:** [`force-app/main/default/lwc/emptyStateDemo/`](force-app/main/default/lwc/emptyStateDemo/)

New base components for displaying empty states with beautiful, theme-adaptive illustrations.

#### Key Features
- 🎨 Theme-adaptive (works with SLDS 1/2 and dark mode)
- 📱 Responsive design
- 🎯 Multiple illustration types
- 🔘 Built-in CTA button slots

#### Components

| Component | Use Case |
|-----------|----------|
| `lightning-empty-state` | Full empty state with title, description, and CTA |
| `lightning-illustration` | Illustration only (no text) |

#### Example

```html
<!-- Full Empty State -->
<lightning-empty-state
    illustration-name="cart:noitems"
    title="Your cart is empty">
    <p slot="description">
        Browse our product catalog to find items you love.
    </p>
    <lightning-button
        variant="brand"
        label="Browse Products"
        slot="cta"
        onclick={handleBrowse}>
    </lightning-button>
</lightning-empty-state>

<!-- Illustration Only -->
<lightning-illustration
    illustration-name="noTask"
    alternative-text="No tasks remaining">
</lightning-illustration>
```

#### Available Illustrations
- `cart:noitems` - Empty shopping cart
- `noTask` - All tasks complete
- `noResult` - No search results
- And many more from the SLDS illustration library!

---

### 5. 🔄 GraphQL Mutations

**Location:** [`force-app/main/default/lwc/graphqlMutationDemo/`](force-app/main/default/lwc/graphqlMutationDemo/)

The new `executeMutation` function enables Create, Update, and Delete operations via GraphQL!

#### Key Features
- ✨ **Create** records with `ContactCreate`
- 📝 **Update** records with `ContactUpdate`
- 🗑️ **Delete** records with `ContactDelete`
- 🔄 Full integration with `@wire` for queries
- 📄 Cursor-based pagination support

#### Example

```javascript
import { gql, graphql, executeMutation } from 'lightning/graphql';

// Define mutation
get createQuery() {
    return gql`
        mutation CreateContact($input: ContactCreateInput!) {
            uiapi {
                ContactCreate(input: $input) {
                    Record {
                        Id
                        FirstName { value }
                        LastName { value }
                    }
                }
            }
        }
    `;
}

// Execute mutation
async handleCreate() {
    const result = await executeMutation({
        query: this.createQuery,
        variables: {
            input: {
                Contact: {
                    FirstName: this.firstName,
                    LastName: this.lastName,
                    Email: this.email
                }
            }
        }
    });
    
    const newRecord = result.data.uiapi.ContactCreate.Record;
    console.log('Created:', newRecord.Id);
}
```

#### Demo Included
📇 **Contact Manager** - A full CRUD application demonstrating create, read, update, and delete operations with GraphQL, including pagination.

---

### 6. 🔀 Flow Navigation

**Location:** [`force-app/main/default/lwc/flowNavigationDemo/`](force-app/main/default/lwc/flowNavigationDemo/)

Navigate to Flows directly from LWC using the new `standard__flow` PageReference type!

#### Key Features
- 🔗 Navigate to any Flow by developer name
- 📥 Pass input variables to Flows
- 🔗 Generate Flow URLs for sharing

#### Example

```javascript
import { NavigationMixin } from 'lightning/navigation';

export default class FlowNav extends NavigationMixin(LightningElement) {
    
    // Simple navigation to a Flow
    navigateToFlow() {
        this[NavigationMixin.Navigate]({
            type: 'standard__flow',
            attributes: {
                devName: 'MyFlowApiName'
            }
        });
    }
    
    // Navigate with input variables (prefix with 'flow__')
    navigateWithInputs() {
        this[NavigationMixin.Navigate]({
            type: 'standard__flow',
            attributes: {
                devName: 'MyFlowApiName'
            },
            state: {
                flow__recordId: this.recordId,
                flow__userName: 'Trailblazer'
            }
        });
    }
    
    // Generate a shareable URL
    async generateUrl() {
        const url = await this[NavigationMixin.GenerateUrl]({
            type: 'standard__flow',
            attributes: {
                devName: 'MyFlowApiName'
            }
        });
        console.log('Flow URL:', url);
    }
}
```

---

## ⚙️ Apex Features

### 7. 📋 Picklist Values by Record Type

**Location:** [`force-app/main/default/classes/PicklistValuesByRecordTypeDemo.cls`](force-app/main/default/classes/PicklistValuesByRecordTypeDemo.cls)

Get all picklist values for a specific record type in a single call - no callouts required!

#### Key Features
- 🚀 Single API call for all picklist fields
- 🔗 Includes dependent picklist relationships
- 📋 Works with custom and standard fields
- ⚡ No callouts or HTTP requests needed

#### Example

```apex
// Get all picklist values for a record type
ConnectApi.PicklistValuesCollection picklistCollection = 
    ConnectApi.RecordUi.getPicklistValuesByRecordType(
        'Case',           // Object API Name
        recordTypeId      // Record Type Id
    );

// Access specific field values
if (picklistCollection.picklistFieldValues != null) {
    ConnectApi.PicklistValues statusValues = 
        picklistCollection.picklistFieldValues.get('Status');
    
    for (ConnectApi.PicklistValue pv : statusValues.values) {
        System.debug('Status: ' + pv.label + ' = ' + pv.value);
    }
}

// Handle dependent picklists
if (fieldValues.controllerValues != null) {
    // This field is dependent - get valid values per controller
    Map<String, Integer> controllerMap = fieldValues.controllerValues;
    // Filter values based on controlling field selection
}
```

#### Use Cases
- 🎯 Dynamic forms based on record type
- 📝 Dependent picklist cascades
- ✅ Validation of picklist values
- 🔄 Sync picklist values to external systems

---

### 8. 📄 Visualforce PDF Rendering

**Location:** [`force-app/main/default/classes/VisualforcePdfRenderingDemo.cls`](force-app/main/default/classes/VisualforcePdfRenderingDemo.cls)

`Blob.toPdf()` now uses the Visualforce PDF rendering service with enhanced font and language support!

#### Key Features
- 🌍 **Full multibyte character support** (CJK, Thai, Arabic, Hindi, etc.)
- 🔤 **New default font:** sans-serif (previously serif)
- 🎨 **Extended font families** including Arial Unicode MS
- 📄 **Consistent rendering** with Visualforce PDFs

#### Example

```apex
// Generate a multilingual PDF
String html = '<!DOCTYPE html>' +
    '<html><body>' +
    '<h1>Global Support</h1>' +
    '<p>Japanese: こんにちは</p>' +
    '<p>Chinese: 你好世界</p>' +
    '<p>Korean: 안녕하세요</p>' +
    '<p>Thai: สวัสดี</p>' +
    '<p>Arabic: مرحبا</p>' +
    '</body></html>';

Blob pdfBlob = Blob.toPdf(html);

// Save to Files
ContentVersion cv = new ContentVersion();
cv.Title = 'Multilingual Document';
cv.PathOnClient = 'document.pdf';
cv.VersionData = pdfBlob;
insert cv;
```

#### Migration Notes

> ⚠️ **Breaking Change:** Default font changed from `serif` to `sans-serif`
> 
> If your PDFs rely on the old serif appearance, explicitly set:
> ```css
> body { font-family: serif; }
> ```

#### Available Fonts
| Font | Best For |
|------|----------|
| Arial Unicode MS | International characters (CJK) |
| Helvetica | Clean sans-serif |
| Times New Roman | Classic serif |
| Courier New | Monospace / code |
| Georgia | Elegant serif |
| Verdana | Wide sans-serif |
| sans-serif | **NEW DEFAULT** |
| serif | Old default |

---

## 🚀 Getting Started

### Prerequisites

- Salesforce CLI (`sf`)
- Node.js 18+ and npm
- VS Code with Salesforce Extension Pack (recommended)
- A Salesforce org (scratch org, sandbox, or dev org)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/spring26-demos.git
   cd spring26-demos
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Authorize your org**
   ```bash
   sf org login web --alias my-org
   ```

4. **Deploy to your org**
   ```bash
   sf project deploy start --target-org my-org
   ```

5. **Open the org**
   ```bash
   sf org open --target-org my-org
   ```

### Running TypeScript Components

For TypeScript support in LWC:

```bash
# Install TypeScript types
npm install @salesforce/lightning-types --save-dev

# The tsconfig.json is already configured in the lwc folder
```

---

## 📁 Project Structure

```
spring26-demos/
├── force-app/main/default/
│   ├── classes/
│   │   ├── PicklistValuesByRecordTypeDemo.cls    # ConnectApi picklist demo
│   │   ├── VisualforcePdfRenderingDemo.cls       # PDF rendering demo
│   │   └── ...
│   ├── lwc/
│   │   ├── typescriptDemo/                        # TypeScript support
│   │   ├── dynamicEventDemo/                      # lwc:on directive
│   │   ├── templateExpressionsDemo/               # Template expressions
│   │   ├── emptyStateDemo/                        # Empty state components
│   │   ├── graphqlMutationDemo/                   # GraphQL mutations
│   │   └── flowNavigationDemo/                    # Flow navigation
│   └── flows/
│       └── SimpleGreetingFlow.flow-meta.xml       # Sample flow
├── scripts/
│   └── apex/
│       └── visualforcePdfDemo.apex                # PDF demo script
├── package.json
└── README.md
```

---

## 📚 Resources

### Official Documentation
- [Spring '26 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.salesforce_release_notes.htm)
- [LWC TypeScript Support](https://developer.salesforce.com/docs/platform/lwc/guide/ts.html)
- [Lightning GraphQL API](https://developer.salesforce.com/docs/platform/lwc/guide/reference-graphql-mutation.html)
- [ConnectApi.RecordUi](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_ConnectAPI_RecordUi_static_methods.htm)

### Trailhead Modules
- [Build Lightning Web Components](https://trailhead.salesforce.com/content/learn/trails/build-lightning-web-components)
- [Apex Basics & Database](https://trailhead.salesforce.com/content/learn/modules/apex_database)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ for Salesforce Developers**

⭐ Star this repo if you found it helpful!

</div>
