import 'package:ceat_dealer_portal/views/cheque_details_screen.dart';
import 'package:flutter/material.dart';
import 'monthly_statements_screen.dart';
import '../widgets/finance_option_card.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

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
          "Finance",
          style: TextStyle(color: accentColor2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentColor2),
      ),
      body: Container(
       
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16), 
            Expanded(
              child: ListView(
                children: [
                  FinanceOptionCard(
                    icon: Icons.calendar_today,
                    label: "Monthly Statements",
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
                          builder: (context) => const MonthlyStatementsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FinanceOptionCard(
                    icon: Icons.check_circle_outline,
                    label: "Cheque Details",
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
                          builder: (context) => const ChequeDetailsScreen(),
                        ),
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
