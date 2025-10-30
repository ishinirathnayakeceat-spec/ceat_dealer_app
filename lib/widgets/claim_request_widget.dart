import 'package:flutter/material.dart';
import '../views/claim_request_details_screen.dart';

class ClaimRequestWidget extends StatelessWidget {
  final String tyreId;
  final String receivedDate;
  final String tyreSize;
  final String tyreSerialNumber;
  final String estimatedNonSkidDepth;
  final String defectType;
  final List<Map<String, dynamic>> images;

  const ClaimRequestWidget({
    super.key,
    required this.tyreId,
    required this.receivedDate,
    required this.tyreSize,
    required this.tyreSerialNumber,
    required this.estimatedNonSkidDepth,
    required this.defectType,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    const Color secondaryColor = Color(0xFFEF7300); // Orange
    const Color accentColor = Color(0xFF000000); // Black

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.9),
            secondaryColor.withOpacity(0.9),
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
          _buildSummaryRow("Tyre Size", tyreSize),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          _buildSummaryRow("Serial Number", tyreSerialNumber),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          _buildSummaryRow("Received Date", receivedDate),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          const SizedBox(height: 16),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.9),
                    secondaryColor.withOpacity(0.9),
                    accentColor.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaimRequestDetailsScreen(
                        tyreId: tyreId,
                        receivedDate: receivedDate,
                        tyreSize: tyreSize,
                        tyreSerialNumber: tyreSerialNumber,
                        estimatedNonSkidDepth: estimatedNonSkidDepth,
                        defectType: defectType,
                        images: images,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
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
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
