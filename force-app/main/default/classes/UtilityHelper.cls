/**
 * UtilityHelper - A utility class with common helper methods
 * 
 * This class is part of the RunRelevantTests demo.
 * This class demonstrates a shared utility that might be used
 * by multiple service classes.
 */
public with sharing class UtilityHelper {
    
    /**
     * Validates that a string is not blank
     * @param value The string to validate
     * @param fieldName The name of the field for error messages
     * @throws UtilityException if the value is blank
     */
    public static void validateNotBlank(String value, String fieldName) {
        if (String.isBlank(value)) {
            throw new UtilityException(fieldName + ' cannot be blank');
        }
    }
    
    /**
     * Formats a name with proper capitalization
     * @param name The name to format
     * @return The formatted name
     */
    public static String formatName(String name) {
        if (String.isBlank(name)) {
            return name;
        }
        return name.trim().toLowerCase().capitalize();
    }
    
    /**
     * Generates a unique reference number
     * @param prefix The prefix for the reference number
     * @return A unique reference string
     */
    public static String generateReference(String prefix) {
        String timestamp = String.valueOf(DateTime.now().getTime());
        String random = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        return prefix + '-' + timestamp.right(8) + '-' + random.right(4);
    }
    
    /**
     * Checks if a record Id is valid
     * @param recordId The Id to validate
     * @return True if the Id is valid, false otherwise
     */
    public static Boolean isValidId(String recordId) {
        if (String.isBlank(recordId)) {
            return false;
        }
        try {
            Id testId = Id.valueOf(recordId);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Custom exception for utility errors
     */
    public class UtilityException extends Exception {}
}

