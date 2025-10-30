import 'package:flutter/material.dart';


const mainColor = Color(0xFF154FA3); 
const secondaryColor = Color(0xFFEF7300); 
const accentColor = Color(0xFF000000); 

Widget buildSummaryCard() {
  return Container(
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
        _buildSummaryRow("Actual Outstanding", "35,916,288.74"),
        const Divider(
          color: Colors.white54,
          thickness: 0.8,
          height: 24,
        ),
        _buildSummaryRow("Balance of Credit Notes", "0.00"),
        const Divider(
          color: Colors.white54,
          thickness: 0.8,
          height: 24,
        ),
        _buildSummaryRow(
            "Total of Cheques \nReceived (Not set off)", "35,916,288.74"),
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
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
