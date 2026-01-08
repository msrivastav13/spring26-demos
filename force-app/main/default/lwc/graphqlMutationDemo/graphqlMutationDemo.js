import { LightningElement, wire } from 'lwc';
import { gql, graphql, executeMutation } from 'lightning/graphql';

// ============================================================================
// GraphQL Mutation Demo - Teaching executeMutation from lightning/graphql
// ============================================================================
// This component demonstrates the new executeMutation method for:
// 1. Creating records (ContactCreate)
// 2. Updating records (ContactUpdate)
// 3. Deleting records (ContactDelete)
// ============================================================================
// Pattern: Use getter methods that return gql queries, pass variables separately
// Reference: https://developer.salesforce.com/docs/platform/lwc/guide/reference-graphql-mutation.html
// ============================================================================

export default class GraphqlMutationDemo extends LightningElement {
    // Form fields for create/update
    firstName = '';
    lastName = '';
    email = '';

    // Track the selected contact for update/delete
    selectedContactId = null;

    // State management
    contacts = [];
    totalContactCount = 0;
    isLoading = false;
    error = null;
    successMessage = null;

    // Mode: 'create' or 'edit'
    mode = 'create';

    // Store the refresh method returned by the wire adapter
    _refresh;

    // Pagination state
    pageSize = 10;
    currentCursor = null;
    pageInfo = {
        hasNextPage: false,
        hasPreviousPage: false,
        startCursor: null,
        endCursor: null
    };
    // Stack to track previous page cursors for backward navigation
    cursorStack = [];

    // ========================================================================
    // GETTER METHODS FOR QUERIES AND MUTATIONS
    // Following the pattern from Salesforce documentation:
    // https://developer.salesforce.com/docs/platform/lwc/guide/reference-graphql-mutation.html
    // ========================================================================

    /**
     * QUERY - Fetches contacts to display (used with wire adapter)
     * Uses cursor-based pagination with first/after parameters
     */
    get contactsQuery() {
        return gql`
            query GetContacts($first: Int, $after: String) {
                uiapi {
                    query {
                        Contact(first: $first, after: $after, orderBy: { CreatedDate: { order: DESC } }) {
                            totalCount
                            edges {
                                node {
                                    Id
                                    FirstName {
                                        value
                                    }
                                    LastName {
                                        value
                                    }
                                    Email {
                                        value
                                    }
                                }
                            }
                            pageInfo {
                                hasNextPage
                                hasPreviousPage
                                startCursor
                                endCursor
                            }
                        }
                    }
                }
            }
        `;
    }

    /**
     * Variables for the contacts query - reactive to cursor changes
     */
    get contactsQueryVariables() {
        return {
            first: this.pageSize,
            after: this.currentCursor
        };
    }

    /**
     * CREATE MUTATION - Creates a new Contact record
     * Uses $input variable with ContactCreateInput type
     */
    get createQuery() {
        return gql`
            mutation CreateContact($input: ContactCreateInput!) {
                uiapi {
                    ContactCreate(input: $input) {
                        Record {
                            Id
                            FirstName {
                                value
                            }
                            LastName {
                                value
                            }
                            Email {
                                value
                            }
                        }
                    }
                }
            }
        `;
    }

    /**
     * UPDATE MUTATION - Updates an existing Contact record
     * Uses $input variable with ContactUpdateInput type
     */
    get updateQuery() {
        return gql`
            mutation UpdateContact($input: ContactUpdateInput!) {
                uiapi {
                    ContactUpdate(input: $input) {
                        Record {
                            Id
                            FirstName {
                                value
                            }
                            LastName {
                                value
                            }
                            Email {
                                value
                            }
                        }
                    }
                }
            }
        `;
    }

    /**
     * DELETE MUTATION - Deletes a Contact record
     * The Id is embedded directly in the mutation (not as a variable)
     */
    get deleteQuery() {
        return gql`
            mutation DeleteContact {
                uiapi {
                    ContactDelete(input: { Id: "${this.selectedContactId}" }) {
                        Id
                    }
                }
            }
        `;
    }

