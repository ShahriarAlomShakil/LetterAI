import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/letter.dart';
import '../../services/pdf_service.dart';

class PDFPreviewScreen extends StatefulWidget {
  final Letter letter;

  const PDFPreviewScreen({
    super.key,
    required this.letter,
  });

  @override
  State<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends State<PDFPreviewScreen> {
  String _selectedTemplate = 'modern';
  String _selectedFont = 'handwriting';

  final List<Map<String, String>> _templates = [
    {'id': 'modern', 'name': 'Modern', 'description': 'Clean and contemporary design'},
    {'id': 'classic', 'name': 'Classic', 'description': 'Traditional formal letter format'},
    {'id': 'elegant', 'name': 'Elegant', 'description': 'Sophisticated with decorative elements'},
  ];

  final List<Map<String, String>> _fonts = [
    {'id': 'handwriting', 'name': 'Handwriting', 'description': 'Natural handwritten style'},
    {'id': 'professional', 'name': 'Professional', 'description': 'Clean business font'},
    {'id': 'casual', 'name': 'Casual', 'description': 'Friendly and approachable'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Print'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Template and font selection
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Template selection
                Row(
                  children: [
                    Text(
                      'Template:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedTemplate,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        items: _templates.map((template) {
                          return DropdownMenuItem(
                            value: template['id'],
                            child: Text(template['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTemplate = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Font selection
                Row(
                  children: [
                    Text(
                      'Font Style:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFont,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        items: _fonts.map((font) {
                          return DropdownMenuItem(
                            value: font['id'],
                            child: Text(font['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFont = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // PDF Preview area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfPreview(
                  build: (format) => PDFService.generatePDF(
                    letter: widget.letter,
                    fontFamily: _selectedFont,
                    template: _selectedTemplate,
                  ),
                  allowSharing: false,
                  allowPrinting: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  maxPageWidth: 700,
                  pdfFileName: '${widget.letter.title.replaceAll(' ', '_')}.pdf',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) async {
    try {
      // Generate PDF with current settings
      final pdfBytes = await PDFService.generatePDF(
        letter: widget.letter,
        fontFamily: _selectedFont,
        template: _selectedTemplate,
      );

      switch (action) {
        case 'save':
          try {
            final fileName = widget.letter.title.replaceAll(' ', '_');
            await PDFService.savePDF(pdfBytes, fileName);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF saved successfully!'),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saving PDF: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
          break;
          
        case 'share':
          try {
            final fileName = widget.letter.title.replaceAll(' ', '_');
            await PDFService.sharePDF(pdfBytes, fileName);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error sharing PDF: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
          break;
          
        case 'print':
          try {
            await PDFService.printPDF(pdfBytes);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error printing PDF: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
