import 'package:ceat_dealer_portal/views/achievements_screen.dart';
import 'package:ceat_dealer_portal/views/calendar_screen.dart';
import 'package:ceat_dealer_portal/views/finance_screen.dart';
import 'package:ceat_dealer_portal/views/operation_screen.dart';
import 'package:ceat_dealer_portal/views/profile_file.dart';
import 'package:ceat_dealer_portal/views/promotion_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ceat_dealer_portal/views/login_screen.dart';
import 'package:ceat_dealer_portal/views/target_achievement_screen.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernDrawerItem(
                    icon: Icons.person_outline,
                    label: "Profile Settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileSettingsPage()),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    icon: Icons.receipt_long,
                    label: "Finance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FinanceScreen()),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    icon: Icons.star_border,
                    label: "Achievements",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AchievementsScreen()),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    icon: Icons.business_center,
                    label: "Operations",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OperationScreen()),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    icon: Icons.local_offer,
                    label: "Promotions",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PromotionScreen()),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    icon: Icons.calendar_today,
                    label: "Calendar",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarScreen(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('dealerCode');
                      await prefs.remove('email');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF003566),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder(
      future: _getUserInfo(),
      builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading user info"));
        } else {
          final userInfo = snapshot.data!;
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF003566),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userInfo['dealerCode'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userInfo['email'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFADB5BD),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, String>> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dealerCode = prefs.getString('dealerCode');
    String? email = prefs.getString('email');
    return {
      'dealerCode': dealerCode ?? 'N/A',
      'email': email ?? '',
    };
  }

  Widget _buildModernDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, color: const Color(0xFFEF7300)),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
