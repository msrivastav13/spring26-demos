/**
 * AccountServiceTest - Test class for AccountService
 * 
 * RUNRELEVANTTESTS DEMO: @IsTest(testFor='...')
 * 
 * This test class uses the new @IsTest(testFor='ApexClass:AccountService') annotation.
 * When deploying with the RunRelevantTests test level:
 * - This test class will AUTOMATICALLY run when AccountService.cls is new or modified
 * - This test class will NOT run if AccountService.cls is not in the deployment payload
 * 
 * This annotation provides fine-grained control over which tests run during deployment,
 * significantly reducing deployment time for targeted changes.
 * 
 * Available in API version 66.0 and later.
 */
@IsTest(testFor='ApexClass:AccountService')
private class AccountServiceTest {
    
    @IsTest
    static void testCreateAccount_Success() {
        // Test successful Account creation
        Test.startTest();
        Account acc = AccountService.createAccount('Test Company Inc');
        Test.stopTest();
        
        Assert.isNotNull(acc.Id, 'Account should be created with an Id');
        Assert.areEqual('Test Company Inc', acc.Name, 'Account name should match');
        Assert.areEqual('Created by AccountService', acc.Description, 'Description should be set');
        
        // Verify in user mode
        List<Account> verifyAccounts = [SELECT Id, Name, Description FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual(1, verifyAccounts.size(), 'Account should exist in database');
    }
    
    @IsTest
    static void testCreateAccount_BlankName() {
        // Test Account creation with blank name - should throw exception
        Test.startTest();
        try {
            AccountService.createAccount('');
            Assert.fail('Expected AccountServiceException to be thrown');
        } catch (AccountService.AccountServiceException e) {
            Assert.isTrue(e.getMessage().contains('blank'), 'Exception message should mention blank');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testCreateAccount_NullName() {
        // Test Account creation with null name - should throw exception
        Test.startTest();
        try {
            AccountService.createAccount(null);
            Assert.fail('Expected AccountServiceException to be thrown');
        } catch (AccountService.AccountServiceException e) {
            Assert.isTrue(e.getMessage().contains('blank'), 'Exception message should mention blank');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAccountById() {
        // Setup test data in user mode
        Account testAcc = new Account(Name = 'Retrieve Test Account', Industry = 'Technology');
        insert as user testAcc;
        
        // Test retrieval
        Test.startTest();
        Account retrieved = AccountService.getAccountById(testAcc.Id);
        Test.stopTest();
        
        Assert.areEqual(testAcc.Id, retrieved.Id, 'Retrieved Account Id should match');
        Assert.areEqual('Retrieve Test Account', retrieved.Name, 'Retrieved Account name should match');
        Assert.areEqual('Technology', retrieved.Industry, 'Retrieved Account industry should match');
    }
    
    @IsTest
    static void testUpdateAccountIndustry() {
        // Setup test data in user mode
        Account testAcc = new Account(Name = 'Update Test Account');
        insert as user testAcc;
        
        // Test update
        Test.startTest();
        Account updated = AccountService.updateAccountIndustry(testAcc.Id, 'Finance');
        Test.stopTest();
        
        Assert.areEqual('Finance', updated.Industry, 'Industry should be updated');
        
        // Verify in user mode
        Account verifyAcc = [SELECT Industry FROM Account WHERE Id = :testAcc.Id WITH USER_MODE];
        Assert.areEqual('Finance', verifyAcc.Industry, 'Industry should persist in database');
    }
    
    @IsTest
    static void testGetAccountCount() {
        // Get initial count with user mode query
        Integer initialCount = [SELECT COUNT() FROM Account WITH USER_MODE];
        
        // Create test accounts in user mode
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Count Test ' + i));
        }
        insert as user testAccounts;
        
        // Test count
        Test.startTest();
        Integer newCount = AccountService.getAccountCount();
        Test.stopTest();
        
        Assert.areEqual(initialCount + 5, newCount, 'Account count should increase by 5');
    }
}
