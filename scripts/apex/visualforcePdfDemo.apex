/**
 * Anonymous Apex Script - Visualforce PDF Rendering Demo
 * 
 * Run this script in Developer Console or VS Code to test the Spring '26
 * Blob.toPdf() feature with Visualforce PDF rendering service.
 * 
 * The script will generate multiple PDFs and save them to Salesforce Files.
 */

System.debug('===========================================');
System.debug('🎉 Visualforce PDF Rendering Demo - Spring \'26');
System.debug('===========================================');

// ============================================
// 1. QUICK DEMO - Basic PDF Generation
// ============================================
System.debug('\n📄 Generating Quick Demo PDF...');
Blob quickPdf = VisualforcePdfRenderingDemo.quickDemo();
System.debug('✓ Quick demo PDF generated: ' + quickPdf.size() + ' bytes');

// ============================================
// 2. MULTILINGUAL SHOWCASE
// ============================================
System.debug('\n🌍 Generating Multilingual Showcase PDF...');
Id multilingualFileId = VisualforcePdfRenderingDemo.savePdfToFiles('Multilingual_Showcase_Spring26');
System.debug('✓ Multilingual showcase saved to Files. ContentVersion Id: ' + multilingualFileId);

// ============================================
// 3. FONT SHOWCASE
// ============================================
System.debug('\n🔤 Generating Font Showcase PDF...');
Blob fontPdf = VisualforcePdfRenderingDemo.generateFontShowcase();

// Save Font Showcase to Files
ContentVersion fontCv = new ContentVersion();
fontCv.Title = 'Font_Showcase_Spring26';
fontCv.PathOnClient = 'Font_Showcase_Spring26.pdf';
fontCv.VersionData = fontPdf;
fontCv.IsMajorVersion = true;
insert fontCv;
System.debug('✓ Font showcase saved to Files. ContentVersion Id: ' + fontCv.Id);

// ============================================
// 4. PROFESSIONAL CERTIFICATE
// ============================================
System.debug('\n🏆 Generating Professional Certificate PDF...');
Blob certPdf = VisualforcePdfRenderingDemo.generateCertificate(
    'Alex Johnson',
    'Salesforce Platform Developer I',
    Date.today(),
    'Sarah Williams'
);

ContentVersion certCv = new ContentVersion();
certCv.Title = 'Certificate_Demo_Spring26';
certCv.PathOnClient = 'Certificate_Demo_Spring26.pdf';
certCv.VersionData = certPdf;
certCv.IsMajorVersion = true;
insert certCv;
System.debug('✓ Certificate saved to Files. ContentVersion Id: ' + certCv.Id);

// ============================================
// 5. CERTIFICATE WITH JAPANESE CHARACTERS
// ============================================
System.debug('\n🇯🇵 Generating Japanese Certificate PDF...');
Blob japaneseCertPdf = VisualforcePdfRenderingDemo.generateCertificate(
    '田中太郎',
    'Salesforce認定アドミニストレーター',
    Date.today(),
    '山田花子'
);

ContentVersion jaCertCv = new ContentVersion();
jaCertCv.Title = 'Japanese_Certificate_Spring26';
jaCertCv.PathOnClient = 'Japanese_Certificate_Spring26.pdf';
jaCertCv.VersionData = japaneseCertPdf;
jaCertCv.IsMajorVersion = true;
insert jaCertCv;
System.debug('✓ Japanese certificate saved to Files. ContentVersion Id: ' + jaCertCv.Id);

// ============================================
// 6. PROFESSIONAL INVOICE
// ============================================
System.debug('\n💰 Generating Professional Invoice PDF...');
List<VisualforcePdfRenderingDemo.InvoiceLineItem> lineItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>{
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Salesforce Enterprise License (Annual)', 25, 1500.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Implementation Services', 80, 200.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Data Migration Package', 1, 5000.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Training - Admin Certification Prep', 5, 500.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Premium Support (Annual)', 1, 12000.00)
};

Blob invoicePdf = VisualforcePdfRenderingDemo.generateInvoice(
    'INV-2026-0042',
    'Global Enterprises Inc.',
    lineItems
);

ContentVersion invoiceCv = new ContentVersion();
invoiceCv.Title = 'Invoice_Demo_Spring26';
invoiceCv.PathOnClient = 'Invoice_Demo_Spring26.pdf';
invoiceCv.VersionData = invoicePdf;
invoiceCv.IsMajorVersion = true;
insert invoiceCv;
System.debug('✓ Invoice saved to Files. ContentVersion Id: ' + invoiceCv.Id);

// ============================================
// 7. INTERNATIONAL INVOICE (JAPANESE)
// ============================================
System.debug('\n🇯🇵 Generating Japanese Invoice PDF...');
List<VisualforcePdfRenderingDemo.InvoiceLineItem> japaneseItems = new List<VisualforcePdfRenderingDemo.InvoiceLineItem>{
    new VisualforcePdfRenderingDemo.InvoiceLineItem('Salesforceエンタープライズライセンス', 10, 180000.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('導入コンサルティングサービス', 40, 15000.00),
    new VisualforcePdfRenderingDemo.InvoiceLineItem('カスタム開発', 1, 500000.00)
};

Blob japaneseInvoicePdf = VisualforcePdfRenderingDemo.generateInvoice(
    'INV-2026-JP-001',
    '株式会社サンプル商事',
    japaneseItems
);

ContentVersion jaInvoiceCv = new ContentVersion();
jaInvoiceCv.Title = 'Japanese_Invoice_Spring26';
jaInvoiceCv.PathOnClient = 'Japanese_Invoice_Spring26.pdf';
jaInvoiceCv.VersionData = japaneseInvoicePdf;
jaInvoiceCv.IsMajorVersion = true;
insert jaInvoiceCv;
System.debug('✓ Japanese invoice saved to Files. ContentVersion Id: ' + jaInvoiceCv.Id);

// ============================================
// 8. RENDERING COMPARISON DOCUMENT
// ============================================
System.debug('\n📊 Generating Rendering Comparison PDF...');
Blob comparisonPdf = VisualforcePdfRenderingDemo.generateRenderingComparison();

ContentVersion compCv = new ContentVersion();
compCv.Title = 'Rendering_Comparison_Spring26';
compCv.PathOnClient = 'Rendering_Comparison_Spring26.pdf';
compCv.VersionData = comparisonPdf;
compCv.IsMajorVersion = true;
insert compCv;
System.debug('✓ Rendering comparison saved to Files. ContentVersion Id: ' + compCv.Id);

// ============================================
// SUMMARY
// ============================================
System.debug('\n===========================================');
System.debug('✅ DEMO COMPLETE!');
System.debug('===========================================');
System.debug('\n📂 All PDFs have been saved to Salesforce Files.');
System.debug('Navigate to Files in your org to view the generated PDFs.\n');
System.debug('Generated PDFs:');
System.debug('  1. Multilingual_Showcase_Spring26.pdf');
System.debug('  2. Font_Showcase_Spring26.pdf');
System.debug('  3. Certificate_Demo_Spring26.pdf');
System.debug('  4. Japanese_Certificate_Spring26.pdf');
System.debug('  5. Invoice_Demo_Spring26.pdf');
System.debug('  6. Japanese_Invoice_Spring26.pdf');
System.debug('  7. Rendering_Comparison_Spring26.pdf');
System.debug('\n🔑 Key Spring \'26 Features Demonstrated:');
System.debug('  • New default sans-serif font');
System.debug('  • Multibyte character support (CJK)');
System.debug('  • Consistent Visualforce PDF rendering');
System.debug('  • Professional document styling');
System.debug('===========================================');