    // Wire the query to fetch contacts using @wire decorator with graphql adapter
    // Pass variables for pagination support
    @wire(graphql, { query: '$contactsQuery', variables: '$contactsQueryVariables' })
    contactsResult({ data, errors, refresh }) {
        // Store the refresh method returned by the wire adapter
        // This is the recommended pattern for refreshing GraphQL queries
        this._refresh = refresh;

        // Process the data and errors
        if (data) {
            const contactData = data.uiapi.query.Contact;
            this.contacts = contactData.edges.map(edge => ({
                id: edge.node.Id,
                firstName: edge.node.FirstName?.value || '',
                lastName: edge.node.LastName?.value || '',
                email: edge.node.Email?.value || '',
                fullName: `${edge.node.FirstName?.value || ''} ${edge.node.LastName?.value || ''}`.trim()
            }));
            
            // Update total count
            this.totalContactCount = contactData.totalCount || 0;
            
            // Update pagination info
            if (contactData.pageInfo) {
                this.pageInfo = {
                    hasNextPage: contactData.pageInfo.hasNextPage,
                    hasPreviousPage: this.cursorStack.length > 0,
                    startCursor: contactData.pageInfo.startCursor,
                    endCursor: contactData.pageInfo.endCursor
                };
            }
            this.error = null;
        }
        if (errors) {
            this.error = errors.map(e => e.message).join(', ');
            this.contacts = [];
        }
    }

