import 'package:flutter/material.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String InvNo;
  final String paymentReturnNo;
  final String InvAmount;

  const InvoiceDetailScreen({
    super.key,
    required this.InvNo,
    required this.paymentReturnNo,
    required this.InvAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Invoice Details",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), 
                  blurRadius: 12, 
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0), 
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Payment Return No", paymentReturnNo),
                const Divider(
                  color: Colors.white54,
                  thickness: 0.8,
                  height: 24,
                ),
                _buildSummaryRow("Invoice No", InvNo),
                const Divider(
                  color: Colors.white54,
                  thickness: 0.8,
                  height: 24,
                ),
                _buildSummaryRow("Amount", InvAmount),
                const Divider(
                  color: Colors.white54,
                  thickness: 0.8,
                  height: 24,
                ),
              ],
            ),
          ),
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
}
