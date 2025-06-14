import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/letter.dart';

class PDFService {
  static Future<Uint8List> generatePDF({
    required Letter letter,
    String fontFamily = 'handwriting',
    String template = 'modern',
  }) async {
    final pdf = pw.Document();
    
    // Load font
    final font = await _loadFont(fontFamily);
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return _buildLetterContent(letter, font, template);
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildLetterContent(
    Letter letter,
    pw.Font font,
    String template,
  ) {
    switch (template) {
      case 'classic':
        return _buildClassicTemplate(letter, font);
      case 'modern':
        return _buildModernTemplate(letter, font);
      case 'elegant':
        return _buildElegantTemplate(letter, font);
      default:
        return _buildModernTemplate(letter, font);
    }
  }
  
  static pw.Widget _buildModernTemplate(Letter letter, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header with title
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(bottom: 20),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColors.grey300,
                width: 1,
              ),
            ),
          ),
          child: pw.Text(
            letter.title,
            style: pw.TextStyle(
              font: font,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        
        pw.SizedBox(height: 30),
        
        // Date aligned to the right
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            _formatDate(letter.createdAt),
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
        
        pw.SizedBox(height: 30),
        
        // Content
        pw.Expanded(
          child: pw.Text(
            letter.content,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              lineSpacing: 1.5,
              color: PdfColors.black,
            ),
          ),
        ),
        
        // Footer
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(top: 20),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                color: PdfColors.grey300,
                width: 1,
              ),
            ),
          ),
          child: pw.Text(
            'Created with LetterAI',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey500,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildClassicTemplate(Letter letter, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Text(
          letter.title,
          style: pw.TextStyle(
            font: font,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        
        pw.SizedBox(height: 40),
        
        // Date
        pw.Text(
          _formatDate(letter.createdAt),
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            color: PdfColors.black,
          ),
        ),
        
        pw.SizedBox(height: 30),
        
        // Content
        pw.Expanded(
          child: pw.Text(
            letter.content,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              lineSpacing: 2,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }
  
  static pw.Widget _buildElegantTemplate(Letter letter, pw.Font font) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: 2,
        ),
      ),
      padding: const pw.EdgeInsets.all(30),
      child: pw.Column(
        children: [
          // Elegant header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.grey400,
                  width: 2,
                ),
              ),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'LETTER',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  letter.title,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 40),
          
          // Content
          pw.Expanded(
            child: pw.Text(
              letter.content,
              style: pw.TextStyle(
                font: font,
                fontSize: 13,
                lineSpacing: 1.8,
                color: PdfColors.black,
              ),
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Date at bottom
          pw.Text(
            _formatDate(letter.createdAt),
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  static Future<pw.Font> _loadFont(String fontFamily) async {
    // For now, using built-in fonts
    // In a future enhancement, we can load custom fonts from assets
    switch (fontFamily) {
      case 'handwriting':
        return pw.Font.times();
      case 'professional':
        return pw.Font.helvetica();
      case 'casual':
        return pw.Font.courier();
      default:
        return pw.Font.helvetica();
    }
  }
  
  static String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  static Future<File> savePDF(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }
  
  static Future<void> printPDF(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
  
  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$fileName.pdf',
    );
  }
}
