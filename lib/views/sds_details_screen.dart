import 'package:ceat_dealer_portal/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import '../widgets/ppd_card_widget.dart';

class SDSDetailsScreen extends StatefulWidget {
  const SDSDetailsScreen({super.key});

  @override
  State<SDSDetailsScreen> createState() => _SDSDetailsScreenState();
}

class _SDSDetailsScreenState extends State<SDSDetailsScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3), 
        title: const Text("SDS Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sdsData.length,
                itemBuilder: (context, index) {
                  final sds = sdsData[index];
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedIndex =
                                _expandedIndex == index ? null : index;
                          });
                        },
                        child: PPDCardWidget(
                          title: sds['quarter']!,
                          amount: sds['amount']!,
                        ),
                      ),
                      if (_expandedIndex == index)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF000000).withOpacity(0.9),
                                mainColor.withOpacity(0.9),
                                const Color(0xFF000000).withOpacity(0.9),
                              ],
                              
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildGradientButton(
                                label: "Download PDF",
                                icon: Icons.download,
                                onPressed: () {
                                  
                                },
                              ),
                              _buildGradientButton(
                                label: "View PDF",
                                icon: Icons.picture_as_pdf,
                                onPressed: () {
                                  
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000000).withOpacity(0.8),
            const Color(0xFF154FA3).withOpacity(0.8),
            const Color(0xFF000000).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent, 
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

const List<Map<String, String>> sdsData = [
  {"quarter": "Q1 2024", "amount": "Rs. 15,000"},
  {"quarter": "Q2 2024", "amount": "Rs. 12,500"},
  {"quarter": "Q3 2024", "amount": "Rs. 16,800"},
  {"quarter": "Q4 2024", "amount": "Rs. 14,200"},
];
