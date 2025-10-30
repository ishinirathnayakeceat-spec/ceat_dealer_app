import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../services/ppd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PPDReportScreen extends StatefulWidget {
  final String yearMonth;
  final List<dynamic> details;

  const PPDReportScreen({
    Key? key,
    required this.yearMonth,
    required this.details,
  }) : super(key: key);

  @override
  _PPDReportScreenState createState() => _PPDReportScreenState();
}

class _PPDReportScreenState extends State<PPDReportScreen> {
  bool isGeneratingPdf = false;
  final PPDService _ppdService = PPDService();

  Future<void> _generatePDF() async {
    if (widget.details.isNotEmpty) {
      setState(() => isGeneratingPdf = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final dealerCode = prefs.getString('dealerCode') ?? '';

        final pdfPath = await _ppdService.generatePDF(
          widget.yearMonth,
          widget.details,
          dealerCode,
        );

        if (!mounted) return;

        if (pdfPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report downloaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          OpenFilex.open(pdfPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report download failed!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isGeneratingPdf = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to generate PDF.')),
      );
    }
  }

  Widget _buildPaginatedTable(List<dynamic> data) {
    return PaginatedDataTable(
      columns: const [
        DataColumn(label: Text('Invoice Number')),
        DataColumn(label: Text('Invoice Date')),
        DataColumn(label: Text('PPD Cal Date')),
        DataColumn(label: Text('Due Date')),
        DataColumn(label: Text('Invoice Amount')),
        DataColumn(label: Text('Acc.Posting Date')),
        DataColumn(label: Text('Acc.Ref.Doc Number')),
        DataColumn(label: Text('Settle Amount')),
        DataColumn(label: Text('PPD Amount')),
        DataColumn(label: Text('Penalty Amount')),
        DataColumn(label: Text('Net PPD Amount')),
      ],
      source: _PPDReportData(data),
      header: const Text(''),
      rowsPerPage: 10,
      columnSpacing: 12,
      horizontalMargin: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3);
    const Color accentColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          "PPD Report - ${widget.yearMonth}",
          style: const TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isGeneratingPdf
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "PPD Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _generatePDF,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF000000).withOpacity(0.9),
                                  const Color(0xFFEF7300).withOpacity(0.9),
                                  const Color(0xFF000000).withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: const Text(
                              'Download Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPaginatedTable(widget.details),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PPDReportData extends DataTableSource {
  final List<dynamic> data;
  int? _selectedIndex;

  _PPDReportData(this.data);

  @override
  DataRow getRow(int index) {
    if (index >= data.length) return null!;
    final item = data[index];

    return DataRow(
      selected: _selectedIndex == index,
      onSelectChanged: (isSelected) {
        if (isSelected == true) {
          _selectedIndex = index;
          notifyListeners();
        }
      },
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFFEF7300).withOpacity(0.5);
          }
          return null;
        },
      ),
      cells: [
        DataCell(Text(item['Invoice Number']?.toString() ?? '')),
        DataCell(Text(item['Invoice Date']?.toString() ?? '')),
        DataCell(Text(item['PPD Cal Date']?.toString() ?? '')),
        DataCell(Text(item['Due Date']?.toString() ?? '')),
        DataCell(Text(NumberFormat('#,##0.00').format(
          double.parse(item['Invoice Amount'].toString()),
        ))),
        DataCell(Text(item['Acc.Posting Date']?.toString() ?? '')),
        DataCell(Text(item['Acc.Ref.Doc Number']?.toString() ?? '')),
        DataCell(Text(NumberFormat('#,##0.00').format(
          double.parse(item['Settle Amount'].toString()),
        ))),
        DataCell(Text(NumberFormat('#,##0.00').format(
          double.parse(item['PPD Amount'].toString()),
        ))),
        DataCell(Text(NumberFormat('#,##0.00').format(
          double.parse(item['Panalty Amount'].toString()),
        ))),
        DataCell(Text(NumberFormat('#,##0.00').format(
          double.parse(item['Net PPD Amount'].toString()),
        ))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedIndex != null ? 1 : 0;
}
