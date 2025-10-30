import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';

class PPDService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> getPPDDetailsAndSummary(
      String dealerCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/getPPDDetailsAndSummary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'zsDelCode': dealerCode}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch PPD data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<String?> generatePDF(
      String yearMonth, List<dynamic> details, String dealerCode) async {
    final pdf = pw.Document();

    try {
      final image = await _loadHeaderImage();
      final reportDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final headerStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      );
      const cellStyle = pw.TextStyle(fontSize: 9);
      const headerColor = PdfColors.blue800;

      final List<double> columnWidths = [
        30, 
        40,
        40, 
        40, 
        30,
        40, 
        30, 
        40, 
        40, 
        40, 
        50, 
      ];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return [
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 1, color: PdfColors.grey400),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        image != null
                            ? pw.Image(image, width: 100, height: 80)
                            : pw.Text('Company Logo Placeholder',
                                style: const pw.TextStyle(fontSize: 12)),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Created on: $reportDateTime',
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'CEAT Dealer App',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'PPD Report - $yearMonth',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Dealer Code: $dealerCode',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 10),
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
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: headerStyle,
                headerDecoration: const pw.BoxDecoration(color: headerColor),
                cellStyle: cellStyle,
                cellHeight: 15,
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
                columnWidths: {
                  for (int i = 0; i < columnWidths.length; i++)
                    i: pw.FixedColumnWidth(columnWidths[i]),
                },
                headers: [
                  'Invoice Number',
                  'Invoice Date',
                  'PPD Cal Date',
                  'Due Date ',
                  'Invoice Amount',
                  'Acc.Posting Date',
                  'Acc.Ref.Doc Number',
                  'Settle Amount',
                  'PPD Amount',
                  'Penalty Amount',
                  'Net PPD Amount'
                ],
                data: details
                    .map((detail) => [
                          detail['Invoice Number']?.toString() ?? '',
                          detail['Invoice Date']?.toString() ?? '',
                          detail['PPD Cal Date']?.toString() ?? '',
                          detail['Due Date']?.toString() ?? '',
                          NumberFormat('#,##0.00;(#,##0.00)').format(
                              double.parse(
                                  detail['Invoice Amount'].toString())),
                          detail['Acc.Posting Date']?.toString() ?? '',
                          detail['Acc.Ref.Doc Number']?.toString() ?? '',
                          NumberFormat('#,##0.00;(#,##0.00)').format(
                              double.parse(detail['Settle Amount'].toString())),
                          NumberFormat('#,##0.00;(#,##0.00)').format(
                              double.parse(detail['PPD Amount'].toString())),
                          NumberFormat('#,##0.00;(#,##0.00)').format(
                              double.parse(
                                  detail['Panalty Amount'].toString())),
                          NumberFormat('#,##0.00;(#,##0.00)').format(
                              double.parse(
                                  detail['Net PPD Amount'].toString())),
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween, 
                children: [
                  pw.Text(
                    'Total Net PPD Amount: ',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${details.isNotEmpty ? details.map((detail) => double.parse(detail['Net PPD Amount'].toString())).reduce((value, element) => value + element).toStringAsFixed(2) : '0.00'}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
            ];
          },
          footer: (pw.Context context) {
            
            final pageNumberText =
                'Page ${context.pageNumber} of ${context.pagesCount}';

           
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
                      pageNumberText,
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'CEAT Kelani International Tyres (Pvt) Ltd.',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                            pw.Text(
                              'Office & Factory: P.O. Box 53,',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'Nungamugoda, Kelaniya, Sri Lanka.',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'T: +94 114 822 800, +94 112 911 305,',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              '+94 112 911 269, +94 112 911 241',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              'F: +94 114 817 721 (Procurement),',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              '+94 112 911 453 (Marketing),',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              '+94 114 810 034 (Finance)',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

           
            return pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(
                pageNumberText,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            );
          },
        ),
      );

      return await _savePDF(pdf);
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  
  Future<String?> _savePDF(pw.Document pdf) async {
    try {
      if (kIsWeb) {
        return null;
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 30) {
            if (await Permission.manageExternalStorage.request().isGranted) {
              final directory = Directory('/storage/emulated/0/Download');
              final String filePath = '${directory.path}/ppd_reports.pdf';
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
                final String filePath = '${directory.path}/ppd_reports.pdf';
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
          final String filePath = '${directory.path}/ppd_reports.pdf';
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
