/**
 * ApexCursorDemo - Demonstrates the use of Apex Cursors (GA in API v66.0)
 * 
 * Apex cursors allow you to work with large SOQL query result sets in manageable parts.
 * This class demonstrates:
 * - Standard cursors with Database.getCursor()
 * - Cursors with bind variables using Database.getCursorWithBinds()
 * - Pagination cursors for UI elements
 * - Cursor usage in Queueable Apex for processing large datasets
 * - Cursor limit monitoring
 * 
 * Key Benefits over Batch Apex:
 * - Flexibility in how many records are processed per transaction
 * - Better utilization of async Apex limits
 * - Bidirectional traversal (forward and backward)
 * - Maximum 50 million rows per cursor
 */
public with sharing class ApexCursorDemo {

    // ============================================
    // BASIC CURSOR OPERATIONS
    // ============================================

    /**
     * Demonstrates basic cursor creation and fetching
     * @return CursorResult containing fetched records and metadata
     */
    public static CursorResult basicCursorDemo() {
        // Create a cursor from a SOQL query
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id, Name, Industry, AnnualRevenue FROM Account ORDER BY Name'
        );
        
        // Get total number of records in the result set
        Integer totalRecords = cursor.getNumRecords();
        
        // Fetch first batch of 10 records starting at position 0
        List<Account> firstBatch = cursor.fetch(0, 10);
        
        // Fetch second batch of 10 records starting at position 10
        List<Account> secondBatch = cursor.fetch(10, 10);
        
        // Navigate backwards - fetch records 5-14 (overlapping with first batch)
        List<Account> overlappingBatch = cursor.fetch(5, 10);
        
        return new CursorResult(
            totalRecords,
            firstBatch,
            'Fetched ' + firstBatch.size() + ' records in first batch, ' +
            secondBatch.size() + ' in second batch'
        );
    }

    /**
     * Demonstrates cursor with bind variables for dynamic queries
     * @param industry The industry to filter by
     * @param minRevenue Minimum annual revenue threshold
     * @return List of matching accounts
     */
    public static List<Account> cursorWithBindsDemo(String industry, Decimal minRevenue) {
        // Create bind variable map
        Map<String, Object> bindVars = new Map<String, Object>{
            'industryFilter' => industry,
            'revenueThreshold' => minRevenue
        };
        
        // Create cursor with bind variables
        Database.Cursor cursor = Database.getCursorWithBinds(
            'SELECT Id, Name, Industry, AnnualRevenue FROM Account ' +
            'WHERE Industry = :industryFilter AND AnnualRevenue >= :revenueThreshold ' +
            'ORDER BY AnnualRevenue DESC',
            bindVars,
            AccessLevel.USER_MODE
        );
        
        Integer totalRecords = cursor.getNumRecords();
        System.debug('Total matching records: ' + totalRecords);
        
        // Return empty list if no records found (cursor throws exception if fetching from empty result)
        if (totalRecords == 0) {
            return new List<Account>();
        }
        
        // Fetch up to 100 records
        return cursor.fetch(0, Math.min(totalRecords, 100));
    }

    // ============================================
    // PAGINATION USING STANDARD CURSOR FOR UI
    // ============================================

    /**
     * Creates a cursor-based pagination result for UI display
     * Uses standard cursor with manual page calculations
     * @param pageSize Number of records per page
     * @return PaginationResult containing the cursor and first page data
     */
    @AuraEnabled(cacheable=false)
    public static PaginationResult createPaginationCursor(Integer pageSize) {
        // Create a standard cursor for pagination
        Database.Cursor cursor = Database.getCursor(
            'SELECT Id, Name, Industry, Type, Phone, Website FROM Account ORDER BY Name'
        );
        
        // Fetch the first page (position 0, count = pageSize)
        List<Account> firstPage = cursor.fetch(0, pageSize);
        
        // Get total record count
        Integer totalRecords = cursor.getNumRecords();
        Integer totalPages = (Integer)Math.ceil((Decimal)totalRecords / pageSize);
        
        return new PaginationResult(
            cursor,
            firstPage,
            1,
            totalPages,
            totalRecords,
            pageSize
        );
    }

    /**
     * Fetches a specific page from an existing cursor
     * @param cursor The cursor (serialized from client)
     * @param pageNumber The page number to fetch (1-based)
     * @param pageSize Number of records per page
     * @return PaginationResult with the requested page data
     */
    @AuraEnabled
    public static PaginationResult fetchPage(
        Database.Cursor cursor, 
        Integer pageNumber,
        Integer pageSize
    ) {
        // Calculate offset from page number (1-based)
        Integer offset = (pageNumber - 1) * pageSize;
        
        List<Account> pageData = cursor.fetch(offset, pageSize);
        Integer totalRecords = cursor.getNumRecords();
        Integer totalPages = (Integer)Math.ceil((Decimal)totalRecords / pageSize);
        
        return new PaginationResult(
            cursor,
            pageData,
            pageNumber,
            totalPages,
            totalRecords,
            pageSize
        );
    }

    // ============================================
    // CURSOR LIMITS AND MONITORING
    // ============================================

    /**
     * Returns current cursor usage and limits
     * @return CursorLimitsInfo containing all cursor-related limits
     */
    public static CursorLimitsInfo getCursorLimits() {
        return new CursorLimitsInfo(
            Limits.getApexCursors(),
            Limits.getLimitApexCursors(),
            Limits.getApexCursorRows(),
            Limits.getLimitApexCursorRows(),
            Limits.getFetchCallsOnApexCursor(),
            Limits.getLimitFetchCallsOnApexCursor(),
            Limits.getApexPaginationCursors(),
            Limits.getLimitApexPaginationCursors(),
            Limits.getApexPaginationCursorRows(),
            Limits.getLimitApexPaginationCursorRows()
        );
    }

    /**
     * Logs current cursor limits to debug log
     */
    public static void logCursorLimits() {
        CursorLimitsInfo limits = getCursorLimits();
        System.debug('=== Apex Cursor Limits ===');
        System.debug('Standard Cursors: ' + limits.cursorsUsed + ' / ' + limits.cursorsLimit);
        System.debug('Cursor Rows: ' + limits.cursorRowsUsed + ' / ' + limits.cursorRowsLimit);
        System.debug('Fetch Calls: ' + limits.fetchCallsUsed + ' / ' + limits.fetchCallsLimit);
        System.debug('Pagination Cursors: ' + limits.paginationCursorsUsed + ' / ' + limits.paginationCursorsLimit);
        System.debug('Pagination Cursor Rows: ' + limits.paginationRowsUsed + ' / ' + limits.paginationRowsLimit);
    }

    // ============================================
    // HELPER CLASSES
    // ============================================

    /**
     * Wrapper class for cursor results
     */
    public class CursorResult {
        @AuraEnabled public Integer totalRecords { get; set; }
        @AuraEnabled public List<Account> records { get; set; }
        @AuraEnabled public String message { get; set; }
        
        public CursorResult(Integer totalRecords, List<Account> records, String message) {
            this.totalRecords = totalRecords;
            this.records = records;
            this.message = message;
        }
    }

    /**
     * Wrapper class for pagination results
     * Supports AuraEnabled serialization for LWC
     */
    public class PaginationResult {
        @AuraEnabled public Database.Cursor cursor { get; set; }
        @AuraEnabled public List<Account> records { get; set; }
        @AuraEnabled public Integer currentPage { get; set; }
        @AuraEnabled public Integer totalPages { get; set; }
        @AuraEnabled public Integer totalRecords { get; set; }
        @AuraEnabled public Integer pageSize { get; set; }
        
        public PaginationResult(
            Database.Cursor cursor,
            List<Account> records,
            Integer currentPage,
            Integer totalPages,
            Integer totalRecords,
            Integer pageSize
        ) {
            this.cursor = cursor;
            this.records = records;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalRecords = totalRecords;
            this.pageSize = pageSize;
        }
    }

    /**
     * Wrapper class for cursor limits information
     */
    public class CursorLimitsInfo {
        @AuraEnabled public Integer cursorsUsed { get; set; }
        @AuraEnabled public Integer cursorsLimit { get; set; }
        @AuraEnabled public Integer cursorRowsUsed { get; set; }
        @AuraEnabled public Integer cursorRowsLimit { get; set; }
        @AuraEnabled public Integer fetchCallsUsed { get; set; }
        @AuraEnabled public Integer fetchCallsLimit { get; set; }
        @AuraEnabled public Integer paginationCursorsUsed { get; set; }
        @AuraEnabled public Integer paginationCursorsLimit { get; set; }
        @AuraEnabled public Integer paginationRowsUsed { get; set; }
        @AuraEnabled public Integer paginationRowsLimit { get; set; }
        
        public CursorLimitsInfo(
            Integer cursorsUsed, Integer cursorsLimit,
            Integer cursorRowsUsed, Integer cursorRowsLimit,
            Integer fetchCallsUsed, Integer fetchCallsLimit,
            Integer paginationCursorsUsed, Integer paginationCursorsLimit,
            Integer paginationRowsUsed, Integer paginationRowsLimit
        ) {
            this.cursorsUsed = cursorsUsed;
            this.cursorsLimit = cursorsLimit;
            this.cursorRowsUsed = cursorRowsUsed;
            this.cursorRowsLimit = cursorRowsLimit;
            this.fetchCallsUsed = fetchCallsUsed;
            this.fetchCallsLimit = fetchCallsLimit;
            this.paginationCursorsUsed = paginationCursorsUsed;
            this.paginationCursorsLimit = paginationCursorsLimit;
            this.paginationRowsUsed = paginationRowsUsed;
            this.paginationRowsLimit = paginationRowsLimit;
        }
    }
}

