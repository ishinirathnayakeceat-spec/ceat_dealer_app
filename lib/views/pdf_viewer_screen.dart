import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerScreen extends StatefulWidget {
  final String url;
  const PdfViewerScreen({super.key, required this.url});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? filePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");

      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        filePath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filePath != null
              ? PDFView(
                  filePath: filePath!,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                )
              : const Center(child: Text("Failed to load PDF")),
    );
  }
}
