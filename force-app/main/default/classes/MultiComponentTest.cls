/**
 * MultiComponentTest - Test class demonstrating testFor with multiple components
 * 
 * RUNRELEVANTTESTS DEMO: @IsTest(testFor='...') with Multiple Components
 * 
 * This test class demonstrates how to use @IsTest(testFor='...') to specify
 * multiple components that should trigger the test to run.
 * 
 * When deploying with the RunRelevantTests test level:
 * - This test class will run when AccountService.cls is new or modified
 * - This test class will run when ContactService.cls is new or modified
 * - This test class will run when UtilityHelper.cls is new or modified
 * - This provides comprehensive integration testing when any related component changes
 * 
 * Syntax: @IsTest(testFor='ApexClass:Class1, ApexClass:Class2, ApexTrigger:Trigger1')
 * 
 * Available in API version 66.0 and later.
 */
@IsTest(testFor='ApexClass:AccountService, ApexClass:ContactService, ApexClass:UtilityHelper')
private class MultiComponentTest {
    
    /**
     * Integration test: Creating Account and Contact together
     * Tests the interaction between AccountService and ContactService
     */
    @IsTest
    static void testIntegration_AccountAndContact() {
        Test.startTest();
        
        // Create an Account using AccountService
        Account acc = AccountService.createAccount('Integration Test Company');
        Assert.isNotNull(acc.Id, 'Account should be created');
        
        // Create a Contact using ContactService
        Contact con = ContactService.createContact('Integration', 'TestContact', acc.Id);
        Assert.isNotNull(con.Id, 'Contact should be created');
        
        // Verify relationship with user mode query
        Contact retrieved = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id WITH USER_MODE];
        Assert.areEqual(acc.Id, retrieved.AccountId, 'Contact should be linked to Account');
        
