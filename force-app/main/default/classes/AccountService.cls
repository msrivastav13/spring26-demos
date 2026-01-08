/**
 * AccountService - A service class for Account-related operations
 * 
 * This class is part of the RunRelevantTests demo.
 * When this class is modified and deployed with RunRelevantTests,
 * only tests annotated with @IsTest(testFor='ApexClass:AccountService')
 * and @IsTest(critical=true) will run automatically.
 * 
 * All DML and SOQL operations run in USER_MODE for enhanced security.
 */
public with sharing class AccountService {
    
    /**
     * Creates a new Account with the given name
     * @param accountName The name for the new Account
     * @return The newly created Account record
     */
    public static Account createAccount(String accountName) {
        if (String.isBlank(accountName)) {
            throw new AccountServiceException('Account name cannot be blank');
        }
        
        Account acc = new Account(
            Name = accountName,
            Description = 'Created by AccountService'
        );
        insert as user acc;
        return acc;
    }
    
    /**
     * Retrieves an Account by Id
     * @param accountId The Id of the Account to retrieve
     * @return The Account record
     */
    public static Account getAccountById(Id accountId) {
        return [SELECT Id, Name, Description, Industry, AnnualRevenue 
                FROM Account 
                WHERE Id = :accountId 
                WITH USER_MODE
                LIMIT 1];
    }
    
    /**
     * Updates the industry for a given Account
     * @param accountId The Id of the Account to update
     * @param industry The new industry value
     * @return The updated Account record
     */
    public static Account updateAccountIndustry(Id accountId, String industry) {
        Account acc = new Account(
            Id = accountId,
            Industry = industry
        );
        update as user acc;
        return getAccountById(accountId);
    }
    
    /**
     * Gets the total count of Accounts in the org
     * @return The number of Account records
     */
    public static Integer getAccountCount() {
        return [SELECT COUNT() FROM Account WITH USER_MODE];
    }
    
    /**
     * Custom exception for AccountService errors
     */
    public class AccountServiceException extends Exception {}
}
