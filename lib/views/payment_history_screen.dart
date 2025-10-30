import 'package:flutter/material.dart';
import '../services/payment_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentHistoryService service = PaymentHistoryService();
  String? _zsDelCode;
  List<dynamic> results = [];
  bool isLoading = true;
  String _message = '';
  bool showAllData = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
  }

  Future<void> _loadPaymentHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _zsDelCode = prefs.getString('dealerCode');

    if (_zsDelCode != null) {
      try {
        final history = await service.fetchPaymentHistory(_zsDelCode!);
        setState(() {
          results = history;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          _message = 'Error fetching payment history: $e';
          isLoading = false;
        });
      }
    }
  }

  final Color secondaryColor = const Color(0xFFEF7300); // Orange
  final Color accentColor = const Color(0xFF000000); // Black

  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController paymentNoController = TextEditingController();

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          if (toDate != null && pickedDate.isAfter(toDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("From date cannot be after To date")),
            );
          } else {
            fromDate = pickedDate;
            fromDateController.text = formatDate(fromDate);
          }
        } else {
          if (fromDate != null && pickedDate.isBefore(fromDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("To date cannot be before From date")),
            );
          } else {
            toDate = pickedDate;
            toDateController.text = formatDate(toDate);
          }
        }
      });
    }
  }

  // Search function
  Future<void> searchPayments() async {
    if (_zsDelCode != null) {
      String paymentNo = paymentNoController.text;
      String fromDateStr = fromDate != null ? fromDateController.text : '';
      String toDateStr = toDate != null ? toDateController.text : '';

      try {
        final searchResults = await service.searchPaymentHistory(
            _zsDelCode!, paymentNo, fromDateStr, toDateStr);
        setState(() {
          results = searchResults;
          _message = results.isEmpty ? 'No results found' : '';
          showAllData = false;
        });
      } catch (e) {
        setState(() {
          _message = 'Error searching payment history: $e';
        });
      }
    }
  }

  void resetForm() {
    setState(() {
      paymentNoController.clear();
      fromDateController.clear();
      toDateController.clear();
      fromDate = null;
      toDate = null;
      showAllData = true;
      _message = '';
    });
  }

  // void toggleExpand() {
  //   setState(() {
  //     showAllData = !showAllData;
  //     if (showAllData) {
  //       resetForm();
  //       _loadPaymentHistory();
  //     } else {
  //       results.clear();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Payment History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            // : results.isEmpty
            //     ? Center(
            //         child: Text(_message.isNotEmpty
            //             ? _message
            //             : "No payment history found."),
            //       )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: TextField(
                          controller: paymentNoController,
                          decoration: InputDecoration(
                            labelText: "Payment No",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: Icon(
                              Icons.payment,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => selectDate(context, true),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: fromDateController,
                              decoration: InputDecoration(
                                labelText: "From",
                                filled: true,
                                fillColor: Colors.white,
                                hintText: formatDate(fromDate),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: Icon(
                                  Icons.date_range,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () => selectDate(context, false),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: toDateController,
                              decoration: InputDecoration(
                                labelText: "To",
                                filled: true,
                                fillColor: Colors.white,
                                hintText: formatDate(toDate),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                prefixIcon: Icon(
                                  Icons.date_range,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: searchPayments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                        ),
                        child: const Text(
                          "Search",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 5),
                      OutlinedButton(
                        onPressed: () {
                          resetForm();
                          _loadPaymentHistory();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: secondaryColor),
                        ),
                        child: Text(
                          showAllData ? "Reset" : "Reset",
                          style: TextStyle(color: secondaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  // Display message if no results found
                  // Display message if no results found
                  if (!showAllData && _message.isNotEmpty)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // You can add any action here, like dismissing the message
                          setState(() {
                            _message = ''; // Clear the message when tapped
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: secondaryColor
                                .withOpacity(0.1), // Light red background
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _message,
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: showAllData ? results.length : results.length,
                      itemBuilder: (context, index) {
                        final paymentHistory = results[index];
                        return PaymentCardWidget(
                          paymentNo: paymentHistory['paymentNo'] ?? 'N/A',
                          chequeNo: paymentHistory['chequeNo'] ?? 'N/A',
                          receivedDate:
                              formatDateOnly(paymentHistory['receivedDate']),
                          receivedAmount:
                              paymentHistory['receivedAmount']?.toString() ??
                                  'N/A',
                          returnDate:
                              formatDateOnly(paymentHistory['returnDate']),
                          secondaryColor: secondaryColor,
                          accentColor: accentColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String formatDateOnly(String? dateTime) {
    if (dateTime == null) return 'N/A';
    DateTime date = DateTime.parse(dateTime);
    return "${date.year}-${date.month}-${date.day}";
  }
}

class PaymentCardWidget extends StatelessWidget {
  final String paymentNo;
  final String chequeNo;
  final String receivedDate;
  final String receivedAmount;
  final String returnDate;
  final Color secondaryColor;
  final Color accentColor;

  const PaymentCardWidget({
    super.key,
    required this.paymentNo,
    required this.chequeNo,
    required this.receivedDate,
    required this.receivedAmount,
    required this.returnDate,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.9),
              secondaryColor.withOpacity(0.8),
              accentColor.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow("Payment No", paymentNo),
            const Divider(
              color: Colors.white54,
              thickness: 0.8,
              height: 24,
            ),
            _buildSummaryRow("Cheque No", chequeNo),
            const Divider(
              color: Colors.white54,
              thickness: 0.8,
              height: 24,
            ),
            _buildSummaryRow("Received Date", receivedDate),
            const Divider(
              color: Colors.white54,
              thickness: 0.8,
              height: 24,
            ),
            _buildSummaryRow("Received Amount", receivedAmount),
            const Divider(
              color: Colors.white54,
              thickness: 0.8,
              height: 24,
            ),
            _buildSummaryRow("Return Date", returnDate),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
