import 'package:ceat_dealer_portal/views/view_claim_status_screen.dart';
import 'package:flutter/material.dart';

class ClaimCardWidget extends StatelessWidget {
  final String clNumber;
  final String receivedDate;
  final String totalReceivedQty;
  final Color secondaryColor;
  final Color accentColor;
  final List<Map<String, dynamic>> claimDetails;

  const ClaimCardWidget({
    super.key,
    required this.clNumber,
    required this.receivedDate,
    required this.totalReceivedQty,
    required this.secondaryColor,
    required this.accentColor,
    required this.claimDetails,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildSummaryRow("CL-1 Number", clNumber),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          _buildSummaryRow("Received Date", receivedDate),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          _buildSummaryRow("Total Received Qty", totalReceivedQty),
          const Divider(color: Colors.white54, thickness: 0.8, height: 24),
          const SizedBox(height: 16), 
          Center(
            child: Container(
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewClaimStatusScreen(
                          clNumber: clNumber,
                          claimDetails: claimDetails),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "View Claim Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
