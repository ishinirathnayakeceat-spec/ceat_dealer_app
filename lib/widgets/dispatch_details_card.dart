import 'package:flutter/material.dart';

class DispatchDetailCardWidget extends StatelessWidget {
  final Map<String, String> dispatchDetails;
  final String dispatch_no;
  const DispatchDetailCardWidget({
    super.key,
    required this.dispatchDetails,
    required this.dispatch_no,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Dispatch Number", dispatch_no),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Invoice No", dispatchDetails['invoice_no'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow(
                "Invoice Date", dispatchDetails['invoice_date'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow(
                "Product Code", dispatchDetails['product_code'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow(
                "Product Des.", dispatchDetails['description'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Quantity", dispatchDetails['quantity'] ?? ''),
            // const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            // _buildDetailRow("Defect", claimDetail['defect'] ?? ''),
            // const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            // _buildDetailRow("Invoice Number", claimDetail['invoiceNumber'] ?? ''),
            // const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            // _buildDetailRow("Invoice Date", claimDetail['invoiceDate'] ?? ''),
            // const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            // _buildDetailRow("Billing Type", claimDetail['billingType'] ?? ''),
            // const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            // _buildDetailRow("Offer Value", claimDetail['offerValue'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.visible,
                maxLines: null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
