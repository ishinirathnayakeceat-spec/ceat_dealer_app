import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class OutstandingReportService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> fetchOutstandingReports(String zsDelCode) async {
    final String url = '$baseUrl/outstanding-reports';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'zsDelCode': zsDelCode}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load outstanding reports');
      }
    } catch (error) {
      throw Exception('Error fetching outstanding reports: $error');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Future<String?> generatePdfReport(List<dynamic> dueInvoices,
      List<dynamic> creditNotes, String dealerCode) async {
    final pdf = pw.Document();

   
    final image = await _loadHeaderImage();

   
    final headerStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 10,
      color: PdfColors.white,
    );
    const cellStyle = pw.TextStyle(fontSize: 8);
    const headerColor = PdfColors.blue800;

   
    final reportDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape.copyWith(
          marginLeft: 20,
          marginRight: 20,
          marginTop: 20,
          marginBottom: 20,
        ),
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 1, color: PdfColors.grey400),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                 
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                    
                      image != null
                          ? pw.Image(image, width: 80, height: 60)
                          : pw.Text(
                              'Company Logo Placeholder',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                      pw.SizedBox(height: 10),
                      
                      pw.Text(
                        'Outstanding Report',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                     
                      pw.Text(
                        'Dealer Code: $dealerCode',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                 
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Created on: $reportDateTime',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 5),
            
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColors.orange200,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'This report contains confidential information. Unauthorized sharing is prohibited.',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey600,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
           
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 5),
              width: double.infinity,
              height: 1,
              color: PdfColors.grey400,
            ),

          
            pw.Header(
              level: 1,
              child: pw.Text('Due Invoices',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.TableHelper.fromTextArray(
              headerStyle: headerStyle,
              headerDecoration: const pw.BoxDecoration(color: headerColor),
              cellStyle: cellStyle,
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerLeft,
                6: pw.Alignment.centerLeft,
                7: pw.Alignment.centerLeft,
                8: pw.Alignment.centerLeft,
                9: pw.Alignment.centerLeft,
                10: pw.Alignment.centerLeft,
              },
              headers: [
                'Doc Date',
                'Doc No',
                'Doc Type',
                'Amount',
                'Del Date',
                '30 Due',
                'Due Date',
                'Days Due',
                'Chq No',
                'Chq Amt',
                'Chq Dep Date',
              ],
              data: dueInvoices
                  .map((invoice) => [
                        formatDate(invoice['docDate']),
                        invoice['docNo']?.toString() ?? 'N/A',
                        invoice['docType']?.toString() ?? 'N/A',
                        NumberFormat('#,##0.00')
                            .format(double.parse(invoice['amount'].toString())),
                        formatDate(invoice['delDate']),
                        formatDate(invoice['dueDate30']),
                        formatDate(invoice['dueDate']),
                        invoice['daysDue']?.toString() ?? 'N/A',
                        invoice['chqNo']?.toString() ?? 'CNR',
                        invoice['chqAmt'] != null
                            ? NumberFormat('#,##0.00').format(
                                double.parse(invoice['chqAmt'].toString()))
                            : '0.00',
                        formatDate(invoice['chqDepDate']),
                      ])
                  .toList(),
            ),

            pw.SizedBox(height: 10),

         
            pw.Header(
              level: 1,
              child: pw.Text('Others',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.TableHelper.fromTextArray(
              headerStyle: headerStyle,
              headerDecoration: const pw.BoxDecoration(color: headerColor),
              cellStyle: cellStyle,
              cellHeight: 20,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.centerLeft,
              },
              headers: [
                'Doc Date',
                'Doc No',
                'Doc Type',
                'Amount',
                'Reason1', 
                'Reason2', 
              ],
              data: creditNotes
                  .map((credit) => [
                        formatDate(credit['docDate']),
                        credit['docNo']?.toString() ?? 'N/A',
                        credit['docType']?.toString() ?? 'N/A',
                        NumberFormat('#,##0.00')
                            .format(double.parse(credit['amount'].toString())),
                        credit['reason1']?.toString() ??
                            'N/A', 
                        credit['reason2']?.toString() ??
                            'N/A', 
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 30),

           
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text('Total:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(width: 10),
                pw.Text(
                  NumberFormat('#,##0.00')
                      .format(_calculateTotal(dueInvoices, creditNotes)),
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12),
                ),
              ],
            ),

            pw.SizedBox(height: 20),
          ];
        },
        footer: (pw.Context context) {
          
          if (context.pageNumber == context.pagesCount) {
            return pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.grey),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style:
                        const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Document Type With Company:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            'CNR - Cheque Not Received',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'RV21 Invoice of Associate CEAT(Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'ZG21 Credit Note of Associate CEAT(Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'AB21(+) Invoice Bal. of Associate CEAT(Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'AB21(-) Credit Note Bal. of Associate CEAT(Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'R Cheque Returned',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'RV22 Invoice of CEAT Kelani International Tyres (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'ZG22 Credit Note of CEAT Kelani International Tyres (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'AB22(+) Invoice Bal. of CEAT Kelani International Tyres (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'AB22(-) Credit Note Bal. of CEAT Kelani International Tyres (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bank A/C No:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            'Associate CEAT (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'BOC - 0000000955',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'Commercial Bank - 1415263801',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'CEAT Kelani International Tyres (Pvt) Ltd',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'BOC - 0000000791',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'Commercial Bank - 1415342101',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                     
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'General Contact:',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            'T: +94 114 822 800, +94 112 911 305,',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            '+94 112 911 269, +94 112 911 241',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            'F: +94 114 817 721 (Procurement),',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            '+94 112 911 453 (Marketing),',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            '+94 114 810 034 (Finance)',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'This is a System Generated statement and does not require a signature.',
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          } else {
            
            return pw.SizedBox(height: 0); 
          }
        },
      ),
    );

    return await _savePdf(pdf);
  }

  double _calculateTotal(List<dynamic> dueInvoices, List<dynamic> creditNotes) {
    double total = 0.0;
    for (var invoice in dueInvoices) {
      total += double.tryParse(invoice['amount'].toString()) ?? 0.0;
    }
    for (var credit in creditNotes) {
      total += double.tryParse(credit['amount'].toString()) ?? 0.0;
    }
    return total;
  }

  Future<String?> _savePdf(pw.Document pdf) async {
    try {
      if (kIsWeb) {
        return null;
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 30) {
            if (await Permission.manageExternalStorage.request().isGranted) {
              final directory = Directory('/storage/emulated/0/Download');
              final String filePath =
                  '${directory.path}/outstanding_reports.pdf';
              final File file = File(filePath);
              await file.writeAsBytes(await pdf.save());
              return filePath;
            } else {
              throw Exception('Manage external storage permission denied');
            }
          } else {
            if (await Permission.storage.request().isGranted) {
              final directory = await getExternalStorageDirectory();
              if (directory != null) {
                final String filePath =
                    '${directory.path}/outstanding_reports.pdf';
                final File file = File(filePath);
                await file.writeAsBytes(await pdf.save());
                return filePath;
              } else {
                throw Exception('Could not get the external storage directory');
              }
            } else {
              throw Exception('Storage permission denied');
            }
          }
        } else if (Platform.isIOS) {
          final directory = await getApplicationDocumentsDirectory();
          final String filePath = '${directory.path}/outstanding_reports.pdf';
          final File file = File(filePath);
          await file.writeAsBytes(await pdf.save());
          return filePath;
        }
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<pw.ImageProvider?> _loadHeaderImage() async {
    try {
      final ByteData imageData =
          await rootBundle.load('assets/images/ceat-logo-present-scaled.png');
      return pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }
}
