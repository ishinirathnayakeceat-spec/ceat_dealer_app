import 'package:flutter/material.dart';

class InvoiceCardWidget extends StatelessWidget {
  final String documentDate;
  final String invoiceNumber;
  final String daysDue;
  final String amount;
  final VoidCallback onTap;

  const InvoiceCardWidget({
    super.key,
    required this.documentDate,
    required this.invoiceNumber,
    required this.daysDue,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Invoice Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryRow("Document Date", documentDate),
              const Divider(
                color: Colors.white54,
                thickness: 0.8,
                height: 24,
              ),
              _buildSummaryRow("Invoice Number", invoiceNumber),
              const Divider(
                color: Colors.white54,
                thickness: 0.8,
                height: 24,
              ),
              _buildSummaryRow("Days Due", daysDue),
              const Divider(
                color: Colors.white54,
                thickness: 0.8,
                height: 24,
              ),
              _buildSummaryRow("Amount", amount),
            ],
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
