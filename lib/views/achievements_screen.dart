// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../widgets/achievement_option_card.dart';
import 'purchase_volume_screen.dart';
import 'target_achievement_screen.dart';
import 'commission_achievement_screen.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

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
          "Achievements",
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
            const SizedBox(height: 30), 
            Expanded(
              child: ListView(
                children: [
                  AchievementOptionCard(
                    icon: Icons.assessment,
                    label: "Quarter Comparison",
                    gradientColors: [
                      
                      const Color(0xFF000000).withOpacity(0.9),
                const Color(0xFF154FA3).withOpacity(0.9),
                const Color(0xFF000000).withOpacity(0.9), 
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PurchaseVolumeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AchievementOptionCard(
                    icon: Icons.stacked_bar_chart,
                    label: "Target Achievement",
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
                          builder: (context) => const TargetAchievementScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  AchievementOptionCard(
                    icon: Icons.monetization_on,
                    label: "Commission Achievement",
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
                          builder: (context) =>
                              const CommissionAchievementScreen(),
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