        Test.stopTest();
    }
    
    /**
     * Integration test: Multiple Contacts per Account
     * Tests bulk Contact creation and retrieval
     */
    @IsTest
    static void testIntegration_MultipleContacts() {
        // Create Account
        Account acc = AccountService.createAccount('Multi-Contact Company');
        
        Test.startTest();
        
        // Create multiple Contacts
        ContactService.createContact('First', 'Contact', acc.Id);
        ContactService.createContact('Second', 'Contact', acc.Id);
        ContactService.createContact('Third', 'Contact', acc.Id);
        
        // Retrieve all contacts
        List<Contact> contacts = ContactService.getContactsByAccountId(acc.Id);
        
        Test.stopTest();
        
        Assert.areEqual(3, contacts.size(), 'Should have 3 contacts');
        
        // Verify with user mode query
        List<Contact> verifyContacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id WITH USER_MODE];
        Assert.areEqual(3, verifyContacts.size(), 'Database should have 3 contacts');
    }
    
    /**
     * Integration test: Using UtilityHelper with services
     * Tests that utility methods work correctly
     */
    @IsTest
    static void testIntegration_UtilityWithServices() {
        Test.startTest();
        
        // Test UtilityHelper.formatName
        String formattedName = UtilityHelper.formatName('test company');
        Assert.areEqual('Test company', formattedName, 'Name should be formatted');
        
        // Create Account with formatted name
        Account acc = AccountService.createAccount('Test Company');
        Assert.isNotNull(acc.Id, 'Account should be created');
        
        // Validate the Account Id using UtilityHelper
        Boolean isValid = UtilityHelper.isValidId(String.valueOf(acc.Id));
        Assert.isTrue(isValid, 'Account Id should be valid');
        
        // Verify in user mode
        Account verifyAcc = [SELECT Id, Name FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual('Test Company', verifyAcc.Name, 'Account should exist in database');
        
        Test.stopTest();
    }
    
    /**
     * Integration test: Error handling across services
     * Tests that errors are properly handled
     */
    @IsTest
    static void testIntegration_ErrorHandling() {
        Test.startTest();
        
        // Test AccountService error handling
        Boolean accountErrorCaught = false;
        try {
            AccountService.createAccount('');
        } catch (AccountService.AccountServiceException e) {
            accountErrorCaught = true;
        }
        Assert.isTrue(accountErrorCaught, 'AccountService should throw error for blank name');
        
        // Test ContactService error handling
        Boolean contactErrorCaught = false;
        try {
            ContactService.createContact('First', '', null);
        } catch (ContactService.ContactServiceException e) {
            contactErrorCaught = true;
        }
        Assert.isTrue(contactErrorCaught, 'ContactService should throw error for blank last name');
        
        // Test UtilityHelper validation
        Boolean utilityErrorCaught = false;
        try {
            UtilityHelper.validateNotBlank('', 'Test Field');
        } catch (UtilityHelper.UtilityException e) {
            utilityErrorCaught = true;
        }
        Assert.isTrue(utilityErrorCaught, 'UtilityHelper should throw error for blank value');
        
        Test.stopTest();
    }
    
    /**
     * Integration test: Full workflow
     * Tests a complete business workflow using all services
     */
    @IsTest
    static void testIntegration_FullWorkflow() {
        Test.startTest();
        
        // Step 1: Generate a reference number
        String reference = UtilityHelper.generateReference('WF');
        Assert.isTrue(reference.startsWith('WF-'), 'Reference should have correct prefix');
        
        // Step 2: Create Account
        Account acc = AccountService.createAccount('Workflow Test Company - ' + reference);
        Assert.isNotNull(acc.Id, 'Account should be created');
        
        // Step 3: Update Account industry
        Account updatedAcc = AccountService.updateAccountIndustry(acc.Id, 'Technology');
        Assert.areEqual('Technology', updatedAcc.Industry, 'Industry should be updated');
        
        // Step 4: Create primary Contact
        Contact primaryContact = ContactService.createContact('Primary', 'Contact', acc.Id);
        Assert.isNotNull(primaryContact.Id, 'Primary contact should be created');
        
        // Step 5: Update Contact email
        Contact updatedContact = ContactService.updateContactEmail(
            primaryContact.Id, 
            'primary@workflowtest.com'
        );
        Assert.areEqual('primary@workflowtest.com', updatedContact.Email, 'Email should be updated');
        
        // Step 6: Verify final state with user mode queries
        Account finalAccount = [SELECT Id, Name, Industry FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        List<Contact> finalContacts = [SELECT Id, Email FROM Contact WHERE AccountId = :acc.Id WITH USER_MODE];
        
        Assert.areEqual('Technology', finalAccount.Industry, 'Final account state should be correct');
        Assert.areEqual(1, finalContacts.size(), 'Should have one contact');
        Assert.areEqual('primary@workflowtest.com', finalContacts[0].Email, 'Contact email should be correct');
        
        Test.stopTest();
    }
    
    /**
     * Integration test: User mode DML operations
     * Tests that all DML operations work in user mode
     */
    @IsTest
    static void testIntegration_UserModeDML() {
        Test.startTest();
        
        // Create Account in user mode
        Account acc = new Account(Name = 'User Mode Test Account');
        insert as user acc;
        Assert.isNotNull(acc.Id, 'Account should be created in user mode');
        
        // Create Contact in user mode
        Contact con = new Contact(FirstName = 'User', LastName = 'Mode', AccountId = acc.Id);
        insert as user con;
        Assert.isNotNull(con.Id, 'Contact should be created in user mode');
        
        // Update in user mode
        acc.Industry = 'Healthcare';
        update as user acc;
        
        // Verify with user mode query
        Account verifyAcc = [SELECT Industry FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual('Healthcare', verifyAcc.Industry, 'Account should be updated in user mode');
        
        // Delete Contact in user mode
        delete as user con;
        
        // Verify deletion
        List<Contact> deletedContacts = [SELECT Id FROM Contact WHERE Id = :con.Id WITH USER_MODE];
        Assert.areEqual(0, deletedContacts.size(), 'Contact should be deleted in user mode');
        
        Test.stopTest();
    }
}
