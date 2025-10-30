import 'package:flutter/material.dart';

class DetailsCard extends StatelessWidget {
  final Color secondaryColor;
  final VoidCallback onViewMore;
  final String zsmonth;
  final String totalQuantity;
  final String totalAmount;


  const DetailsCard({
    Key? key,
    required this.secondaryColor,
    required this.onViewMore,
    required this.zsmonth,
    required this.totalQuantity,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
                      colors: [
                      const Color(0xFF000000).withOpacity(0.9),
                      const Color(0xFFEF7300).withOpacity(0.8),
                      const Color(0xFF000000).withOpacity(0.9),
                      ], // orange-black gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:  Text(
                    zsmonth,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSummaryRow("Total Quantity", totalQuantity),
                const Divider(
                  color: Colors.white54,
                  thickness: 0.8,
                  height: 24,
                ),
                _buildSummaryRow("Total Purchases", totalAmount),
                const Divider(
                  color: Colors.white54,
                  thickness: 0.8,
                  height: 24,
                ),
                
                Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                      const Color(0xFF000000).withOpacity(0.6),
                      const Color(0xFFEF7300).withOpacity(0.6),
                      const Color(0xFF000000).withOpacity(0.6),
                      ], 
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: ElevatedButton(
                    onPressed: onViewMore, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "View More",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              ],
            ),
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
