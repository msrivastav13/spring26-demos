/**
 * UtilityHelperTest - Test class for UtilityHelper
 * 
 * RUNRELEVANTTESTS DEMO: Regular Test Class (No Special Annotation)
 * 
 * This is a standard test class WITHOUT any special RunRelevantTests annotations.
 * When deploying with the RunRelevantTests test level:
 * - This test class will run based on the automatic dependency analysis
 * - If UtilityHelper.cls is in the deployment payload, this test may run
 * - The engine determines relevance based on code references and dependencies
 * 
 * Compare this with:
 * - @IsTest(testFor='...') - Explicitly declares which components trigger the test
 * - @IsTest(critical=true) - Always runs regardless of payload
 * 
 * For most test classes, the automatic dependency analysis is sufficient.
 * Use explicit annotations when you need guaranteed behavior.
 */
@IsTest
private class UtilityHelperTest {
    
    @IsTest
    static void testValidateNotBlank_ValidValue() {
        Test.startTest();
        // Should not throw exception
        UtilityHelper.validateNotBlank('Valid Value', 'Test Field');
        Test.stopTest();
        
        // If we reach here, the test passed
        Assert.isTrue(true, 'validateNotBlank should accept valid values');
    }
    
    @IsTest
    static void testValidateNotBlank_BlankValue() {
        Test.startTest();
        try {
            UtilityHelper.validateNotBlank('', 'Test Field');
            Assert.fail('Expected UtilityException to be thrown');
        } catch (UtilityHelper.UtilityException e) {
            Assert.isTrue(e.getMessage().contains('Test Field'), 'Exception should include field name');
            Assert.isTrue(e.getMessage().contains('blank'), 'Exception should mention blank');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testValidateNotBlank_NullValue() {
        Test.startTest();
        try {
            UtilityHelper.validateNotBlank(null, 'Required Field');
            Assert.fail('Expected UtilityException to be thrown');
        } catch (UtilityHelper.UtilityException e) {
            Assert.isTrue(e.getMessage().contains('Required Field'), 'Exception should include field name');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testFormatName_LowerCase() {
        Test.startTest();
        String result = UtilityHelper.formatName('john');
        Test.stopTest();
        
        Assert.areEqual('John', result, 'Name should be capitalized');
    }
    
    @IsTest
    static void testFormatName_UpperCase() {
        Test.startTest();
        String result = UtilityHelper.formatName('JOHN');
        Test.stopTest();
        
        Assert.areEqual('John', result, 'Name should be properly capitalized');
    }
    
    @IsTest
    static void testFormatName_MixedCase() {
        Test.startTest();
        String result = UtilityHelper.formatName('jOhN');
        Test.stopTest();
        
        Assert.areEqual('John', result, 'Name should be properly capitalized');
    }
    
    @IsTest
    static void testFormatName_WithSpaces() {
        Test.startTest();
        String result = UtilityHelper.formatName('  john  ');
        Test.stopTest();
        
        Assert.areEqual('John', result, 'Name should be trimmed and capitalized');
    }
    
    @IsTest
    static void testFormatName_Blank() {
        Test.startTest();
        String result = UtilityHelper.formatName('');
        Test.stopTest();
        
        Assert.areEqual('', result, 'Blank string should return blank');
    }
    
    @IsTest
    static void testFormatName_Null() {
        Test.startTest();
        String result = UtilityHelper.formatName(null);
        Test.stopTest();
        
        Assert.isNull(result, 'Null should return null');
    }
    
    @IsTest
    static void testGenerateReference() {
        Test.startTest();
        String ref1 = UtilityHelper.generateReference('ACC');
        String ref2 = UtilityHelper.generateReference('ACC');
        String ref3 = UtilityHelper.generateReference('CON');
        Test.stopTest();
        
        Assert.isTrue(ref1.startsWith('ACC-'), 'Reference should start with prefix');
        Assert.isTrue(ref3.startsWith('CON-'), 'Reference should start with prefix');
        Assert.areNotEqual(ref1, ref2, 'Each reference should be unique');
    }
    
    @IsTest
    static void testIsValidId_ValidAccountId() {
        Account acc = new Account(Name = 'Test Account');
        insert as user acc;
        
        Test.startTest();
        Boolean result = UtilityHelper.isValidId(acc.Id);
        Test.stopTest();
        
        Assert.isTrue(result, 'Valid Id should return true');
    }
    
    @IsTest
    static void testIsValidId_ValidIdString() {
        Account acc = new Account(Name = 'Test Account');
        insert as user acc;
        
        Test.startTest();
        Boolean result = UtilityHelper.isValidId(String.valueOf(acc.Id));
        Test.stopTest();
        
        Assert.isTrue(result, 'Valid Id string should return true');
    }
    
    @IsTest
    static void testIsValidId_InvalidString() {
        Test.startTest();
        Boolean result = UtilityHelper.isValidId('not-a-valid-id');
        Test.stopTest();
        
        Assert.isFalse(result, 'Invalid string should return false');
    }
    
    @IsTest
    static void testIsValidId_BlankString() {
        Test.startTest();
        Boolean result = UtilityHelper.isValidId('');
        Test.stopTest();
        
        Assert.isFalse(result, 'Blank string should return false');
    }
    
    @IsTest
    static void testIsValidId_NullString() {
        Test.startTest();
        Boolean result = UtilityHelper.isValidId(null);
        Test.stopTest();
        
        Assert.isFalse(result, 'Null should return false');
    }
}
