import 'package:flutter/material.dart';

class ClaimStatusDetailCardWidget extends StatelessWidget {
  final String clNumber;
  final Map<String, dynamic> claimDetail;

  const ClaimStatusDetailCardWidget({
    super.key,
    required this.clNumber,
    required this.claimDetail,
  });

  @override
  Widget build(BuildContext context) {
   
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
            _buildDetailRow("CL-1 Number", clNumber),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Claim No", claimDetail['claimNo'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Material Des.", claimDetail['materialDescription'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Serial Number", claimDetail['serialNumber'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Tread Wear", claimDetail['treadWear'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Disposition", claimDetail['disposition'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Defect", claimDetail['defect'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Invoice Number", claimDetail['invoiceNumber'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Invoice Date", claimDetail['invoiceDate'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Billing Type", claimDetail['billingType'] ?? ''),
            const Divider(color: Colors.white54, thickness: 0.8, height: 24),
            _buildDetailRow("Offer Value", claimDetail['offerValue'] ?? ''),
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
