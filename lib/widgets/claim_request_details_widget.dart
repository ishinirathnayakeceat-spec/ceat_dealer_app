import 'package:flutter/material.dart';

class ClaimRequestDetailsWidget extends StatelessWidget {
  final String tyreId;
  final String receivedDate;
  final String tyreSize;

  const ClaimRequestDetailsWidget({
    super.key,
    required this.tyreId,
    required this.receivedDate,
    required this.tyreSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow("Tyre ID", tyreId),
        _buildDetailRow("Received Date", receivedDate),
        _buildDetailRow("Tyre Size", tyreSize),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
