import 'package:flutter/material.dart';
import '../widgets/achievement_option_card.dart';
import 'ppd_details_screen.dart';
import 'sds_details_screen.dart';

class CommissionAchievementScreen extends StatelessWidget {
  const CommissionAchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3); // Dark Blue
    const Color secondaryColor = Color(0xFFEF7300); // Orange

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Commission Achievement",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30), 
            Expanded(
              child: ListView(
                children: [
                  AchievementOptionCard(
                    icon: Icons.attach_money,
                    label: "PPD",
                    gradientColors: [
                      Colors.black.withOpacity(0.8),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.8),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PPDDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // AchievementOptionCard(
                  //   icon: Icons.show_chart,
                  //   label: "SDS",
                  //   gradientColors: [
                  //     Colors.black.withOpacity(0.8),
                  //     mainColor.withOpacity(0.8),
                  //     Colors.black.withOpacity(0.8),
                  //   ],
                  //   iconBackgroundColor: secondaryColor,
                  //   onTap: () {
                  //     
                  //   },
                  // ),
                  const SizedBox(height: 16),
                  // AchievementOptionCard(
                  //   icon: Icons.card_giftcard,
                  //   label: "Other Incentives",
                  //   gradientColors: [
                  //     Colors.black.withOpacity(0.8),
                  //     mainColor.withOpacity(0.8),
                  //     Colors.black.withOpacity(0.8),
                  //   ],
                  //   iconBackgroundColor: secondaryColor,
                  //   onTap: () {
                     
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
