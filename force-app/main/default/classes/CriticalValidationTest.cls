/**
 * CriticalValidationTest - Critical test class that ALWAYS runs
 * 
 * RUNRELEVANTTESTS DEMO: @IsTest(critical=true)
 * 
 * This test class uses the new @IsTest(critical=true) annotation.
 * When deploying with the RunRelevantTests test level:
 * - This test class will ALWAYS run, regardless of what's in the deployment payload
 * - Use this for tests that validate critical business logic or system integrity
 * - Use this for smoke tests that should run on every deployment
 * 
 * Best practices for critical tests:
 * - Keep them fast and focused
 * - Test critical business rules that must never break
 * - Test integration points that affect multiple components
 * - Validate core security and data integrity rules
 * 
 * Available in API version 66.0 and later.
 */
@IsTest(critical=true)
private class CriticalValidationTest {
    
    /**
     * Critical Test: Verify Account can be created
     * This is a smoke test to ensure basic DML operations work
     */
    @IsTest
    static void testCritical_AccountCreation() {
        Test.startTest();
        Account acc = new Account(Name = 'Critical Test Account');
        insert as user acc;
        Test.stopTest();
        
        Assert.isNotNull(acc.Id, 'CRITICAL: Account creation must work');
        
        Account retrieved = [SELECT Id, Name FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual('Critical Test Account', retrieved.Name, 'CRITICAL: Account data integrity');
    }
    
    /**
     * Critical Test: Verify Contact-Account relationship
     * Ensures master-detail relationships function correctly
     */
    @IsTest
    static void testCritical_ContactAccountRelationship() {
        Account acc = new Account(Name = 'Critical Parent Account');
        insert as user acc;
        
        Test.startTest();
        Contact con = new Contact(
            FirstName = 'Critical',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert as user con;
        Test.stopTest();
        
        Contact retrieved = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Id = :con.Id WITH USER_MODE];
        Assert.areEqual(acc.Id, retrieved.AccountId, 'CRITICAL: Contact-Account relationship must work');
        Assert.areEqual('Critical Parent Account', retrieved.Account.Name, 'CRITICAL: Relationship traversal must work');
    }
    
    /**
     * Critical Test: Verify bulk DML operations
     * Ensures the org can handle bulk operations correctly
     */
    @IsTest
    static void testCritical_BulkOperations() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(Name = 'Bulk Account ' + i));
        }
        
        Test.startTest();
        insert as user accounts;
        Test.stopTest();
        
        Integer insertedCount = [SELECT COUNT() FROM Account WHERE Name LIKE 'Bulk Account%' WITH USER_MODE];
        Assert.areEqual(200, insertedCount, 'CRITICAL: Bulk insert must work for 200 records');
    }
    
    /**
     * Critical Test: Verify SOQL query functionality
     * Ensures basic querying capabilities work
     */
    @IsTest
    static void testCritical_QueryFunctionality() {
        // Create test data with various field values in user mode
        Account acc1 = new Account(Name = 'Query Test Alpha', Industry = 'Technology');
        Account acc2 = new Account(Name = 'Query Test Beta', Industry = 'Finance');
        Account acc3 = new Account(Name = 'Query Test Gamma', Industry = 'Technology');
        insert as user new List<Account>{ acc1, acc2, acc3 };
        
        Test.startTest();
        // Test filtering with user mode
        List<Account> techAccounts = [SELECT Id, Name FROM Account 
                                       WHERE Industry = 'Technology' 
                                       AND Name LIKE 'Query Test%'
                                       WITH USER_MODE];
        
        // Test ordering with user mode
        List<Account> orderedAccounts = [SELECT Id, Name FROM Account 
                                          WHERE Name LIKE 'Query Test%' 
                                          WITH USER_MODE
                                          ORDER BY Name ASC];
        
        // Test aggregation with user mode
        Integer totalCount = [SELECT COUNT() FROM Account WHERE Name LIKE 'Query Test%' WITH USER_MODE];
        Test.stopTest();
        
        Assert.areEqual(2, techAccounts.size(), 'CRITICAL: WHERE filtering must work');
        Assert.areEqual('Query Test Alpha', orderedAccounts[0].Name, 'CRITICAL: ORDER BY must work');
        Assert.areEqual(3, totalCount, 'CRITICAL: COUNT aggregation must work');
    }
    
    /**
     * Critical Test: Verify exception handling
     * Ensures the platform properly handles exceptions
     */
    @IsTest
    static void testCritical_ExceptionHandling() {
        Test.startTest();
        Boolean exceptionCaught = false;
        try {
            // Attempt to insert Account without required Name field
            Account acc = new Account();
            insert as user acc;
        } catch (DmlException e) {
            exceptionCaught = true;
            Assert.isNotNull(e.getMessage(), 'CRITICAL: Exception should have a message');
        }
        Test.stopTest();
        
        Assert.isTrue(exceptionCaught, 'CRITICAL: DmlException must be thrown for invalid data');
    }
    
    /**
     * Critical Test: Verify governor limits are tracked
     * Ensures Limits class provides accurate information
     */
    @IsTest
    static void testCritical_GovernorLimits() {
        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        
        // Execute a query in user mode
        List<Account> accounts = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
        
        Integer queriesAfter = Limits.getQueries();
        Test.stopTest();
        
        Assert.areEqual(queriesBefore + 1, queriesAfter, 'CRITICAL: Limits.getQueries() must track queries');
        Assert.isTrue(Limits.getLimitQueries() > 0, 'CRITICAL: Query limits must be available');
    }
    
    /**
     * Critical Test: Verify update and delete operations in user mode
     * Ensures all DML operations respect user permissions
     */
    @IsTest
    static void testCritical_UpdateAndDelete() {
        // Create test data
        Account acc = new Account(Name = 'DML Test Account');
        insert as user acc;
        
        Test.startTest();
        // Update in user mode
        acc.Name = 'Updated DML Test Account';
        update as user acc;
        
        Account updatedAcc = [SELECT Name FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual('Updated DML Test Account', updatedAcc.Name, 'CRITICAL: Update must work in user mode');
        
        // Delete in user mode
        delete as user acc;
        
        List<Account> deletedAccounts = [SELECT Id FROM Account WHERE Id = :acc.Id WITH USER_MODE];
        Assert.areEqual(0, deletedAccounts.size(), 'CRITICAL: Delete must work in user mode');
        Test.stopTest();
    }
}
