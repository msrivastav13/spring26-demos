/**
 * ContactServiceTest - Test class for ContactService
 * 
 * RUNRELEVANTTESTS DEMO: @IsTest(testFor='...')
 * 
 * This test class uses the new @IsTest(testFor='ApexClass:ContactService') annotation.
 * When deploying with the RunRelevantTests test level:
 * - This test class will AUTOMATICALLY run when ContactService.cls is new or modified
 * - This test class will NOT run if ContactService.cls is not in the deployment payload
 * 
 * You can specify multiple components in a single testFor annotation:
 * @IsTest(testFor='ApexClass:ContactService, ApexClass:AccountService')
 * 
 * You can also specify triggers:
 * @IsTest(testFor='ApexTrigger:ContactTrigger')
 * 
 * Available in API version 66.0 and later.
 */
@IsTest(testFor='ApexClass:ContactService')
private class ContactServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create a test Account for Contact tests in user mode
        Account testAccount = new Account(Name = 'Contact Test Account');
        insert as user testAccount;
    }
    
    private static Account getTestAccount() {
        return [SELECT Id, Name FROM Account WHERE Name = 'Contact Test Account' WITH USER_MODE LIMIT 1];
    }
    
    @IsTest
    static void testCreateContact_Success() {
        Account acc = getTestAccount();
        
        Test.startTest();
        Contact con = ContactService.createContact('John', 'Doe', acc.Id);
        Test.stopTest();
        
        Assert.isNotNull(con.Id, 'Contact should be created with an Id');
        Assert.areEqual('John', con.FirstName, 'First name should match');
        Assert.areEqual('Doe', con.LastName, 'Last name should match');
        Assert.areEqual(acc.Id, con.AccountId, 'Account Id should match');
        
        // Verify in user mode
        List<Contact> verifyContacts = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :con.Id WITH USER_MODE];
        Assert.areEqual(1, verifyContacts.size(), 'Contact should exist in database');
    }
    
    @IsTest
    static void testCreateContact_NoFirstName() {
        // First name is optional
        Account acc = getTestAccount();
        
        Test.startTest();
        Contact con = ContactService.createContact(null, 'Smith', acc.Id);
        Test.stopTest();
        
        Assert.isNotNull(con.Id, 'Contact should be created');
        Assert.isNull(con.FirstName, 'First name should be null');
        Assert.areEqual('Smith', con.LastName, 'Last name should match');
    }
    
    @IsTest
    static void testCreateContact_BlankLastName() {
        Account acc = getTestAccount();
        
        Test.startTest();
        try {
            ContactService.createContact('Jane', '', acc.Id);
            Assert.fail('Expected ContactServiceException to be thrown');
        } catch (ContactService.ContactServiceException e) {
            Assert.isTrue(e.getMessage().contains('Last name'), 'Exception should mention last name');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetContactById() {
        Account acc = getTestAccount();
        Contact testCon = new Contact(FirstName = 'Retrieve', LastName = 'Test', AccountId = acc.Id);
        insert as user testCon;
        
        Test.startTest();
        Contact retrieved = ContactService.getContactById(testCon.Id);
        Test.stopTest();
        
        Assert.areEqual(testCon.Id, retrieved.Id, 'Contact Id should match');
        Assert.areEqual('Retrieve', retrieved.FirstName, 'First name should match');
        Assert.areEqual('Test', retrieved.LastName, 'Last name should match');
        Assert.areEqual(acc.Name, retrieved.Account.Name, 'Parent Account name should be retrieved');
    }
    
    @IsTest
    static void testGetContactsByAccountId() {
        Account acc = getTestAccount();
        
        // Create multiple contacts in user mode
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Alice', LastName = 'Anderson', AccountId = acc.Id));
        contacts.add(new Contact(FirstName = 'Bob', LastName = 'Brown', AccountId = acc.Id));
        contacts.add(new Contact(FirstName = 'Charlie', LastName = 'Clark', AccountId = acc.Id));
        insert as user contacts;
        
        Test.startTest();
        List<Contact> retrieved = ContactService.getContactsByAccountId(acc.Id);
        Test.stopTest();
        
        Assert.areEqual(3, retrieved.size(), 'Should retrieve 3 contacts');
        // Verify ordering by last name
        Assert.areEqual('Anderson', retrieved[0].LastName, 'First contact should be Anderson');
        Assert.areEqual('Brown', retrieved[1].LastName, 'Second contact should be Brown');
        Assert.areEqual('Clark', retrieved[2].LastName, 'Third contact should be Clark');
    }
    
    @IsTest
    static void testUpdateContactEmail() {
        Account acc = getTestAccount();
        Contact testCon = new Contact(FirstName = 'Email', LastName = 'Test', AccountId = acc.Id);
        insert as user testCon;
        
        Test.startTest();
        Contact updated = ContactService.updateContactEmail(testCon.Id, 'email.test@example.com');
        Test.stopTest();
        
        Assert.areEqual('email.test@example.com', updated.Email, 'Email should be updated');
        
        // Verify in user mode
        Contact verifyContact = [SELECT Email FROM Contact WHERE Id = :testCon.Id WITH USER_MODE];
        Assert.areEqual('email.test@example.com', verifyContact.Email, 'Email should persist in database');
    }
}
