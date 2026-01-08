/**
 * VisualforcePdfRenderingDemo - Demonstrates the new Blob.toPdf() with Visualforce Rendering
 * 
 * Spring '26 Release Update: Blob.toPdf() now uses the Visualforce PDF rendering service
 * which provides:
 * - Expanded font support including multibyte characters (CJK - Chinese, Japanese, Korean)
 * - Default font changed from serif to sans-serif
 * - Consistent rendering across the Salesforce Platform
 * 
 * This demo showcases:
 * - Global language support with multibyte characters
 * - Available font families from Visualforce PDF rendering
 * - Professional document generation (certificates, invoices, reports)
 * - Styling capabilities with CSS
 * 
 * @author Salesforce Spring '26 Demo
 * @since API Version 66.0
 */
public with sharing class VisualforcePdfRenderingDemo {

    // ============================================
    // FONT SHOWCASE - Visualforce PDF Fonts
    // ============================================
    
    /**
     * Available fonts in Visualforce PDF Rendering Service
     * Note: The default font is now sans-serif (previously serif)
     */
    public static final List<String> AVAILABLE_FONTS = new List<String>{
        'Arial Unicode MS',      // Best for multibyte/international characters
        'Helvetica',             // Clean sans-serif (similar to new default)
        'Times New Roman',       // Classic serif
        'Courier New',           // Monospace
        'Georgia',               // Elegant serif
        'Verdana',               // Wide sans-serif
        'Tahoma',                // Compact sans-serif
        'Trebuchet MS',          // Modern sans-serif
        'sans-serif',            // NEW DEFAULT in Spring '26
        'serif'                  // OLD DEFAULT (before Spring '26)
    };

    // ============================================
    // MULTILINGUAL PDF GENERATION
    // ============================================
    
    /**
     * Generates a PDF showcasing multilingual support with the new rendering engine
     * Demonstrates the power of multibyte character support (CJK and more)
     * @return Blob The generated PDF as a Blob
     */
    public static Blob generateMultilingualShowcase() {
        String htmlContent = buildMultilingualHtml();
        return Blob.toPdf(htmlContent);
    }
    
    /**
     * Builds HTML content demonstrating multilingual capabilities
     * @return String HTML content for PDF generation
     */
    private static String buildMultilingualHtml() {
        return '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<style>' +
            'body { font-family: "Arial Unicode MS", sans-serif; margin: 40px; }' +
            'h1 { color: #0070d2; text-align: center; font-size: 28px; margin-bottom: 30px; }' +
            '.subtitle { text-align: center; color: #666; margin-bottom: 40px; }' +
            '.language-section { margin-bottom: 25px; padding: 15px; border-left: 4px solid #0070d2; background: #f4f6f9; }' +
            '.language-name { font-weight: bold; color: #0070d2; margin-bottom: 8px; }' +
            '.greeting { font-size: 18px; margin-bottom: 5px; }' +
            '.description { color: #666; font-size: 12px; }' +
            '.badge { display: inline-block; background: #0070d2; color: white; padding: 3px 10px; border-radius: 12px; font-size: 10px; }' +
            '.footer { margin-top: 40px; text-align: center; color: #999; font-size: 11px; border-top: 1px solid #ddd; padding-top: 20px; }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<h1>🌍 Global Language Support Demo</h1>' +
            '<p class="subtitle">Powered by Visualforce PDF Rendering Service | Spring \'26</p>' +
            
            // Japanese
            '<div class="language-section">' +
            '<div class="language-name">🇯🇵 Japanese (日本語)</div>' +
            '<div class="greeting">こんにちは、Salesforceへようこそ！</div>' +
            '<div class="description">Hello, welcome to Salesforce! - Full Hiragana, Katakana, and Kanji support</div>' +
            '</div>' +
            
            // Chinese Simplified
            '<div class="language-section">' +
            '<div class="language-name">🇨🇳 Chinese Simplified (简体中文)</div>' +
            '<div class="greeting">欢迎使用Salesforce平台！</div>' +
            '<div class="description">Welcome to the Salesforce Platform! - Complete CJK Unified Ideographs</div>' +
            '</div>' +
            
            // Chinese Traditional
            '<div class="language-section">' +
            '<div class="language-name">🇹🇼 Chinese Traditional (繁體中文)</div>' +
            '<div class="greeting">歡迎使用Salesforce平台！</div>' +
            '<div class="description">Welcome to the Salesforce Platform! - Traditional Chinese characters</div>' +
            '</div>' +
            
            // Korean
            '<div class="language-section">' +
            '<div class="language-name">🇰🇷 Korean (한국어)</div>' +
            '<div class="greeting">Salesforce에 오신 것을 환영합니다!</div>' +
            '<div class="description">Welcome to Salesforce! - Full Hangul syllables support</div>' +
            '</div>' +
            
            // Thai
            '<div class="language-section">' +
            '<div class="language-name">🇹🇭 Thai (ภาษาไทย)</div>' +
            '<div class="greeting">ยินดีต้อนรับสู่ Salesforce!</div>' +
            '<div class="description">Welcome to Salesforce! - Thai script with tone marks</div>' +
            '</div>' +
            
            // Arabic (RTL)
            '<div class="language-section">' +
            '<div class="language-name">🇸🇦 Arabic (العربية)</div>' +
            '<div class="greeting" dir="rtl">مرحباً بكم في Salesforce!</div>' +
            '<div class="description">Welcome to Salesforce! - Right-to-left script support</div>' +
            '</div>' +
            
            // Hindi
            '<div class="language-section">' +
            '<div class="language-name">🇮🇳 Hindi (हिन्दी)</div>' +
            '<div class="greeting">Salesforce में आपका स्वागत है!</div>' +
            '<div class="description">Welcome to Salesforce! - Devanagari script</div>' +
            '</div>' +
            
            // Russian
            '<div class="language-section">' +
            '<div class="language-name">🇷🇺 Russian (Русский)</div>' +
            '<div class="greeting">Добро пожаловать в Salesforce!</div>' +
            '<div class="description">Welcome to Salesforce! - Cyrillic alphabet</div>' +
            '</div>' +
            
            // Greek
            '<div class="language-section">' +
            '<div class="language-name">🇬🇷 Greek (Ελληνικά)</div>' +
            '<div class="greeting">Καλώς ήρθατε στο Salesforce!</div>' +
            '<div class="description">Welcome to Salesforce! - Greek alphabet</div>' +
            '</div>' +
            
            '<div class="footer">' +
            '<span class="badge">NEW IN SPRING \'26</span><br/><br/>' +
            'Blob.toPdf() with Visualforce PDF Rendering Service<br/>' +
            'Generated on ' + Date.today().format() +
            '</div>' +
            '</body>' +
            '</html>';
    }

    // ============================================
    // FONT FAMILY SHOWCASE
    // ============================================
    
    /**
     * Generates a PDF demonstrating all available font families
     * Shows the visual difference between old serif default and new sans-serif default
     * @return Blob The generated PDF as a Blob
     */
    public static Blob generateFontShowcase() {
        String htmlContent = buildFontShowcaseHtml();
        return Blob.toPdf(htmlContent);
    }
    
    /**
     * Builds HTML showcasing different font families
     * @return String HTML content for PDF generation
     */
    private static String buildFontShowcaseHtml() {
        String fontSamples = '';
        String sampleText = 'The quick brown fox jumps over the lazy dog. 0123456789';
        
        for (String font : AVAILABLE_FONTS) {
            String isDefault = '';
            String highlightStyle = '';
            
            if (font == 'sans-serif') {
                isDefault = '<span style="background: #4bca81; color: white; padding: 2px 8px; border-radius: 10px; font-size: 10px; margin-left: 10px;">NEW DEFAULT</span>';
                highlightStyle = 'border: 2px solid #4bca81; background: #f0fff4;';
            } else if (font == 'serif') {
                isDefault = '<span style="background: #f39c12; color: white; padding: 2px 8px; border-radius: 10px; font-size: 10px; margin-left: 10px;">OLD DEFAULT</span>';
                highlightStyle = 'border: 2px solid #f39c12; background: #fffef0;';
            }
            
            fontSamples += 
                '<div class="font-sample" style="' + highlightStyle + '">' +
                '<div class="font-name">' + font + isDefault + '</div>' +
                '<div style="font-family: \'' + font + '\', sans-serif; font-size: 14px;">' + sampleText + '</div>' +
                '<div style="font-family: \'' + font + '\', sans-serif; font-size: 14px; font-weight: bold;">Bold: ' + sampleText + '</div>' +
                '<div style="font-family: \'' + font + '\', sans-serif; font-size: 14px; font-style: italic;">Italic: ' + sampleText + '</div>' +
                '</div>';
        }
        
        return '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<style>' +
            'body { margin: 30px; }' +
            'h1 { color: #0070d2; text-align: center; font-family: sans-serif; }' +
            '.subtitle { text-align: center; color: #666; font-family: sans-serif; margin-bottom: 30px; }' +
            '.font-sample { margin-bottom: 20px; padding: 15px; border-radius: 8px; border: 1px solid #ddd; background: #fafafa; }' +
            '.font-name { font-family: sans-serif; font-weight: bold; color: #333; margin-bottom: 10px; font-size: 12px; }' +
            '.comparison-box { margin-top: 30px; padding: 20px; background: #e8f4fd; border-radius: 8px; }' +
            '.comparison-title { font-family: sans-serif; font-weight: bold; color: #0070d2; margin-bottom: 15px; }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<h1>🔤 Font Family Showcase</h1>' +
            '<p class="subtitle">Available Fonts in Visualforce PDF Rendering Service</p>' +
            fontSamples +
            '<div class="comparison-box">' +
            '<div class="comparison-title">⚠️ Important Note for Spring \'26 Migration</div>' +
            '<p style="font-family: sans-serif; font-size: 12px; color: #333;">' +
            'The default font has changed from <strong>serif</strong> to <strong>sans-serif</strong>. ' +
            'If your PDF strings don\'t include explicit font styling, you may notice:<br/><br/>' +
            '• Different line lengths and character widths<br/>' +
            '• Different line breaks and page breaks<br/>' +
            '• Overall cleaner, more modern appearance<br/><br/>' +
            'To maintain the old appearance, explicitly set <code>font-family: serif;</code> in your CSS.' +
            '</p>' +
            '</div>' +
            '</body>' +
            '</html>';
    }

    // ============================================
    // PROFESSIONAL CERTIFICATE GENERATOR
    // ============================================
    
    /**
     * Generates a professional certificate PDF
     * Demonstrates practical business use case with styling
     * @param recipientName Name of the certificate recipient
     * @param courseName Name of the completed course
     * @param completionDate Date of completion
     * @param instructorName Name of the instructor
     * @return Blob The generated certificate PDF
     */
    public static Blob generateCertificate(
        String recipientName, 
        String courseName, 
        Date completionDate, 
        String instructorName
    ) {
        String htmlContent = buildCertificateHtml(recipientName, courseName, completionDate, instructorName);
        return Blob.toPdf(htmlContent);
    }
    
    /**
     * Builds HTML for a professional certificate
     */
    private static String buildCertificateHtml(
        String recipientName, 
        String courseName, 
        Date completionDate, 
        String instructorName
    ) {
        return '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<style>' +
            'body { ' +
            '  font-family: "Georgia", serif; ' +
            '  margin: 0; ' +
            '  padding: 40px; ' +
            '  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);' +
            '}' +
            '.certificate-border {' +
            '  border: 8px double #c9a227;' +
            '  background: white;' +
            '  padding: 50px;' +
            '  text-align: center;' +
            '}' +
            '.certificate-header {' +
            '  color: #c9a227;' +
            '  font-size: 14px;' +
            '  letter-spacing: 8px;' +
            '  text-transform: uppercase;' +
            '  margin-bottom: 20px;' +
            '}' +
            '.certificate-title {' +
            '  font-size: 42px;' +
            '  color: #333;' +
            '  margin-bottom: 30px;' +
            '  font-family: "Times New Roman", serif;' +
            '}' +
            '.certificate-text {' +
            '  color: #666;' +
            '  font-size: 16px;' +
            '  margin-bottom: 15px;' +
            '}' +
            '.recipient-name {' +
            '  font-size: 36px;' +
            '  color: #0070d2;' +
            '  font-family: "Trebuchet MS", sans-serif;' +
            '  margin: 30px 0;' +
            '  padding-bottom: 10px;' +
            '  border-bottom: 2px solid #c9a227;' +
            '  display: inline-block;' +
            '}' +
            '.course-name {' +
            '  font-size: 24px;' +
            '  color: #333;' +
            '  font-weight: bold;' +
            '  margin: 20px 0;' +
            '}' +
            '.certificate-date {' +
            '  color: #999;' +
            '  font-size: 14px;' +
            '  margin-top: 30px;' +
            '}' +
            '.signature-section {' +
            '  margin-top: 50px;' +
            '  display: flex;' +
            '  justify-content: space-around;' +
            '}' +
            '.signature-line {' +
            '  border-top: 1px solid #333;' +
            '  width: 200px;' +
            '  padding-top: 10px;' +
            '  font-size: 12px;' +
            '  color: #666;' +
            '}' +
            '.seal {' +
            '  width: 80px;' +
            '  height: 80px;' +
            '  border: 3px solid #c9a227;' +
            '  border-radius: 50%;' +
            '  display: flex;' +
            '  align-items: center;' +
            '  justify-content: center;' +
            '  margin: 30px auto;' +
            '  color: #c9a227;' +
            '  font-size: 10px;' +
            '  text-align: center;' +
            '}' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<div class="certificate-border">' +
            '<div class="certificate-header">Certificate of Completion</div>' +
            '<div class="certificate-title">Achievement Award</div>' +
            '<div class="certificate-text">This is to certify that</div>' +
            '<div class="recipient-name">' + String.escapeSingleQuotes(recipientName) + '</div>' +
            '<div class="certificate-text">has successfully completed the course</div>' +
            '<div class="course-name">' + String.escapeSingleQuotes(courseName) + '</div>' +
            '<div class="seal">★<br/>CERTIFIED<br/>★</div>' +
            '<div class="certificate-date">Completed on ' + completionDate.format() + '</div>' +
            '<table style="width: 100%; margin-top: 40px;">' +
            '<tr>' +
            '<td style="text-align: center; width: 50%;">' +
            '<div class="signature-line">' + String.escapeSingleQuotes(instructorName) + '<br/>Instructor</div>' +
            '</td>' +
            '<td style="text-align: center; width: 50%;">' +
            '<div class="signature-line">Salesforce<br/>Training Authority</div>' +
            '</td>' +
            '</tr>' +
            '</table>' +
            '</div>' +
            '</body>' +
            '</html>';
    }

    // ============================================
    // INVOICE GENERATOR
    // ============================================
    
    /**
     * Generates a professional invoice PDF with international support
     * @param invoiceNumber The invoice number
     * @param customerName Customer name (supports multibyte characters)
     * @param lineItems List of invoice line items
     * @return Blob The generated invoice PDF
     */
    public static Blob generateInvoice(
        String invoiceNumber,
        String customerName,
        List<InvoiceLineItem> lineItems
    ) {
        String htmlContent = buildInvoiceHtml(invoiceNumber, customerName, lineItems);
        return Blob.toPdf(htmlContent);
    }
    
    /**
     * Builds HTML for a professional invoice
     */
    private static String buildInvoiceHtml(
        String invoiceNumber,
        String customerName,
        List<InvoiceLineItem> lineItems
    ) {
        String itemRows = '';
        Decimal subtotal = 0;
        
        for (InvoiceLineItem item : lineItems) {
            Decimal lineTotal = item.quantity * item.unitPrice;
            subtotal += lineTotal;
            itemRows += 
                '<tr>' +
                '<td style="padding: 12px; border-bottom: 1px solid #eee;">' + String.escapeSingleQuotes(item.description) + '</td>' +
                '<td style="padding: 12px; border-bottom: 1px solid #eee; text-align: center;">' + item.quantity + '</td>' +
                '<td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right;">$' + item.unitPrice.setScale(2) + '</td>' +
                '<td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right; font-weight: bold;">$' + lineTotal.setScale(2) + '</td>' +
                '</tr>';
        }
        
        Decimal tax = subtotal * 0.08;
        Decimal total = subtotal + tax;
        
        return '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<style>' +
            'body { font-family: "Arial Unicode MS", sans-serif; margin: 40px; color: #333; }' +
            '.header { display: flex; justify-content: space-between; margin-bottom: 40px; }' +
            '.company-info { }' +
            '.company-name { font-size: 28px; font-weight: bold; color: #0070d2; }' +
            '.company-details { font-size: 12px; color: #666; margin-top: 5px; }' +
            '.invoice-info { text-align: right; }' +
            '.invoice-title { font-size: 32px; color: #333; font-weight: bold; }' +
            '.invoice-number { font-size: 14px; color: #666; }' +
            '.invoice-date { font-size: 12px; color: #999; }' +
            '.customer-section { background: #f4f6f9; padding: 20px; border-radius: 8px; margin-bottom: 30px; }' +
            '.section-title { font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; }' +
            '.customer-name { font-size: 18px; font-weight: bold; }' +
            'table { width: 100%; border-collapse: collapse; }' +
            'th { background: #0070d2; color: white; padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; }' +
            '.totals-section { margin-top: 30px; text-align: right; }' +
            '.total-row { padding: 8px 0; }' +
            '.total-label { color: #666; }' +
            '.grand-total { font-size: 24px; color: #0070d2; font-weight: bold; padding-top: 15px; border-top: 2px solid #0070d2; margin-top: 10px; }' +
            '.footer { margin-top: 50px; text-align: center; color: #999; font-size: 11px; border-top: 1px solid #ddd; padding-top: 20px; }' +
            '.badge { background: #4bca81; color: white; padding: 4px 12px; border-radius: 15px; font-size: 11px; }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<table style="width: 100%;">' +
            '<tr>' +
            '<td style="vertical-align: top;">' +
            '<div class="company-name">Acme Corporation</div>' +
            '<div class="company-details">123 Business Street<br/>San Francisco, CA 94102<br/>contact@acme.com</div>' +
            '</td>' +
            '<td style="vertical-align: top; text-align: right;">' +
            '<div class="invoice-title">INVOICE</div>' +
            '<div class="invoice-number">#' + String.escapeSingleQuotes(invoiceNumber) + '</div>' +
            '<div class="invoice-date">Date: ' + Date.today().format() + '</div>' +
            '</td>' +
            '</tr>' +
            '</table>' +
            
            '<div class="customer-section">' +
            '<div class="section-title">Bill To</div>' +
            '<div class="customer-name">' + String.escapeSingleQuotes(customerName) + '</div>' +
            '</div>' +
            
            '<table>' +
            '<thead>' +
            '<tr>' +
            '<th style="width: 50%;">Description</th>' +
            '<th style="width: 15%; text-align: center;">Qty</th>' +
            '<th style="width: 17.5%; text-align: right;">Unit Price</th>' +
            '<th style="width: 17.5%; text-align: right;">Total</th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>' +
            itemRows +
            '</tbody>' +
            '</table>' +
            
            '<div class="totals-section">' +
            '<div class="total-row"><span class="total-label">Subtotal:</span> $' + subtotal.setScale(2) + '</div>' +
            '<div class="total-row"><span class="total-label">Tax (8%):</span> $' + tax.setScale(2) + '</div>' +
            '<div class="grand-total">Total: $' + total.setScale(2) + '</div>' +
            '</div>' +
            
            '<div class="footer">' +
            '<span class="badge">Generated with Blob.toPdf()</span><br/><br/>' +
            'Thank you for your business! | Powered by Visualforce PDF Rendering Service<br/>' +
            'This invoice supports multibyte characters: 日本語 | 中文 | 한국어 | ไทย' +
            '</div>' +
            '</body>' +
            '</html>';
    }

    // ============================================
    // COMPARISON: OLD vs NEW RENDERING
    // ============================================
    
    /**
     * Generates a side-by-side comparison document showing the rendering differences
     * This helps developers understand what to expect after the Spring '26 update
     * @return Blob The comparison PDF
     */
    public static Blob generateRenderingComparison() {
        String htmlContent = buildComparisonHtml();
        return Blob.toPdf(htmlContent);
    }
    
    /**
     * Builds HTML showing before/after rendering comparison
     */
    private static String buildComparisonHtml() {
        return '<!DOCTYPE html>' +
            '<html>' +
            '<head>' +
            '<style>' +
            'body { font-family: sans-serif; margin: 30px; }' +
            'h1 { color: #0070d2; text-align: center; }' +
            '.comparison-container { display: flex; gap: 20px; margin-top: 30px; }' +
            '.comparison-box { flex: 1; padding: 20px; border-radius: 8px; }' +
            '.old-style { background: #fff5f5; border: 2px solid #f39c12; }' +
            '.new-style { background: #f0fff4; border: 2px solid #4bca81; }' +
            '.box-title { font-weight: bold; margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #ddd; }' +
            '.old-title { color: #f39c12; }' +
            '.new-title { color: #4bca81; }' +
            '.sample-text { margin: 10px 0; }' +
            '.highlight { background: yellow; padding: 2px 5px; }' +
            '.info-box { margin-top: 30px; padding: 20px; background: #e8f4fd; border-radius: 8px; border-left: 4px solid #0070d2; }' +
            '.info-title { font-weight: bold; color: #0070d2; margin-bottom: 10px; }' +
            '.checklist { list-style-type: none; padding: 0; }' +
            '.checklist li { padding: 8px 0; padding-left: 25px; position: relative; }' +
            '.checklist li:before { content: "✓"; position: absolute; left: 0; color: #4bca81; font-weight: bold; }' +
            '</style>' +
            '</head>' +
            '<body>' +
            '<h1>📄 Blob.toPdf() Rendering Comparison</h1>' +
            '<p style="text-align: center; color: #666;">Spring \'26 Release Update - Before vs After</p>' +
            
            '<table style="width: 100%; margin-top: 30px; border-collapse: separate; border-spacing: 20px 0;">' +
            '<tr>' +
            '<td style="width: 50%; vertical-align: top;">' +
            '<div class="comparison-box old-style">' +
            '<div class="box-title old-title">❌ Before Spring \'26 (Old Rendering)</div>' +
            '<div class="sample-text" style="font-family: serif;">Default font was <strong>serif</strong></div>' +
            '<div class="sample-text" style="font-family: serif;">Limited multibyte character support</div>' +
            '<div class="sample-text" style="font-family: serif;">Japanese: [may not render correctly]</div>' +
            '<div class="sample-text" style="font-family: serif;">Chinese: [may not render correctly]</div>' +
            '<div class="sample-text" style="font-family: serif; font-size: 11px;">Line lengths based on serif metrics</div>' +
            '</div>' +
            '</td>' +
            '<td style="width: 50%; vertical-align: top;">' +
            '<div class="comparison-box new-style">' +
            '<div class="box-title new-title">✓ After Spring \'26 (Visualforce Rendering)</div>' +
            '<div class="sample-text">Default font is now <strong>sans-serif</strong></div>' +
            '<div class="sample-text">Full multibyte character support</div>' +
            '<div class="sample-text">Japanese: こんにちは世界</div>' +
            '<div class="sample-text">Chinese: 你好世界</div>' +
            '<div class="sample-text" style="font-size: 11px;">Line lengths based on sans-serif metrics</div>' +
            '</div>' +
            '</td>' +
            '</tr>' +
            '</table>' +
            
            '<div class="info-box">' +
            '<div class="info-title">🔧 Migration Checklist</div>' +
            '<ul class="checklist">' +
            '<li>Review PDFs that don\'t specify explicit fonts</li>' +
            '<li>Test line breaks and page breaks with new rendering</li>' +
            '<li>Verify international character rendering (CJK, Thai, Arabic, etc.)</li>' +
            '<li>Update explicit font declarations if serif is required</li>' +
            '<li>Test PDF generation in sandbox before enabling in production</li>' +
            '</ul>' +
            '</div>' +
            
            '<div style="margin-top: 30px; padding: 15px; background: #fffef0; border: 1px solid #f39c12; border-radius: 8px;">' +
            '<strong style="color: #f39c12;">⚠️ Enforcement Date:</strong> Summer \'26<br/>' +
            '<span style="color: #666; font-size: 12px;">Check Trust Status for your instance\'s specific upgrade date</span>' +
            '</div>' +
            '</body>' +
            '</html>';
    }

    // ============================================
    // QUICK DEMO METHODS
    // ============================================
    
    /**
     * Quick demo - generates a simple PDF with the new rendering
     * Run this in Anonymous Apex to test the feature
     * @return Blob Simple demo PDF
     */
    public static Blob quickDemo() {
        String html = '<!DOCTYPE html>' +
            '<html><head><style>' +
            'body { font-family: sans-serif; margin: 40px; }' +
            'h1 { color: #0070d2; }' +
            '.demo-box { background: #f4f6f9; padding: 20px; border-radius: 8px; margin: 20px 0; }' +
            '</style></head>' +
            '<body>' +
            '<h1>🎉 Blob.toPdf() Quick Demo</h1>' +
            '<p>This PDF was generated using the new Visualforce PDF Rendering Service.</p>' +
            '<div class="demo-box">' +
            '<strong>Key Features:</strong><br/>' +
            '• Default sans-serif font (notice the clean, modern look)<br/>' +
            '• Multibyte support: 日本語 | 中文 | 한국어<br/>' +
            '• Consistent rendering with Visualforce PDFs<br/>' +
            '</div>' +
            '<p style="color: #666; font-size: 12px;">Generated: ' + DateTime.now().format() + '</p>' +
            '</body></html>';
        
        return Blob.toPdf(html);
    }
    
    /**
     * Demo showing how to save a generated PDF to a ContentVersion
     * @param fileName Name for the PDF file
     * @return Id The ContentVersion Id
     */
    public static Id savePdfToFiles(String fileName) {
        Blob pdfBlob = generateMultilingualShowcase();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName + '.pdf';
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        
        insert cv;
        return cv.Id;
    }

    // ============================================
    // HELPER CLASSES
    // ============================================
    
    /**
     * Wrapper class for invoice line items
     */
    public class InvoiceLineItem {
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Integer quantity { get; set; }
        @AuraEnabled public Decimal unitPrice { get; set; }
        
        public InvoiceLineItem(String description, Integer quantity, Decimal unitPrice) {
            this.description = description;
            this.quantity = quantity;
            this.unitPrice = unitPrice;
        }
    }
    
    /**
     * Result wrapper for PDF generation operations
     */
    public class PdfGenerationResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Id contentVersionId { get; set; }
        @AuraEnabled public Integer fileSizeBytes { get; set; }
        
        public PdfGenerationResult(Boolean success, String message, Id contentVersionId, Integer fileSizeBytes) {
            this.success = success;
            this.message = message;
            this.contentVersionId = contentVersionId;
            this.fileSizeBytes = fileSizeBytes;
        }
    }
}

