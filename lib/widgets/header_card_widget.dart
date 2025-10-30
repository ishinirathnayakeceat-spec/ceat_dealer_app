import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/invoice_service.dart';
import '../views/invoice_list_screen.dart';

class HeaderCardWidget extends StatefulWidget {
  final String zsDelCode;

  const HeaderCardWidget({super.key, required this.zsDelCode});

  @override
  _HeaderCardWidgetState createState() => _HeaderCardWidgetState();
}

class _HeaderCardWidgetState extends State<HeaderCardWidget> {
  int dueInvoiceCount = 0;
  bool isLoading = true;
  bool hasError = false;

  final Color mainColor = const Color(0xFF154FA3);
  final Color secondaryColor = const Color(0xFFEF7300);

  @override
  void initState() {
    super.initState();
    fetchDueInvoiceCount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String getCurrentDate() {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat('dd-MM-yyyy').format(yesterday);
  }

  Future<void> fetchDueInvoiceCount() async {
    try {
      final invoiceService = InvoiceService();
      final response =
          await invoiceService.fetchDueInvoices(widget.zsDelCode.trim());
      if (!mounted) return;
      setState(() {
        dueInvoiceCount = response['dueInvoiceCount'] ?? 0;
        hasError = false;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching due invoice count: $e');
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InvoiceListScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.9),
              mainColor.withOpacity(0.9),
              Colors.black.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF003566),
              spreadRadius: 0,
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Due invoices as at",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getCurrentDate(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: hasError ? Colors.red : secondaryColor,
              radius: 20,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : hasError
                      ? const Icon(Icons.error, color: Colors.white)
                      : Text(
                          dueInvoiceCount.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
