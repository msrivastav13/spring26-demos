/**
 * ApexCursorDemoTest - Test class for Apex Cursor demonstrations
 * 
 * Tests cursor functionality including:
 * - Basic cursor operations
 * - Cursor with bind variables
 * - Pagination cursor
 * - Queueable cursor processing
 * - Cursor limits monitoring
 */
@IsTest
private class ApexCursorDemoTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test accounts with various industries and revenues
        List<Account> accounts = new List<Account>();
        
        // Technology accounts
        for (Integer i = 1; i <= 50; i++) {
            accounts.add(new Account(
                Name = 'Tech Company ' + String.valueOf(i).leftPad(3, '0'),
                Industry = 'Technology',
                AnnualRevenue = 1000000 * i,
                Description = 'Test technology company ' + i
            ));
        }
        
        // Healthcare accounts
        for (Integer i = 1; i <= 30; i++) {
            accounts.add(new Account(
                Name = 'Healthcare Corp ' + String.valueOf(i).leftPad(3, '0'),
                Industry = 'Healthcare',
                AnnualRevenue = 500000 * i
            ));
        }
        
        // Finance accounts
        for (Integer i = 1; i <= 20; i++) {
            accounts.add(new Account(
                Name = 'Finance Inc ' + String.valueOf(i).leftPad(3, '0'),
                Industry = 'Finance',
                AnnualRevenue = 2000000 * i
            ));
        }
        
        insert accounts;
        
        // Create test contacts linked to accounts
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + acc.Name,
                AccountId = acc.Id,
                Email = 'test@' + acc.Name.replaceAll(' ', '').toLowerCase() + '.com'
            ));
        }
        insert contacts;
    }
    
    // ============================================
    // BASIC CURSOR TESTS
    // ============================================
    
    @IsTest
    static void testBasicCursorDemo() {
        Test.startTest();
        
        ApexCursorDemo.CursorResult result = ApexCursorDemo.basicCursorDemo();
        
        Test.stopTest();
        
        // Verify results
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areEqual(100, result.totalRecords, 'Should have 100 total records');
        Assert.areEqual(10, result.records.size(), 'First batch should have 10 records');
        Assert.areNotEqual(null, result.message, 'Message should not be null');
    }
    
    @IsTest
    static void testCursorWithBindsDemo() {
        Test.startTest();
        
        List<Account> techAccounts = ApexCursorDemo.cursorWithBindsDemo('Technology', 5000000);
        
        Test.stopTest();
        
        // Verify all returned accounts are Technology industry with revenue >= 5M
        Assert.isTrue(!techAccounts.isEmpty(), 'Should return some accounts');
        for (Account acc : techAccounts) {
            Assert.areEqual('Technology', acc.Industry, 'All accounts should be Technology');
            Assert.isTrue(acc.AnnualRevenue >= 5000000, 'All accounts should have revenue >= 5M');
        }
    }
    
    @IsTest
    static void testCursorWithBindsDemoNoResults() {
        Test.startTest();
        
        // Query with industry that won't match any records
        // The cursorWithBindsDemo method now checks for empty results before fetching
        List<Account> results = ApexCursorDemo.cursorWithBindsDemo('NonExistentIndustry12345', 0);
        
        Test.stopTest();
        
        Assert.areEqual(0, results.size(), 'Should return no accounts');
    }
    
    // ============================================
    // PAGINATION CURSOR TESTS
    // ============================================
    
    @IsTest
    static void testCreatePaginationCursor() {
        Test.startTest();
        
        ApexCursorDemo.PaginationResult result = ApexCursorDemo.createPaginationCursor(10);
        
        Test.stopTest();
        
        // Verify pagination result
        Assert.areNotEqual(null, result, 'Result should not be null');
        Assert.areNotEqual(null, result.cursor, 'Cursor should not be null');
        Assert.areEqual(10, result.records.size(), 'First page should have 10 records');
        Assert.areEqual(1, result.currentPage, 'Should be on page 1');
        Assert.areEqual(10, result.totalPages, 'Should have 10 total pages (100 records / 10 per page)');
        Assert.areEqual(100, result.totalRecords, 'Should have 100 total records');
        Assert.areEqual(10, result.pageSize, 'Page size should be 10');
    }
    
    @IsTest
    static void testFetchPage() {
        // First create the pagination cursor
        ApexCursorDemo.PaginationResult initialResult = ApexCursorDemo.createPaginationCursor(10);
        
        Test.startTest();
        
        // Fetch page 5 (pass pageSize as third parameter)
        ApexCursorDemo.PaginationResult page5Result = ApexCursorDemo.fetchPage(
            initialResult.cursor, 
            5,
            10
        );
        
        Test.stopTest();
        
        // Verify page 5 result
        Assert.areEqual(5, page5Result.currentPage, 'Should be on page 5');
        Assert.areEqual(10, page5Result.records.size(), 'Page should have 10 records');
        
        // Verify we got different records than page 1
        Set<Id> page1Ids = new Set<Id>();
        for (Account acc : initialResult.records) {
            page1Ids.add(acc.Id);
        }
        
        for (Account acc : page5Result.records) {
            Assert.isTrue(!page1Ids.contains(acc.Id), 'Page 5 should have different records than page 1');
        }
    }
    
    @IsTest
    static void testPaginationCursorNavigateBackwards() {
        // Create cursor with page size 10
        ApexCursorDemo.PaginationResult page1 = ApexCursorDemo.createPaginationCursor(10);
        
        Test.startTest();
        
        // Navigate forward to page 3
        ApexCursorDemo.PaginationResult page3 = ApexCursorDemo.fetchPage(page1.cursor, 3, 10);
        
        // Navigate backwards to page 2
        ApexCursorDemo.PaginationResult page2 = ApexCursorDemo.fetchPage(page3.cursor, 2, 10);
        
        Test.stopTest();
        
        Assert.areEqual(2, page2.currentPage, 'Should be on page 2');
        Assert.areEqual(10, page2.records.size(), 'Page 2 should have 10 records');
    }
    
    // ============================================
    // CURSOR LIMITS TESTS
    // ============================================
    
    @IsTest
    static void testGetCursorLimits() {
        Test.startTest();
        
        ApexCursorDemo.CursorLimitsInfo limits = ApexCursorDemo.getCursorLimits();
        
        Test.stopTest();
        
        // Verify limits object is populated
        Assert.areNotEqual(null, limits, 'Limits should not be null');
        Assert.isTrue(limits.cursorsLimit > 0, 'Cursor limit should be greater than 0');
        Assert.isTrue(limits.cursorRowsLimit > 0, 'Cursor rows limit should be greater than 0');
        Assert.isTrue(limits.fetchCallsLimit > 0, 'Fetch calls limit should be greater than 0');
    }
    
    @IsTest
    static void testLogCursorLimits() {
        Test.startTest();
        
        // This should complete without error and log cursor limits
        ApexCursorDemo.logCursorLimits();
        
        Test.stopTest();
        
        // If we get here, the method completed successfully
        Assert.isTrue(true, 'logCursorLimits should complete without error');
    }
    
    // ============================================
    // QUEUEABLE CURSOR PROCESSING TESTS
    // ============================================
    
    @IsTest
    static void testCursorProcessingQueueable() {
        Test.startTest();
        
        // Create and enqueue the processing job
        CursorProcessingQueueable job = new CursorProcessingQueueable(
            'SELECT Id, Name FROM Account ORDER BY Name',
            25 // Process 25 records per chunk
        );
        
        Id jobId = System.enqueueJob(job);
        
        Test.stopTest();
        
        // Verify job was created
        Assert.areNotEqual(null, jobId, 'Job ID should not be null');
    }
    
    @IsTest
    static void testProcessInactiveContacts() {
        Test.startTest();
        
        // Process contacts inactive for 30 days
        Id jobId = CursorProcessingQueueable.processInactiveContacts(30);
        
        Test.stopTest();
        
        Assert.areNotEqual(null, jobId, 'Job ID should not be null');
    }
    
    @IsTest
    static void testProcessAccountsByIndustry() {
        Test.startTest();
        
        // Process all Technology accounts
        Id jobId = CursorProcessingQueueable.processAccountsByIndustry('Technology');
        
        Test.stopTest();
        
        Assert.areNotEqual(null, jobId, 'Job ID should not be null');
    }
    
    @IsTest
    static void testCursorProcessingWithCustomProcessor() {
        Test.startTest();
        
        // Create custom processor
        CursorProcessingQueueable.RecordProcessor processor = 
            new CursorProcessingQueueable.AccountDedupeProcessor();
        
        // Create job with custom processor
        CursorProcessingQueueable job = new CursorProcessingQueueable(
            'SELECT Id, Name FROM Account ORDER BY Name',
            50,
            processor
        );
        
        Id jobId = System.enqueueJob(job);
        
        Test.stopTest();
        
        Assert.areNotEqual(null, jobId, 'Job ID should not be null');
    }
    
    @IsTest
    static void testGetStatus() {
        CursorProcessingQueueable job = new CursorProcessingQueueable(
            'SELECT Id, Name FROM Account ORDER BY Name',
            25
        );
        
        Test.startTest();
        
        Map<String, Object> status = job.getStatus();
        
        Test.stopTest();
        
        // Verify status map
        Assert.areEqual(0, status.get('position'), 'Position should start at 0');
        Assert.areEqual(100, status.get('totalRecords'), 'Should have 100 total records');
        Assert.areEqual(0, status.get('totalProcessed'), 'Should have 0 processed initially');
        Assert.areEqual(25, status.get('chunkSize'), 'Chunk size should be 25');
    }
    
    // ============================================
    // EDGE CASE TESTS
    // ============================================
    
    @IsTest
    static void testCursorWithEmptyResults() {
        Test.startTest();
        
        // Query that returns no results
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id FROM Account WHERE Name = \'NonExistentAccount12345\''
        );
        
        Integer totalRecords = cursor.getNumRecords();
        
        // Cursors throw InvalidParameterValueException when fetching from empty result
        // Best practice: check getNumRecords() before fetching
        List<Account> results = new List<Account>();
        if (totalRecords > 0) {
            results = cursor.fetch(0, 10);
        }
        
        Test.stopTest();
        
        Assert.areEqual(0, totalRecords, 'Should have 0 total records');
        Assert.areEqual(0, results.size(), 'Should return empty list');
    }
    
    @IsTest
    static void testCursorFetchBeyondResultsThrowsException() {
        Test.startTest();
        
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id, Name FROM Account ORDER BY Name LIMIT 5'
        );
        
        // Apex cursors throw InvalidParameterValueException when fetching beyond bounds
        Boolean exceptionThrown = false;
        try {
            List<Account> results = cursor.fetch(10, 10);
        } catch (System.InvalidParameterValueException e) {
            exceptionThrown = true;
            Assert.isTrue(e.getMessage().contains('Fetch beyond bound'), 
                'Exception should indicate fetch beyond bound');
        }
        
        Test.stopTest();
        
        Assert.isTrue(exceptionThrown, 'Should throw exception when fetching beyond results');
    }
    
    @IsTest
    static void testCursorSafeFetch() {
        Test.startTest();
        
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id, Name FROM Account ORDER BY Name LIMIT 7'
        );
        
        Integer totalRecords = cursor.getNumRecords();
        Integer position = 5;
        Integer requestedCount = 10;
        
        // Safe fetch: calculate actual records to fetch
        Integer actualCount = Math.min(requestedCount, totalRecords - position);
        List<Account> results = cursor.fetch(position, actualCount);
        
        Test.stopTest();
        
        Assert.areEqual(2, results.size(), 'Should return only 2 records (7-5)');
    }
    
    @IsTest
    static void testCursorBidirectionalTraversal() {
        Test.startTest();
        
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id, Name FROM Account ORDER BY Name'
        );
        
        // Fetch first batch
        List<Account> batch1 = cursor.fetch(0, 10);
        
        // Jump forward
        List<Account> batch5 = cursor.fetch(40, 10);
        
        // Jump back to first batch
        List<Account> batch1Again = cursor.fetch(0, 10);
        
        Test.stopTest();
        
        // Verify bidirectional traversal works
        Assert.areEqual(batch1.size(), batch1Again.size(), 'Same batch should have same size');
        Assert.areEqual(batch1[0].Id, batch1Again[0].Id, 'Should get same first record');
        
        // Verify batch5 is different
        Assert.areNotEqual(batch1[0].Id, batch5[0].Id, 'Different batches should have different records');
    }
}

