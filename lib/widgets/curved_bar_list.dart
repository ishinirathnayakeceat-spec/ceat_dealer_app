import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class CurvedBar extends StatefulWidget {
  final String title;
  final double value;
  final double comparisonValue;
  final double secondComparisonValue;
  final double maxValue;
  final Color titleColor;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? selectedYear;
  final String? selectedMonth;

  const CurvedBar({
    Key? key,
    required this.title,
    required this.value,
    required this.comparisonValue,
    required this.secondComparisonValue,
    required this.maxValue,
    this.titleColor = Colors.black,
    this.primaryColor = const Color(0xFFFFA726),
    this.secondaryColor = const Color(0xFFBF360C),
    required this.isExpanded,
    required this.onTap,
    this.selectedYear,
    this.selectedMonth,
  }) : super(key: key);

  @override
  _CurvedBarState createState() => _CurvedBarState();
}

class _CurvedBarState extends State<CurvedBar> {
  late String currentMonthYear;
  late String previousMonth;
  late String secondPreviousMonth;

  

  @override
  void initState() {
    super.initState();
    _calculateMonthNames();
  }

  void _calculateMonthNames() {
    DateTime baseDate = DateTime.now();
    
    // Use selected date if available
    if (widget.selectedYear != null && widget.selectedYear!.isNotEmpty &&
        widget.selectedMonth != null && widget.selectedMonth!.isNotEmpty) {
      final monthIndex = _getMonthIndex(widget.selectedMonth!);
      baseDate = DateTime(int.parse(widget.selectedYear!), monthIndex + 1);
    }

    DateTime previous = DateTime(baseDate.year, baseDate.month - 1);
    DateTime secondPrevious = DateTime(baseDate.year, baseDate.month - 2);

    currentMonthYear = DateFormat("yyyy MMM").format(baseDate);
    previousMonth = DateFormat("yyyy MMM").format(previous);
    secondPreviousMonth = DateFormat("yyyy MMM").format(secondPrevious);
  }

  int _getMonthIndex(String monthName) {
    return DateFormat('MMMM').parse(monthName).month - 1;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarWidth = screenWidth * 0.6;
    final valueWidth = (widget.value / widget.maxValue) * maxBarWidth;
    final comparisonWidth = (widget.comparisonValue / widget.maxValue) * maxBarWidth;
    final secondComparisonWidth = (widget.secondComparisonValue / widget.maxValue) * maxBarWidth;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: GestureDetector(
            onTap: widget.onTap,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: widget.titleColor,
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
                      _buildMainBar(valueWidth, widget.value, currentMonthYear),
                      if (widget.isExpanded) ...[
                        const SizedBox(height: 8),
                        _buildComparisonBar(comparisonWidth, widget.comparisonValue, previousMonth),
                        const SizedBox(height: 8),
                        _buildComparisonBar(secondComparisonWidth, widget.secondComparisonValue, secondPreviousMonth),
                      ],
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildMainBar(double width, double value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "$label: ${value.toStringAsFixed(1)}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.primaryColor, widget.secondaryColor],
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

  Widget _buildComparisonBar(double width, double value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "$label: ${value.toStringAsFixed(1)}",
            style:  TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[600]!, Colors.grey[200]!],
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
