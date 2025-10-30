import 'package:flutter/material.dart';
import '../services/outstanding_report_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';

class OutstandingReportScreen extends StatefulWidget {
  const OutstandingReportScreen({super.key});

  @override
  _OutstandingReportScreenState createState() =>
      _OutstandingReportScreenState();
}

class _OutstandingReportScreenState extends State<OutstandingReportScreen> {
  List<dynamic> dueInvoices = [];
  List<dynamic> creditNotes = [];
  bool isLoading = false;
  String? dealerCode;

  @override
  void initState() {
    super.initState();
    _loadDealerCode();
  }

  Future<void> _loadDealerCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dealerCode = prefs.getString('dealerCode');
    if (dealerCode != null) {
      _fetchOutstandingReports();
    }
  }

  Future<void> _fetchOutstandingReports() async {
    if (dealerCode != null) {
      setState(() {
        isLoading = true;
      });
      try {
        final service = OutstandingReportService();
        final response = await service.fetchOutstandingReports(dealerCode!);
        setState(() {
          dueInvoices = response['dueInvoices'] ?? [];
          creditNotes = response['creditNotes'] ?? [];
          isLoading = false;
        });
      } catch (error) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching reports: $error')),
          );
        });
      }
    }
  }

  Future<void> _downloadReport() async {
    if (dueInvoices.isNotEmpty || creditNotes.isNotEmpty) {
      final service = OutstandingReportService();
      try {
        String? filePath = await service.generatePdfReport(
          dueInvoices,
          creditNotes,
          dealerCode ?? 'N/A',
        );
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report downloaded successfully!')),
          );
          OpenFilex.open(filePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report download failed!')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download report: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to download.')),
      );
    }
  }

  String formatDate(String? date) {
    if (date == null) return 'N/A';
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.toLocal()}'.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3);
    const Color accentColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Outstanding Reports",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
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
      body: isLoading
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
                          "Due Invoices",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: _downloadReport,
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
                                horizontal: 12, vertical: 8),
                            child: const Text(
                              'Download Report',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _buildPaginatedTable(dueInvoices),
                    const SizedBox(height: 10),
                    const Text(
                      "Others",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    _buildCreditNotesTable(creditNotes),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaginatedTable(List<dynamic> data) {
    return PaginatedDataTable(
      columns: const [
        DataColumn(label: Text('Doc Date')),
        DataColumn(label: Text('Doc No')),
        DataColumn(label: Text('Doc Type')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Del Date')),
        DataColumn(label: Text('30 Due')),
        DataColumn(label: Text('Due Date')),
        DataColumn(label: Text('Days Due')),
        DataColumn(label: Text('Chq No')),
        DataColumn(label: Text('Chq Amt')),
        DataColumn(label: Text('Chq Dep Date')),
      ],
      source: _OutstandingReportData(data, formatDate),
      header: const Text(''),
      rowsPerPage: 5,
      columnSpacing: 12,
      horizontalMargin: 10,
    );
  }

  Widget _buildCreditNotesTable(List<dynamic> data) {
    return PaginatedDataTable(
      columns: const [
        DataColumn(label: Text('Doc Date')),
        DataColumn(label: Text('Doc No')),
        DataColumn(label: Text('Doc Type')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Description')),
        DataColumn(label: Text('Reference')),
      ],
      source: _CreditNotesData(data, formatDate),
      header: const Text(''),
      rowsPerPage: 5,
      columnSpacing: 12,
      horizontalMargin: 10,
    );
  }
}

class _OutstandingReportData extends DataTableSource {
  final List<dynamic> data;
  final String Function(String?) formatDate;
  int? _selectedIndex;
  _OutstandingReportData(this.data, this.formatDate);

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
        DataCell(Text(formatDate(item['docDate']))),
        DataCell(Text(item['docNo'] ?? 'N/A')),
        DataCell(Text(item['docType'] ?? 'N/A')),
        DataCell(Text(item['amount']?.toString() ?? 'N/A')),
        DataCell(Text(formatDate(item['delDate']))),
        DataCell(Text(formatDate(item['dueDate30']))),
        DataCell(Text(formatDate(item['dueDate']))),
        DataCell(Text(item['daysDue']?.toString() ?? 'N/A')),
        DataCell(Text(item['chqNo'] ?? 'CNR')),
        DataCell(Text(item['chqAmt']?.toString() ?? 'N/A')),
        DataCell(Text(formatDate(item['chqDepDate']))),
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

class _CreditNotesData extends DataTableSource {
  final List<dynamic> data;
  final String Function(String?) formatDate;
  int? _selectedIndex;
  _CreditNotesData(this.data, this.formatDate);

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
        DataCell(Text(formatDate(item['docDate']))),
        DataCell(Text(item['docNo'] ?? 'N/A')),
        DataCell(Text(item['docType'] ?? 'N/A')),
        DataCell(Text(item['amount']?.toString() ?? 'N/A')),
        DataCell(Text(item['reason1'] ?? 'N/A')),
        DataCell(Text(item['reason2'] ?? 'N/A')),
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
