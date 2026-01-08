/**
 * CursorProcessingQueueable - Demonstrates Apex Cursors with Queueable Apex
 * 
 * This class showcases how cursors combined with Queueable Apex provide a powerful
 * alternative to Batch Apex for processing large datasets.
 * 
 * Key Advantages over Batch Apex:
 * 1. Flexible batch sizes - adjust dynamically based on processing needs
 * 2. Better async Apex limit utilization
 * 3. Bidirectional traversal through result sets
 * 4. Can process up to 50 million rows per cursor
 * 5. Cursors can be serialized/deserialized for stateful processing
 * 
 * Usage Example:
 *   // Start processing all Contacts with recent activity
 *   CursorProcessingQueueable job = new CursorProcessingQueueable(
 *       'SELECT Id, Name, Email FROM Contact WHERE LastActivityDate = LAST_N_DAYS:30'
 *   );
 *   System.enqueueJob(job);
 */
public class CursorProcessingQueueable implements Queueable {
    
    // The cursor that holds our query result set
    private Database.Cursor locator;
    
    // Current position in the result set
    private Integer position;
    
    // Number of records to process per execution
    private Integer chunkSize;
    
    // Total records processed across all chunks
    private Integer totalProcessed;
    
    // Optional: custom processor interface for flexibility
    private RecordProcessor processor;
    
    // Default chunk size - can be adjusted based on processing complexity
    private static final Integer DEFAULT_CHUNK_SIZE = 200;
    
    /**
     * Constructor with SOQL query string
     * @param soqlQuery The SOQL query to execute
     */
    public CursorProcessingQueueable(String soqlQuery) {
        this(soqlQuery, DEFAULT_CHUNK_SIZE, null);
    }
    
    /**
     * Constructor with SOQL query and custom chunk size
     * @param soqlQuery The SOQL query to execute
     * @param chunkSize Number of records to process per execution
     */
    public CursorProcessingQueueable(String soqlQuery, Integer chunkSize) {
        this(soqlQuery, chunkSize, null);
    }
    
    /**
     * Full constructor with all options
     * @param soqlQuery The SOQL query to execute
     * @param chunkSize Number of records to process per execution
     * @param processor Custom record processor implementation
     */
    public CursorProcessingQueueable(String soqlQuery, Integer chunkSize, RecordProcessor processor) {
        this.locator = Database.getCursor(soqlQuery);
        this.position = 0;
        this.chunkSize = chunkSize;
        this.totalProcessed = 0;
        this.processor = processor;
        
        System.debug('CursorProcessingQueueable initialized');
        System.debug('Total records to process: ' + this.locator.getNumRecords());
        System.debug('Chunk size: ' + this.chunkSize);
    }
    
    /**
     * Private constructor for chaining (continues processing from current state)
     */
    private CursorProcessingQueueable(
        Database.Cursor locator, 
        Integer position, 
        Integer chunkSize,
        Integer totalProcessed,
        RecordProcessor processor
    ) {
        this.locator = locator;
        this.position = position;
        this.chunkSize = chunkSize;
        this.totalProcessed = totalProcessed;
        this.processor = processor;
    }
    
