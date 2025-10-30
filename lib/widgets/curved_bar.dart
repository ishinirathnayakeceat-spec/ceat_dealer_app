import 'dart:ui';
import 'package:flutter/material.dart';

class CurvedBar extends StatelessWidget {
  final String title;
  final double value;
  final double comparisonValue;
  final double maxValue;
  final Color titleColor;
  final Color primaryColor;
  final Color secondaryColor;

  const CurvedBar({
    Key? key,
    required this.title,
    required this.value,
    required this.comparisonValue,
    required this.maxValue,
    this.titleColor = Colors.black,
    this.primaryColor = const Color(0xFFFFA726), // Orange 400
    this.secondaryColor = const Color(0xFFBF360C), // Deep Orange 900
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarWidth = screenWidth * 0.6;
    final targetWidth = (comparisonValue / maxValue) * maxBarWidth;
    final achievementWidth = (value / maxValue) * maxBarWidth;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBar(
                      width: achievementWidth,
                      label: "Achieved: ${value.toStringAsFixed(1)}",
                      isAchieved: true,
                    ),
                    const SizedBox(height: 8),
                    _buildBar(
                      width: targetWidth,
                      label: "Target: ${comparisonValue.toStringAsFixed(1)}",
                      isAchieved: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          height: 3,
          thickness: 3,
          color: Colors.white24,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  Widget _buildBar({
    required double width,
    required String label,
    required bool isAchieved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAchieved ? primaryColor : Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAchieved
                  ? [primaryColor, secondaryColor]
                  : [Colors.grey[600]!, Colors.grey[200]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
