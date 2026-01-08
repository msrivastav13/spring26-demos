/**
 * PicklistValuesByRecordTypeDemo - Demonstrates the new ConnectApi.RecordUi.getPicklistValuesByRecordType() method
 * 
 * New in Spring '26 (API v62.0):
 * Get the values for all picklist fields for a particular record type using the new
 * ConnectApi.RecordUi.getPicklistValuesByRecordType(objectApiName, recordTypeId) method.
 * 
 * This class demonstrates:
 * - Getting all picklist values for a specific record type
 * - Handling dependent picklist hierarchies (e.g., Continent → Country → City)
 * - Building dynamic picklist options for UI components
 * - Comparing with the old approach (which required callouts)
 * 
 * Key Benefits:
 * - No callouts required - direct Apex access to record type specific picklist values
 * - Single request for all picklist values on an object
 * - Includes dependent picklist relationships
 * - Works with custom and standard picklist fields
 * 
 * Where: Available in Lightning Experience and Salesforce Classic in 
 *        Enterprise, Performance, Unlimited, and Developer editions.
 */
public with sharing class PicklistValuesByRecordTypeDemo {

    // ============================================
    // BASIC USAGE - GET ALL PICKLIST VALUES
    // ============================================

    /**
     * Gets all picklist values for a specific object and record type
     * This is the simplest usage of the new method
     * 
     * @param objectApiName The API name of the object (e.g., 'Account', 'Case', 'Custom_Object__c')
     * @param recordTypeId The Id of the record type
     * @return PicklistValuesResult containing all picklist field values
     */
    @AuraEnabled(cacheable=true)
    public static PicklistValuesResult getPicklistValues(String objectApiName, Id recordTypeId) {
        try {
            // Use the new ConnectApi method to get all picklist values for the record type
            ConnectApi.PicklistValuesCollection picklistCollection = 
                ConnectApi.RecordUi.getPicklistValuesByRecordType(objectApiName, recordTypeId);
            
            // Process the collection into a structured result
            return processPicklistCollection(picklistCollection, objectApiName);
            
        } catch (ConnectApi.ConnectApiException e) {
            throw new AuraHandledException('Error fetching picklist values: ' + e.getMessage());
        }
    }

    /**
     * Gets all picklist values for an object using the master record type
     * Useful when you want all possible picklist values regardless of record type
     * 
     * @param objectApiName The API name of the object
     * @return PicklistValuesResult containing all picklist field values
     */
    @AuraEnabled(cacheable=true)
    public static PicklistValuesResult getPicklistValuesForMasterRecordType(String objectApiName) {
        // Get the master record type Id for the object
        Id masterRecordTypeId = getMasterRecordTypeId(objectApiName);
        
        return getPicklistValues(objectApiName, masterRecordTypeId);
    }

    // ============================================
    // DEPENDENT PICKLIST HANDLING
    // ============================================

    /**
     * Demonstrates handling dependent picklist hierarchies
     * For example: Continent__c → Country__c → City__c
     * 
     * The new method returns all values with their dependencies in a single call,
     * eliminating the need for multiple callouts or complex describe calls.
     * 
     * @param objectApiName The API name of the object
     * @param recordTypeId The Id of the record type
     * @return DependentPicklistResult with full dependency tree
     */
    @AuraEnabled(cacheable=true)
    public static DependentPicklistResult getDependentPicklistTree(
        String objectApiName, 
        Id recordTypeId
    ) {
        try {
            ConnectApi.PicklistValuesCollection picklistCollection = 
                ConnectApi.RecordUi.getPicklistValuesByRecordType(objectApiName, recordTypeId);
            
            Map<String, DependentFieldInfo> dependentFields = new Map<String, DependentFieldInfo>();
            Map<String, List<PicklistOption>> allPicklistValues = new Map<String, List<PicklistOption>>();
            
            // Iterate through all picklist fields in the collection
            if (picklistCollection.picklistFieldValues != null) {
                for (String fieldName : picklistCollection.picklistFieldValues.keySet()) {
                    ConnectApi.PicklistValues fieldValues = picklistCollection.picklistFieldValues.get(fieldName);
                    
                    // Check if this field has a controlling field (is dependent)
                    if (fieldValues.controllerValues != null && !fieldValues.controllerValues.isEmpty()) {
                        // This is a dependent picklist
                        DependentFieldInfo depInfo = new DependentFieldInfo();
                        depInfo.fieldName = fieldName;
                        depInfo.controllingFieldName = getControllingFieldName(fieldValues);
                        depInfo.valuesByControllingValue = buildDependencyMap(fieldValues);
                        dependentFields.put(fieldName, depInfo);
                    }
                    
                    // Store all picklist options for this field
                    allPicklistValues.put(fieldName, extractPicklistOptions(fieldValues));
                }
            }
            
            return new DependentPicklistResult(allPicklistValues, dependentFields);
            
        } catch (ConnectApi.ConnectApiException e) {
            throw new AuraHandledException('Error fetching dependent picklist values: ' + e.getMessage());
        }
    }

    /**
     * Gets filtered dependent picklist values based on a controlling value
     * 
     * @param objectApiName The API name of the object
     * @param recordTypeId The Id of the record type
     * @param dependentFieldName The API name of the dependent field
     * @param controllingValue The selected value of the controlling field
     * @return List of valid picklist options for the dependent field
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getFilteredDependentValues(
        String objectApiName,
        Id recordTypeId,
        String dependentFieldName,
        String controllingValue
    ) {
        try {
            ConnectApi.PicklistValuesCollection picklistCollection = 
                ConnectApi.RecordUi.getPicklistValuesByRecordType(objectApiName, recordTypeId);
            
            List<PicklistOption> filteredOptions = new List<PicklistOption>();
            
            if (picklistCollection.picklistFieldValues != null && 
                picklistCollection.picklistFieldValues.containsKey(dependentFieldName)) {
                
                ConnectApi.PicklistValues fieldValues = 
                    picklistCollection.picklistFieldValues.get(dependentFieldName);
                
                // Get the index of the controlling value
                Integer controllerIndex = getControllerValueIndex(fieldValues, controllingValue);
                
                if (controllerIndex != null && fieldValues.values != null) {
                    // Get the default value for this field (if any)
                    String defaultVal = fieldValues.defaultValue != null ? fieldValues.defaultValue.value : null;
                    
                    // Filter values that are valid for this controlling value
                    for (ConnectApi.PicklistValue pv : fieldValues.values) {
                        if (isValidForController(pv, controllerIndex)) {
                            filteredOptions.add(new PicklistOption(
                                pv.label,
                                pv.value,
                                pv.value == defaultVal
                            ));
                        }
                    }
                }
            }
            
            return filteredOptions;
            
        } catch (ConnectApi.ConnectApiException e) {
            throw new AuraHandledException('Error filtering dependent values: ' + e.getMessage());
        }
    }

    // ============================================
    // PRACTICAL EXAMPLE: CASE RECORD TYPES
    // ============================================

    /**
     * Real-world example: Get Case picklist values by record type
     * Demonstrates typical usage for a support case form
     * 
     * @param recordTypeDeveloperName The developer name of the Case record type
     * @return CasePicklistValues containing all relevant picklist options
     */
    @AuraEnabled(cacheable=true)
    public static CasePicklistValues getCasePicklistsByRecordType(String recordTypeDeveloperName) {
        // Get the record type Id from the developer name
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Case' 
            AND DeveloperName = :recordTypeDeveloperName 
            LIMIT 1
        ];
        
        ConnectApi.PicklistValuesCollection picklistCollection = 
            ConnectApi.RecordUi.getPicklistValuesByRecordType('Case', rt.Id);
        
        CasePicklistValues result = new CasePicklistValues();
        result.recordTypeId = rt.Id;
        result.recordTypeName = recordTypeDeveloperName;
        
        // Extract specific picklist values for common Case fields
        if (picklistCollection.picklistFieldValues != null) {
            result.statusOptions = extractFieldOptions(picklistCollection, 'Status');
            result.priorityOptions = extractFieldOptions(picklistCollection, 'Priority');
            result.originOptions = extractFieldOptions(picklistCollection, 'Origin');
            result.typeOptions = extractFieldOptions(picklistCollection, 'Type');
            result.reasonOptions = extractFieldOptions(picklistCollection, 'Reason');
        }
        
        return result;
    }

    // ============================================
    // HELPER METHODS
    // ============================================

    /**
     * Gets the master record type Id for an object
     */
    private static Id getMasterRecordTypeId(String objectApiName) {
        Schema.DescribeSObjectResult describeResult = 
            Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        
        // Get the master record type
        Map<Id, Schema.RecordTypeInfo> recordTypes = describeResult.getRecordTypeInfosById();
        for (Schema.RecordTypeInfo rtInfo : recordTypes.values()) {
            if (rtInfo.isMaster()) {
                return rtInfo.getRecordTypeId();
            }
        }
        
        // If no master found, return the first available record type
        return new List<Id>(recordTypes.keySet())[0];
    }

    /**
     * Processes the picklist collection into a structured result
     */
    private static PicklistValuesResult processPicklistCollection(
        ConnectApi.PicklistValuesCollection collection,
        String objectApiName
    ) {
        PicklistValuesResult result = new PicklistValuesResult();
        result.objectApiName = objectApiName;
        result.picklistFields = new Map<String, List<PicklistOption>>();
        result.fieldMetadata = new Map<String, PicklistFieldMetadata>();
        
        if (collection.picklistFieldValues != null) {
            for (String fieldName : collection.picklistFieldValues.keySet()) {
                ConnectApi.PicklistValues fieldValues = collection.picklistFieldValues.get(fieldName);
                
                // Extract options
                result.picklistFields.put(fieldName, extractPicklistOptions(fieldValues));
                
                // Extract metadata
                PicklistFieldMetadata metadata = new PicklistFieldMetadata();
                metadata.fieldName = fieldName;
                metadata.defaultValue = getDefaultValue(fieldValues);
                metadata.isDependent = fieldValues.controllerValues != null && 
                                       !fieldValues.controllerValues.isEmpty();
                result.fieldMetadata.put(fieldName, metadata);
            }
        }
        
        return result;
    }

    /**
     * Extracts picklist options from field values
     */
    private static List<PicklistOption> extractPicklistOptions(ConnectApi.PicklistValues fieldValues) {
        List<PicklistOption> options = new List<PicklistOption>();
        
        if (fieldValues.values != null) {
            // Get the default value for comparison
            String defaultVal = fieldValues.defaultValue != null ? fieldValues.defaultValue.value : null;
            
            for (ConnectApi.PicklistValue pv : fieldValues.values) {
                options.add(new PicklistOption(
                    pv.label,
                    pv.value,
                    pv.value == defaultVal
                ));
            }
        }
        
        return options;
    }

    /**
     * Extracts picklist options for a specific field from the collection
     */
    private static List<PicklistOption> extractFieldOptions(
        ConnectApi.PicklistValuesCollection collection,
        String fieldName
    ) {
        if (collection.picklistFieldValues.containsKey(fieldName)) {
            return extractPicklistOptions(collection.picklistFieldValues.get(fieldName));
        }
        return new List<PicklistOption>();
    }

    /**
     * Gets the default value for a picklist field
     */
    private static String getDefaultValue(ConnectApi.PicklistValues fieldValues) {
        if (fieldValues.defaultValue != null) {
            return fieldValues.defaultValue.value;
        }
        return null;
    }

    /**
     * Gets the controlling field name for a dependent picklist
     */
    private static String getControllingFieldName(ConnectApi.PicklistValues fieldValues) {
        // The controlling field name is typically available in the URL reference
        // This is a simplified approach - actual implementation may vary
        if (fieldValues.url != null) {
            // Parse from URL or use describe call
            return 'ControllingField'; // Placeholder - actual field name from metadata
        }
        return null;
    }

    /**
     * Builds a dependency map for a dependent picklist field
     */
    private static Map<String, List<PicklistOption>> buildDependencyMap(
        ConnectApi.PicklistValues fieldValues
    ) {
        Map<String, List<PicklistOption>> dependencyMap = new Map<String, List<PicklistOption>>();
        
        if (fieldValues.controllerValues != null && fieldValues.values != null) {
            // Initialize lists for each controlling value
            for (String controllerValue : fieldValues.controllerValues.keySet()) {
                dependencyMap.put(controllerValue, new List<PicklistOption>());
            }
            
            // Get the default value for comparison
            String defaultVal = fieldValues.defaultValue != null ? fieldValues.defaultValue.value : null;
            
            // Map each picklist value to its valid controlling values
            for (ConnectApi.PicklistValue pv : fieldValues.values) {
                if (pv.validFor != null) {
                    for (String controllerValue : fieldValues.controllerValues.keySet()) {
                        Integer controllerIndex = fieldValues.controllerValues.get(controllerValue);
                        if (isValidForControllerIndex(pv.validFor, controllerIndex)) {
                            dependencyMap.get(controllerValue).add(new PicklistOption(
                                pv.label,
                                pv.value,
                                pv.value == defaultVal
                            ));
                        }
                    }
                }
            }
        }
        
        return dependencyMap;
    }

    /**
     * Gets the index of a controlling value
     */
    private static Integer getControllerValueIndex(
        ConnectApi.PicklistValues fieldValues,
        String controllingValue
    ) {
        if (fieldValues.controllerValues != null && 
            fieldValues.controllerValues.containsKey(controllingValue)) {
            return fieldValues.controllerValues.get(controllingValue);
        }
        return null;
    }

    /**
     * Checks if a picklist value is valid for a given controller index
     */
    private static Boolean isValidForController(ConnectApi.PicklistValue pv, Integer controllerIndex) {
        if (pv.validFor == null || pv.validFor.isEmpty()) {
            return true; // No restrictions
        }
        return pv.validFor.contains(controllerIndex);
    }

    /**
     * Checks if a picklist value is valid for a specific controller index
     * Uses the validFor list from the picklist value
     */
    private static Boolean isValidForControllerIndex(List<Integer> validFor, Integer controllerIndex) {
        if (validFor == null || validFor.isEmpty()) {
            return true;
        }
        return validFor.contains(controllerIndex);
    }

    // ============================================
    // WRAPPER CLASSES
    // ============================================

    /**
     * Main result wrapper for picklist values
     */
    public class PicklistValuesResult {
        @AuraEnabled public String objectApiName { get; set; }
        @AuraEnabled public Map<String, List<PicklistOption>> picklistFields { get; set; }
        @AuraEnabled public Map<String, PicklistFieldMetadata> fieldMetadata { get; set; }
    }

    /**
     * Individual picklist option
     */
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public Boolean isDefault { get; set; }
        
        public PicklistOption(String label, String value, Boolean isDefault) {
            this.label = label;
            this.value = value;
            this.isDefault = isDefault;
        }
    }

    /**
     * Metadata for a picklist field
     */
    public class PicklistFieldMetadata {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String defaultValue { get; set; }
        @AuraEnabled public Boolean isDependent { get; set; }
    }

    /**
     * Result wrapper for dependent picklist hierarchies
     */
    public class DependentPicklistResult {
        @AuraEnabled public Map<String, List<PicklistOption>> allValues { get; set; }
        @AuraEnabled public Map<String, DependentFieldInfo> dependentFields { get; set; }
        
        public DependentPicklistResult(
            Map<String, List<PicklistOption>> allValues,
            Map<String, DependentFieldInfo> dependentFields
        ) {
            this.allValues = allValues;
            this.dependentFields = dependentFields;
        }
    }

    /**
     * Information about a dependent picklist field
     */
    public class DependentFieldInfo {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String controllingFieldName { get; set; }
        @AuraEnabled public Map<String, List<PicklistOption>> valuesByControllingValue { get; set; }
    }

    /**
     * Case-specific picklist values wrapper
     */
    public class CasePicklistValues {
        @AuraEnabled public Id recordTypeId { get; set; }
        @AuraEnabled public String recordTypeName { get; set; }
        @AuraEnabled public List<PicklistOption> statusOptions { get; set; }
        @AuraEnabled public List<PicklistOption> priorityOptions { get; set; }
        @AuraEnabled public List<PicklistOption> originOptions { get; set; }
        @AuraEnabled public List<PicklistOption> typeOptions { get; set; }
        @AuraEnabled public List<PicklistOption> reasonOptions { get; set; }
    }
}

