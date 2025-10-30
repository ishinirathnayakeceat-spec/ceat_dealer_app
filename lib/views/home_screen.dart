// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/side_menu_widget.dart';
import '../widgets/header_card_widget.dart';
import '../widgets/summary_details.dart';
import 'achievements_screen.dart';
import 'finance_screen.dart';
import 'operation_screen.dart';
import 'promotion_screen.dart';
import 'profile_file.dart';
import '../services/credit_service.dart';
import '../services/summary_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CreditService _creditService = CreditService();
  final SummaryService _summaryService = SummaryService();
  double _creditLimit = 0.0;
  bool _isLoadingCredit = true;

  Map<String, dynamic>? summaryData;
  bool _isLoadingSummary = true;

  final Color mainColor = const Color(0xFF154FA3);
  final Color secondaryColor = const Color(0xFFEF7300);
  final Color accentColor = const Color(0xFF000000);
  final Color accentColor2 = const Color(0xFFFFFFFF);

  int _currentIndex = 0;

  String? zsDelCode;

  @override
  void initState() {
    super.initState();

    _loadDealerCode().then((_) {
      if (zsDelCode != null) {
        _loadCreditLimit();
        _loadSummaryData();
      }
    });
  }

  Future<void> _loadDealerCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      zsDelCode = prefs.getString('dealerCode');
    });
  }

  Future<void> _loadCreditLimit() async {
    if (zsDelCode == null) return;

    try {
      final limit = await _creditService.getCreditLimit(zsDelCode!);
      setState(() {
        _creditLimit = limit;
        _isLoadingCredit = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCredit = false;
      });
    }
  }

  Future<void> _loadSummaryData() async {
    if (zsDelCode == null) return;

    try {
      final data = await _summaryService.getSummaryDetails(zsDelCode!);
      setState(() {
        summaryData = data;
        _isLoadingSummary = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSummary = false;
      });
    }
  }

  String _calculateBalanceDue() {
    if (summaryData == null) return '0';

    double actualOutstanding = double.tryParse(
            summaryData!['actual_outstanding']?.toString() ?? '0') ??
        0;
    double balanceCrNotes = double.tryParse(
            summaryData!['balance_of_cr_notes_adv']?.toString() ?? '0') ??
        0;
    double days45 =
        double.tryParse(summaryData!['days_45']?.toString() ?? '0') ?? 0;

    double balanceDueValue = (actualOutstanding + balanceCrNotes) - days45;

    return balanceDueValue.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const SideMenuWidget(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (zsDelCode != null) HeaderCardWidget(zsDelCode: zsDelCode!),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: "Balance Due",
                      value: _isLoadingSummary
                          ? 'Loading...'
                          : _calculateBalanceDue(),
                      icon: Icons.account_balance_wallet_outlined,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: "Credit Limit",
                      value: _isLoadingCredit
                          ? 'Loading...'
                          : _creditLimit.toStringAsFixed(0).replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              ),
                      icon: Icons.credit_card,
                      color: secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 5),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionButton(
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
                  _buildActionButton(
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
                  _buildActionButton(
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
                  _buildActionButton(
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
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "Dealer Summary Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SummaryDetails(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.orange,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              // Use push() instead of pushReplacement()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (_currentIndex == 1) {
              // Use push() instead of pushReplacement()
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsPage(),
                ),
              );
            }
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: _modernIcon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _modernIcon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _modernIcon(IconData icon) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _currentIndex == 0
            ? mainColor.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 30,
        color: _currentIndex == 0 ? mainColor : const Color(0xFFEF7300),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        double cardHeight = cardWidth * 0.8;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.9),
                color.withOpacity(0.9),
                Colors.black.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: accentColor2),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: accentColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: accentColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.9),
              mainColor.withOpacity(0.9),
              Colors.black.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: secondaryColor),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                  color: accentColor2,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