    /**
     * Queueable execute method - processes one chunk and chains if more remain
     */
    public void execute(QueueableContext ctx) {
        try {
            Integer totalRecords = locator.getNumRecords();
            
            // Check if there are records to process and we haven't reached the end
            if (totalRecords == 0 || position >= totalRecords) {
                System.debug('No more records to process. Total processed: ' + totalProcessed);
                return;
            }
            
            // Calculate how many records to fetch (don't exceed remaining records)
            Integer recordsToFetch = Math.min(chunkSize, totalRecords - position);
            
            // Fetch the next chunk of records
            List<SObject> scope = locator.fetch(position, recordsToFetch);
            
            if (scope.isEmpty()) {
                System.debug('No more records to process. Total processed: ' + totalProcessed);
                return;
            }
            
            // Update position for next chunk
            position += scope.size();
            totalProcessed += scope.size();
            
            // Process the records
            if (processor != null) {
                processor.processRecords(scope);
            } else {
                // Default processing - just log the records
                defaultProcessing(scope);
            }
            
            // Log progress
            Decimal percentComplete = totalRecords > 0 
                ? ((Decimal)position / totalRecords * 100).setScale(1) 
                : 100;
            System.debug('Progress: ' + position + ' / ' + totalRecords + ' (' + percentComplete + '%)');
            
            // Log cursor limits
            logCursorLimits();
            
            // Chain to next execution if more records remain
            // Skip chaining during tests to avoid max stack depth errors
            if (position < totalRecords && !Test.isRunningTest()) {
                // Check if we can enqueue another job
                if (Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                    System.enqueueJob(new CursorProcessingQueueable(
                        locator, position, chunkSize, totalProcessed, processor
                    ));
                } else {
                    System.debug('Queueable limit reached. Processed ' + totalProcessed + ' records so far.');
                }
            } else {
                System.debug('Processing complete! Total records processed: ' + totalProcessed);
            }
            
        } catch (System.TransientCursorException e) {
            // Transient errors can be retried (but not during tests)
            System.debug('Transient cursor error: ' + e.getMessage());
            if (!Test.isRunningTest()) {
                System.enqueueJob(new CursorProcessingQueueable(
                    locator, position, chunkSize, totalProcessed, processor
                ));
            }
        } catch (System.FatalCursorException e) {
            // Fatal errors cannot be retried
            System.debug('Fatal cursor error: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Default processing logic - override or use RecordProcessor interface
     */
    private void defaultProcessing(List<SObject> records) {
        System.debug('Processing ' + records.size() + ' records');
        
        // Example: Just log record names/IDs
        for (SObject record : records) {
            String recordName = record.get('Name') != null 
                ? String.valueOf(record.get('Name')) 
                : String.valueOf(record.get('Id'));
            System.debug('Processing record: ' + recordName);
        }
    }
    
    /**
     * Log current cursor limits for monitoring
     */
    private void logCursorLimits() {
        System.debug('=== Cursor Limits ===');
        System.debug('Cursors: ' + Limits.getApexCursors() + ' / ' + Limits.getLimitApexCursors());
        System.debug('Cursor Rows: ' + Limits.getApexCursorRows() + ' / ' + Limits.getLimitApexCursorRows());
        System.debug('Fetch Calls: ' + Limits.getFetchCallsOnApexCursor() + ' / ' + Limits.getLimitFetchCallsOnApexCursor());
    }
    
    // ============================================
    // RECORD PROCESSOR INTERFACE
    // ============================================
    
    /**
     * Interface for custom record processing logic
     * Implement this to define how records should be processed
     */
    public interface RecordProcessor {
        void processRecords(List<SObject> records);
    }
    
    // ============================================
    // EXAMPLE PROCESSOR IMPLEMENTATIONS
    // ============================================
    
    /**
     * Example processor that archives old contacts
     */
    public class ContactArchiveProcessor implements RecordProcessor {
        public void processRecords(List<SObject> records) {
            List<Contact> contacts = (List<Contact>)records;
            
            // Example: Update a custom field to mark as archived
            for (Contact c : contacts) {
                c.Description = 'Archived on ' + System.now().format();
            }
            
            if (!contacts.isEmpty()) {
                update contacts;
            }
            
            System.debug('Archived ' + contacts.size() + ' contacts');
        }
    }
    
    /**
     * Example processor that deduplicates accounts
     */
    public class AccountDedupeProcessor implements RecordProcessor {
        private Set<String> processedNames = new Set<String>();
        private List<Account> duplicates = new List<Account>();
        
        public void processRecords(List<SObject> records) {
            List<Account> accounts = (List<Account>)records;
            
            for (Account acc : accounts) {
                String normalizedName = acc.Name?.toLowerCase().trim();
                if (processedNames.contains(normalizedName)) {
                    duplicates.add(acc);
                    System.debug('Found duplicate: ' + acc.Name);
                } else {
                    processedNames.add(normalizedName);
                }
            }
            
            System.debug('Processed ' + accounts.size() + ' accounts, found ' + duplicates.size() + ' duplicates');
        }
    }
    
    // ============================================
    // STATIC HELPER METHODS
    // ============================================
    
    /**
     * Start processing contacts with no recent activity
     * @param daysInactive Number of days without activity
     * @return The job ID
     */
    public static Id processInactiveContacts(Integer daysInactive) {
        String query = 'SELECT Id, Name, Email, LastActivityDate FROM Contact ' +
                       'WHERE LastActivityDate < LAST_N_DAYS:' + daysInactive + ' ' +
                       'OR LastActivityDate = NULL ' +
                       'ORDER BY LastActivityDate NULLS FIRST';
        
        CursorProcessingQueueable job = new CursorProcessingQueueable(query, 100);
        return System.enqueueJob(job);
    }
    
    /**
     * Start processing all accounts in a specific industry
     * @param industry The industry to filter by
     * @return The job ID
     */
    public static Id processAccountsByIndustry(String industry) {
        Map<String, Object> bindVars = new Map<String, Object>{
            'industry' => industry
        };
        
        // Note: For bind variables, we'd need to use a different approach
        // since the cursor is created in the constructor
        String query = 'SELECT Id, Name, Industry, AnnualRevenue FROM Account ' +
                       'WHERE Industry = \'' + String.escapeSingleQuotes(industry) + '\' ' +
                       'ORDER BY AnnualRevenue DESC';
        
        CursorProcessingQueueable job = new CursorProcessingQueueable(query, 200);
        return System.enqueueJob(job);
    }
    
    /**
     * Get the current processing status
     * @return Status information
     */
    public Map<String, Object> getStatus() {
        return new Map<String, Object>{
            'position' => position,
            'totalRecords' => locator.getNumRecords(),
            'totalProcessed' => totalProcessed,
            'chunkSize' => chunkSize,
            'percentComplete' => locator.getNumRecords() > 0 
                ? ((Decimal)position / locator.getNumRecords() * 100).setScale(2) 
                : 100
        };
    }
}