    // ========================================================================
    // CREATE OPERATION
    // ========================================================================
    async handleCreate() {
        // Validate required fields
        if (!this.lastName) {
            this.showError('Last Name is required');
            return;
        }

        this.isLoading = true;
        this.clearMessages();

        try {
            // executeMutation using the getter pattern from Salesforce docs
            // Pass the query from getter and variables with input object
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

            // Check for errors in the response
            if (result.errors) {
                this.showError(result.errors.map(e => e.message).join(', '));
                return;
            }

            // Access the created record from the response (wrapped in data)
            const createdRecord = result.data.uiapi.ContactCreate.Record;

            this.showSuccess(
                `Contact created successfully! ID: ${createdRecord.Id}`
            );

            // Clear form and refresh list
            this.clearForm();
            this.refreshContacts();

        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // ========================================================================
    // UPDATE OPERATION
    // ========================================================================
    async handleUpdate() {
        if (!this.selectedContactId) {
            this.showError('Please select a contact to update');
            return;
        }

        if (!this.lastName) {
            this.showError('Last Name is required');
            return;
        }

        this.isLoading = true;
        this.clearMessages();

        try {
            // executeMutation for update using the getter pattern
            // Id is at the top level of input, fields to update are inside Contact
            const result = await executeMutation({
                query: this.updateQuery,
                variables: {
                    input: {
                        Id: this.selectedContactId,
                        Contact: {
                            FirstName: this.firstName,
                            LastName: this.lastName,
                            Email: this.email
                        }
                    }
                }
            });

            // Check for errors in the response
            if (result.errors) {
                this.showError(result.errors.map(e => e.message).join(', '));
                return;
            }

            // The response includes the updated record with requested fields (wrapped in data)
            const updatedRecord = result.data.uiapi.ContactUpdate.Record;

            this.showSuccess(
                `Contact updated! Name: ${updatedRecord.FirstName?.value} ${updatedRecord.LastName?.value}`
            );

            // Clear form and refresh list
            this.clearForm();
            this.refreshContacts();

        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // ========================================================================
    // DELETE OPERATION
    // ========================================================================
    async handleDelete() {
        if (!this.selectedContactId) {
            this.showError('Please select a contact to delete');
            return;
        }

        this.isLoading = true;
        this.clearMessages();

        try {
            // executeMutation for delete - Id is embedded in the query itself
            const result = await executeMutation({
                query: this.deleteQuery
            });

            // Check for errors in the response
            if (result.errors) {
                this.showError(result.errors.map(e => e.message).join(', '));
                return;
            }
            // Delete returns the ID of the deleted record (wrapped in data)
            const deletedId = result.data.uiapi.ContactDelete.Id;

            this.showSuccess(`Contact deleted! ID: ${deletedId}`);

            // Clear form and refresh list
            this.clearForm();
            this.refreshContacts();

        } catch (error) {
            this.handleError(error);
        } finally {
            this.isLoading = false;
        }
    }

    // ========================================================================
    // UI Event Handlers
    // ========================================================================
    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handleContactSelect(event) {
        const contactId = event.currentTarget.dataset.id;
        const contact = this.contacts.find(c => c.id === contactId);

        if (contact) {
            this.selectedContactId = contact.id;
            this.firstName = contact.firstName;
            this.lastName = contact.lastName;
            this.email = contact.email;
            this.mode = 'edit';
        }
    }

    handleNewContact() {
        this.clearForm();
    }

    // ========================================================================
    // Pagination Handlers
    // ========================================================================
    handleNextPage() {
        if (this.pageInfo.hasNextPage && this.pageInfo.endCursor) {
            // Push current cursor to stack before moving forward
            this.cursorStack = [...this.cursorStack, this.currentCursor];
            this.currentCursor = this.pageInfo.endCursor;
        }
    }

    handlePreviousPage() {
        if (this.cursorStack.length > 0) {
            // Pop the previous cursor from stack
            const newStack = [...this.cursorStack];
            this.currentCursor = newStack.pop();
            this.cursorStack = newStack;
        }
    }

    handleFirstPage() {
        // Reset to first page
        this.currentCursor = null;
        this.cursorStack = [];
    }

    // ========================================================================
    // Helper Methods
    // ========================================================================
    clearForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.selectedContactId = null;
        this.mode = 'create';
    }

    clearMessages() {
        this.error = null;
        this.successMessage = null;
    }

    showSuccess(message) {
        this.successMessage = message;
        this.error = null;
    }

    showError(message) {
        this.error = message;
        this.successMessage = null;
    }

    handleError(error) {
        // GraphQL errors come in different formats
        if (error.body?.errors) {
            this.error = error.body.errors.map(e => e.message).join(', ');
        } else if (error.message) {
            this.error = error.message;
        } else {
            this.error = 'An unexpected error occurred';
        }
        console.error('Mutation error:', error);
    }

    async refreshContacts() {
        // Reset to first page after mutations to see the latest data
        this.currentCursor = null;
        this.cursorStack = [];
        
        // Use the refresh method returned by the wire adapter
        // The refresh method reuses the current query, variables, and operation name
        // It returns a Promise that resolves when fresh data is delivered through the wire
        if (this._refresh) {
            await this._refresh();
        }
    }

    // ========================================================================
    // Computed Properties for Template
    // ========================================================================
    get isCreateMode() {
        return this.mode === 'create';
    }

    get isEditMode() {
        return this.mode === 'edit';
    }

    get formTitle() {
        return this.isCreateMode ? 'Create New Contact' : 'Edit Contact';
    }

    get hasContacts() {
        return this.contacts.length > 0;
    }

    get submitButtonLabel() {
        return this.isCreateMode ? 'Create Contact' : 'Update Contact';
    }

    // Pagination computed properties
    get hasPreviousPage() {
        return this.cursorStack.length > 0;
    }

    get hasNextPage() {
        return this.pageInfo.hasNextPage;
    }

    get currentPageNumber() {
        return this.cursorStack.length + 1;
    }

    get isPreviousDisabled() {
        return !this.hasPreviousPage || this.isLoading;
    }

    get isNextDisabled() {
        return !this.hasNextPage || this.isLoading;
    }

    // ========================================================================
    // Code Examples for Display
    // ========================================================================
    get createExampleCode() {
        return `// Define the mutation with gql
const CREATE_CONTACT = gql\`
  mutation ContactCreate($input: ContactCreateInput!) {
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
\`;

// Execute the mutation
const result = await executeMutation({
  query: CREATE_CONTACT,
  variables: {
    input: {
      Contact: {
        FirstName: 'Sam',
        LastName: 'Smith'
      }
    }
  }
});

// Access the created record
const newId = result.data.uiapi.ContactCreate.Record.Id;`;
    }

    get updateExampleCode() {
        return `// Define the update mutation
const UPDATE_CONTACT = gql\`
  mutation UpdateContact($input: ContactUpdateInput!) {
    uiapi {
      ContactUpdate(input: $input) {
        Record {
          Id
          FirstName { value }
          LastName { value }
        }
      }
    }
  }
\`;

// Execute the mutation
const result = await executeMutation({
  query: UPDATE_CONTACT,
  variables: {
    input: {
      Id: '003RM000008AAAAAA4',
      Contact: {
        FirstName: 'Updated Name',
        LastName: 'Smith'
      }
    }
  }
});

// Access the updated record
const updated = result.data.uiapi.ContactUpdate.Record;`;
    }

    get deleteExampleCode() {
        return `// Define the delete mutation
const DELETE_CONTACT = gql\`
  mutation ContactDelete {
    uiapi {
      ContactDelete(input: { 
        Id: "003RM000008AAAAAA4" 
      }) {
        Id
      }
    }
  }
\`;

// Execute the deletion
const result = await executeMutation({
  query: DELETE_CONTACT
});

// Confirm deletion
const deletedId = result.data.uiapi.ContactDelete.Id;`;
    }
}
