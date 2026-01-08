/**
 * ContactService - A service class for Contact-related operations
 * 
 * This class is part of the RunRelevantTests demo.
 * When this class is modified and deployed with RunRelevantTests,
 * only tests annotated with @IsTest(testFor='ApexClass:ContactService')
 * and @IsTest(critical=true) will run automatically.
 * 
 * All DML and SOQL operations run in USER_MODE for enhanced security.
 */
public with sharing class ContactService {
    
    /**
     * Creates a new Contact associated with an Account
     * @param firstName The first name of the Contact
     * @param lastName The last name of the Contact
     * @param accountId The Id of the parent Account
     * @return The newly created Contact record
     */
    public static Contact createContact(String firstName, String lastName, Id accountId) {
        if (String.isBlank(lastName)) {
            throw new ContactServiceException('Last name is required');
        }
        
        Contact con = new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = accountId,
            Description = 'Created by ContactService'
        );
        insert as user con;
        return con;
    }
    
    /**
     * Retrieves a Contact by Id
     * @param contactId The Id of the Contact to retrieve
     * @return The Contact record
     */
    public static Contact getContactById(Id contactId) {
        return [SELECT Id, FirstName, LastName, Email, AccountId, Account.Name 
                FROM Contact 
                WHERE Id = :contactId 
                WITH USER_MODE
                LIMIT 1];
    }
    
    /**
     * Gets all Contacts for a given Account
     * @param accountId The Id of the Account
     * @return List of Contact records
     */
    public static List<Contact> getContactsByAccountId(Id accountId) {
        return [SELECT Id, FirstName, LastName, Email 
                FROM Contact 
                WHERE AccountId = :accountId 
                WITH USER_MODE
                ORDER BY LastName, FirstName];
    }
    
    /**
     * Updates the email for a given Contact
     * @param contactId The Id of the Contact to update
     * @param email The new email value
     * @return The updated Contact record
     */
    public static Contact updateContactEmail(Id contactId, String email) {
        Contact con = new Contact(
            Id = contactId,
            Email = email
        );
        update as user con;
        return getContactById(contactId);
    }
    
    /**
     * Custom exception for ContactService errors
     */
    public class ContactServiceException extends Exception {}
}
