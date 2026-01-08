/**
 * VisualforcePdfRenderingDemoTest - Test class for VisualforcePdfRenderingDemo
 * 
 * Tests the Spring '26 Blob.toPdf() feature with Visualforce PDF rendering service
 * 
 * @author Salesforce Spring '26 Demo
 * @since API Version 66.0
 */
@IsTest
private class VisualforcePdfRenderingDemoTest {
    
    // ============================================
    // MULTILINGUAL PDF TESTS
    // ============================================
    
    @IsTest
    static void testGenerateMultilingualShowcase() {
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateMultilingualShowcase();
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'PDF Blob should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'PDF Blob should have content');
    }
    
    @IsTest
    static void testMultilingualPdfContainsContent() {
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateMultilingualShowcase();
        Test.stopTest();
        
        // Verify the PDF was generated with meaningful content
        Assert.isTrue(pdfBlob.size() > 1000, 'Multilingual PDF should be substantial in size');
    }
    
    // ============================================
    // FONT SHOWCASE TESTS
    // ============================================
    
    @IsTest
    static void testGenerateFontShowcase() {
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateFontShowcase();
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Font showcase PDF should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Font showcase PDF should have content');
    }
    
    @IsTest
    static void testAvailableFontsConstant() {
        // Verify the AVAILABLE_FONTS constant is properly defined
        List<String> fonts = VisualforcePdfRenderingDemo.AVAILABLE_FONTS;
        
        Assert.areNotEqual(null, fonts, 'AVAILABLE_FONTS should not be null');
        Assert.isTrue(fonts.size() > 0, 'AVAILABLE_FONTS should contain fonts');
        Assert.isTrue(fonts.contains('sans-serif'), 'Should include new default: sans-serif');
        Assert.isTrue(fonts.contains('serif'), 'Should include old default: serif');
        Assert.isTrue(fonts.contains('Arial Unicode MS'), 'Should include Arial Unicode MS for multibyte');
    }
    
    // ============================================
    // CERTIFICATE GENERATION TESTS
    // ============================================
    
    @IsTest
    static void testGenerateCertificate() {
        String recipientName = 'John Doe';
        String courseName = 'Salesforce Administrator Certification';
        Date completionDate = Date.today();
        String instructorName = 'Jane Smith';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Certificate PDF should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Certificate PDF should have content');
    }
    
    @IsTest
    static void testGenerateCertificateWithMultibyteCharacters() {
        // Test with Japanese name
        String recipientName = '田中太郎';
        String courseName = 'Salesforce認定アドミニストレーター';
        Date completionDate = Date.today();
        String instructorName = '山田花子';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Certificate with multibyte should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Certificate with multibyte should have content');
    }
    
    @IsTest
    static void testGenerateCertificateWithChineseCharacters() {
        // Test with Chinese name
        String recipientName = '张伟';
        String courseName = 'Salesforce管理员认证';
        Date completionDate = Date.today();
        String instructorName = '李明';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Certificate with Chinese should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Certificate with Chinese should have content');
    }
    
    @IsTest
    static void testGenerateCertificateWithKoreanCharacters() {
        // Test with Korean name
        String recipientName = '김철수';
        String courseName = 'Salesforce 관리자 인증';
        Date completionDate = Date.today();
        String instructorName = '박영희';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Certificate with Korean should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Certificate with Korean should have content');
    }
    
    // ============================================
    // INVOICE GENERATION TESTS
    // ============================================
    
