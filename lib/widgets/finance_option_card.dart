import 'package:flutter/material.dart';

class FinanceOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;
  final List<Color> gradientColors;
  final Color iconBackgroundColor; 

  const FinanceOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradientColors,
    this.iconBackgroundColor = Colors.transparent, 
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFFFFFFFF); 
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBackgroundColor, 
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12.0), 
              child:
                  Icon(icon, size: 30, color: accentColor), 
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, color: accentColor),
          ],
        ),
      ),
    );
  }
}
