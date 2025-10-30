import 'package:flutter/material.dart';
import 'package:ceat_dealer_portal/views/payment_history_screen.dart';
import 'package:ceat_dealer_portal/views/outstanding_report_screen.dart'; // Import the new screen
import '../widgets/finance_option_card.dart';

class MonthlyStatementsScreen extends StatefulWidget {
  const MonthlyStatementsScreen({super.key});

  @override
  _MonthlyStatementsScreenState createState() =>
      _MonthlyStatementsScreenState();
}

class _MonthlyStatementsScreenState extends State<MonthlyStatementsScreen> {
  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3); // Dark Blue
    const Color secondaryColor = Color(0xFFEF7300); // Orange
    const Color accentColor2 = Color(0xFFFFFFFF); // White

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor,
        title: const Text(
          "Monthly Statements",
          style: TextStyle(color: accentColor2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentColor2),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16), 
            Expanded(
              child: ListView(
                children: [
                  FinanceOptionCard(
                    icon: Icons.history,
                    label: "Payment History",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentHistoryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FinanceOptionCard(
                    icon: Icons.warning_amber_outlined,
                    label: "Outstanding",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const OutstandingReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
