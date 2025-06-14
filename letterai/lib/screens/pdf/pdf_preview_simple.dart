import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../models/letter.dart';
import '../../services/pdf_service.dart';

class PDFPreviewScreenSimple extends StatelessWidget {
  final Letter letter;

  const PDFPreviewScreenSimple({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        build: (format) => PDFService.generatePDF(
          letter: letter,
        ),
      ),
    );
  }
}
