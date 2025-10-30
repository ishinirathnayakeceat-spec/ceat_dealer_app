import 'package:flutter/material.dart';
//f
Widget _buildStatCard({
  required String label,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    decoration: BoxDecoration(
      color: color.withOpacity(1), 
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 30), 
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,

            
          ),
        ),
      ],
    ),
  );
}