    @IsTest
    static void testGenerateInvoice() {
        String invoiceNumber = 'INV-2026-001';
        String customerName = 'Acme Corp';
        
        List<VisualforcePdfRenderingDemo.InvoiceLineItem> lineItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>{
            new VisualforcePdfRenderingDemo.InvoiceLineItem('Salesforce License - Enterprise', 10, 150.00),
            new VisualforcePdfRenderingDemo.InvoiceLineItem('Implementation Services', 40, 200.00),
            new VisualforcePdfRenderingDemo.InvoiceLineItem('Training Package', 1, 2500.00)
        };
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateInvoice(
            invoiceNumber,
            customerName,
            lineItems
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Invoice PDF should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Invoice PDF should have content');
    }
    
    @IsTest
    static void testGenerateInvoiceWithInternationalCustomer() {
        // Test with Japanese customer
        String invoiceNumber = 'INV-2026-002';
        String customerName = '株式会社サンプル';
        
        List<VisualforcePdfRenderingDemo.InvoiceLineItem> lineItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>{
            new VisualforcePdfRenderingDemo.InvoiceLineItem('Salesforceライセンス', 5, 18000.00),
            new VisualforcePdfRenderingDemo.InvoiceLineItem('導入支援サービス', 20, 15000.00)
        };
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateInvoice(
            invoiceNumber,
            customerName,
            lineItems
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Invoice with Japanese should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Invoice with Japanese should have content');
    }
    
    @IsTest
    static void testGenerateInvoiceEmptyLineItems() {
        String invoiceNumber = 'INV-2026-003';
        String customerName = 'Test Customer';
        
        List<VisualforcePdfRenderingDemo.InvoiceLineItem> lineItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>();
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateInvoice(
            invoiceNumber,
            customerName,
            lineItems
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Invoice with no items should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Invoice with no items should have content');
    }
    
    // ============================================
    // RENDERING COMPARISON TESTS
    // ============================================
    
    @IsTest
    static void testGenerateRenderingComparison() {
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateRenderingComparison();
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Comparison PDF should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Comparison PDF should have content');
    }
    
    // ============================================
    // QUICK DEMO TESTS
    // ============================================
    
    @IsTest
    static void testQuickDemo() {
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.quickDemo();
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Quick demo PDF should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Quick demo PDF should have content');
    }
    
    // ============================================
    // FILE SAVE TESTS
    // ============================================
    
    @IsTest
    static void testSavePdfToFiles() {
        String fileName = 'Test_Multilingual_Showcase';
        
        Test.startTest();
        Id contentVersionId = VisualforcePdfRenderingDemo.savePdfToFiles(fileName);
        Test.stopTest();
        
        Assert.areNotEqual(null, contentVersionId, 'ContentVersion Id should not be null');
        
        // Verify the ContentVersion was created correctly
        ContentVersion cv = [
            SELECT Id, Title, PathOnClient, VersionData, FileExtension 
            FROM ContentVersion 
            WHERE Id = :contentVersionId
        ];
        
        Assert.areEqual(fileName, cv.Title, 'Title should match');
        Assert.areEqual(fileName + '.pdf', cv.PathOnClient, 'PathOnClient should match');
        Assert.areNotEqual(null, cv.VersionData, 'VersionData should not be null');
        Assert.areEqual('pdf', cv.FileExtension, 'File extension should be pdf');
    }
    
    // ============================================
    // WRAPPER CLASS TESTS
    // ============================================
    
    @IsTest
    static void testInvoiceLineItemWrapper() {
        String description = 'Test Item';
        Integer quantity = 5;
        Decimal unitPrice = 100.00;
        
        VisualforcePdfRenderingDemo.InvoiceLineItem item = 
            new VisualforcePdfRenderingDemo.InvoiceLineItem(description, quantity, unitPrice);
        
        Assert.areEqual(description, item.description, 'Description should match');
        Assert.areEqual(quantity, item.quantity, 'Quantity should match');
        Assert.areEqual(unitPrice, item.unitPrice, 'Unit price should match');
    }
    
    @IsTest
    static void testPdfGenerationResultWrapper() {
        Boolean success = true;
        String message = 'PDF generated successfully';
        Id contentVersionId = null; // In real test, this would be a valid Id
        Integer fileSizeBytes = 12345;
        
        VisualforcePdfRenderingDemo.PdfGenerationResult result = 
            new VisualforcePdfRenderingDemo.PdfGenerationResult(success, message, contentVersionId, fileSizeBytes);
        
        Assert.areEqual(success, result.success, 'Success should match');
        Assert.areEqual(message, result.message, 'Message should match');
        Assert.areEqual(contentVersionId, result.contentVersionId, 'ContentVersionId should match');
        Assert.areEqual(fileSizeBytes, result.fileSizeBytes, 'FileSizeBytes should match');
    }
    
    // ============================================
    // SPECIAL CHARACTER HANDLING TESTS
    // ============================================
    
    @IsTest
    static void testSpecialCharacterEscaping() {
        // Test with special characters that need escaping
        String recipientName = 'O\'Brien & Partners';
        String courseName = 'Advanced <Apex> Development';
        Date completionDate = Date.today();
        String instructorName = 'Test "Instructor" Name';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'PDF with special characters should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'PDF with special characters should have content');
    }
    
    // ============================================
    // BULK PDF GENERATION TEST
    // ============================================
    
    @IsTest
    static void testBulkPdfGeneration() {
        // Test generating multiple PDFs in sequence
        Test.startTest();
        
        List<Blob> pdfs = new List<Blob>();
        
        // Generate different types of PDFs
        pdfs.add(VisualforcePdfRenderingDemo.quickDemo());
        pdfs.add(VisualforcePdfRenderingDemo.generateFontShowcase());
        pdfs.add(VisualforcePdfRenderingDemo.generateMultilingualShowcase());
        pdfs.add(VisualforcePdfRenderingDemo.generateRenderingComparison());
        
        Test.stopTest();
        
        // Verify all PDFs were generated
        for (Integer i = 0; i < pdfs.size(); i++) {
            Assert.areNotEqual(null, pdfs[i], 'PDF ' + i + ' should not be null');
            Assert.isTrue(pdfs[i].size() > 0, 'PDF ' + i + ' should have content');
        }
    }
    
    // ============================================
    // EDGE CASE TESTS
    // ============================================
    
    @IsTest
    static void testCertificateWithLongNames() {
        String recipientName = 'This Is A Very Long Recipient Name That Should Still Render Properly In The PDF Certificate Document';
        String courseName = 'This Is Also A Very Long Course Name That Tests The Rendering Capabilities Of The New Visualforce PDF Service';
        Date completionDate = Date.today();
        String instructorName = 'Professor Doctor Sir Lord Commander Of The Salesforce Certification Training Program';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'PDF with long names should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'PDF with long names should have content');
    }
    
    @IsTest
    static void testInvoiceWithManyLineItems() {
        String invoiceNumber = 'INV-2026-BULK';
        String customerName = 'Bulk Order Customer';
        
        List<VisualforcePdfRenderingDemo.InvoiceLineItem> lineItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>();
        
        // Add 20 line items
        for (Integer i = 1; i <= 20; i++) {
            lineItems.add(new VisualforcePdfRenderingDemo.InvoiceLineItem(
                'Line Item #' + i + ' - Product Description',
                i,
                (Decimal)(100 + (i * 10))
            ));
        }
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateInvoice(
            invoiceNumber,
            customerName,
            lineItems
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'Invoice with many items should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'Invoice with many items should have content');
    }
    
    // ============================================
    // MIXED LANGUAGE TESTS
    // ============================================
    
    @IsTest
    static void testMixedLanguageContent() {
        // Test certificate with mixed English and Japanese
        String recipientName = 'John Smith (ジョン・スミス)';
        String courseName = 'Salesforce Administrator (管理者)';
        Date completionDate = Date.today();
        String instructorName = 'Tanaka-sensei (田中先生)';
        
        Test.startTest();
        Blob pdfBlob = VisualforcePdfRenderingDemo.generateCertificate(
            recipientName, 
            courseName, 
            completionDate, 
            instructorName
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, pdfBlob, 'PDF with mixed languages should not be null');
        Assert.isTrue(pdfBlob.size() > 0, 'PDF with mixed languages should have content');
    }
}

