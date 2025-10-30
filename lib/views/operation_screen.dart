import 'package:ceat_dealer_portal/views/Claim_request_screen.dart';
import 'package:ceat_dealer_portal/views/claim_status_screen.dart';
import 'package:ceat_dealer_portal/views/dispatch_order_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:ceat_dealer_portal/widgets/operation_option_card.dart';

class OperationScreen extends StatelessWidget {
  const OperationScreen({super.key});

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
          "Operations",
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
                  OperationOptionCard(
                    icon: Icons.assignment_turned_in_outlined,
                    label: "Claim Status",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      // Navigate to Claim Status Screen (to be implemented)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClaimStatusScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OperationOptionCard(
                    icon: Icons.local_shipping_outlined,
                    label: "Dispatch Order Status",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      // Navigate to Dispatch Order Status Screen (to be implemented)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DispatchOrderStatusScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  OperationOptionCard(
                    icon: Icons.fact_check,
                    label: "Claim Request",
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
                          builder: (context) => const ClaimRequestScreen(),
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
