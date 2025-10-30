import 'package:flutter/material.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceNumber;
  final String documentDate;
  final String documentType;
  final String amount;
  final String deliveryDate;
  final String dueDate;
  final String daysDue;
  final String chequeNo;
  final String chequeAmount;
  final String chequeDepositDate;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceNumber,
    required this.documentDate,
    required this.documentType,
    required this.amount,
    required this.deliveryDate,
    required this.dueDate,
    required this.daysDue,
    required this.chequeNo,
    required this.chequeAmount,
    required this.chequeDepositDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Due Invoice Details",
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF000000).withOpacity(0.9),
                        const Color(0xFF154FA3).withOpacity(0.9),
                        const Color(0xFF000000).withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 8),
                          Text(
                            "Invoice Details",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow("Invoice Number", invoiceNumber),
                      _buildDivider(),
                      _buildDetailRow("Document Date", documentDate),
                      _buildDivider(),
                      _buildDetailRow("Document Type", documentType),
                      _buildDivider(),
                      _buildDetailRow("Amount", amount),
                      _buildDivider(),
                      _buildDetailRow("Delivery Date", deliveryDate),
                      _buildDivider(),
                      _buildDetailRow("Due Date", dueDate),
                      _buildDivider(),
                      _buildDetailRow("Days Due", daysDue),
                      _buildDivider(),
                      _buildDetailRow("Cheque No", chequeNo),
                      _buildDivider(),
                      _buildDetailRow("Cheque Amount", chequeAmount),
                      _buildDivider(),
                      _buildDetailRow("Cheque Deposit Date", chequeDepositDate),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white54,
      thickness: 0.8,
      height: 24,
    );
  }
}
