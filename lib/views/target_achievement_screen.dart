
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/target_month.dart';
import '../widgets/target_year.dart';

class TargetAchievementScreen extends StatefulWidget {
  const TargetAchievementScreen({Key? key}) : super(key: key);

  @override
  _TargetAchievementScreenState createState() =>
      _TargetAchievementScreenState();
}

class _TargetAchievementScreenState extends State<TargetAchievementScreen> {
  String _selectedOption = 'Month'; 

  @override
  Widget build(BuildContext context) {

     String currentMonth = DateFormat('MMMM').format(DateTime.now());
    String currentYear = DateFormat('yyyy').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3), 
        title: const Text(
          "Target Achievement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF000000).withOpacity(0.9),
                    const Color(0xFF154FA3).withOpacity(0.9),
                    const Color(0xFF154FA3).withOpacity(0.9),
                    const Color(0xFF000000).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOption('Month', '- $currentMonth'),
                  _buildOption('Year', '- $currentYear'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0), 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF000000).withOpacity(0.9),
                      const Color(0xFFEF7300).withOpacity(0.9),
                      const Color(0xFFEF7300).withOpacity(0.9),
                      const Color(0xFF000000).withOpacity(0.9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    Row(
                      children: [
                         const SizedBox(width: 4),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF154FA3), Colors.black],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Achievement",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
 ],
                    ),

                    
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                             gradient: LinearGradient(
                              colors: [Color(0xFF757575), Color(0xFFEEEEEE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Target",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            
            Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.5, 
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0), 
                child: _selectedOption == 'Month'
                    ? const TargetMonthCard()                
                    : const TargetYearCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option, String displayText) {
    bool isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = option; 
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.white70,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24), 
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF154FA3), Color(0xFF154FA3), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? Colors.black
              : Colors.white.withOpacity(0.1), 
        ),
        child: Row(
          children: [
            Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6), 
            Text(
              displayText,
              style: TextStyle(
                color: isSelected ? Colors.orange : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}