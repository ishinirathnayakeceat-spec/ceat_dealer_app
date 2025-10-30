import 'package:ceat_dealer_portal/services/purchase_service.dart';
import 'package:ceat_dealer_portal/services/purchase_qty_service.dart';
import 'package:ceat_dealer_portal/views/Purchase_volume_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/qty_value_card.dart';
import '../widgets/amount_value_card.dart';
import '../widgets/details_card.dart';

class PurchaseVolumeScreen extends StatefulWidget {
  
  const PurchaseVolumeScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseVolumeScreen> createState() => _PurchaseVolumeScreenState();
}

class _PurchaseVolumeScreenState extends State<PurchaseVolumeScreen> {
  final Color mainColor = const Color(0xFF154FA3); // Dark Blue
  final Color secondaryColor = const Color(0xFFEF7300); // Orange
  final Color highlightCircleColor = const Color(0xFFFFE0B2); // Light Orange highlight

  final TextEditingController yearController = TextEditingController();
  final TextEditingController monthController = TextEditingController();

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  final PurchaseService _purchaseService = PurchaseService();



  bool _isLoading = true;
  List<dynamic> _purchaseData = [];
  String _errorMessage = "";

  bool _isDetailsCardVisible = false;
  bool _isQtyValueCardVisible = false;
  bool _isAmountValueCardVisible = false;

  String _currentMonthLabel = "";
  String _previousMonthLabel = "";
  String _secondPreviousMonthLabel = "";

  @override
  void initState() {
    super.initState();
    toggleDetailsCard();
    _fetchPurchaseData();
    
    
  }

  Future<void> _fetchPurchaseData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null) {
        final response = await _purchaseService.fetchPurchaseVolume(dealerCode);

        if (response['data'] != null) {
          setState(() {
            _purchaseData = response['data'];
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No Purchase Data found.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code not found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching Purchase Data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

Future<void> _fetchPurchaseDataBySearch(String year, String month) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null) {
        final response = await _purchaseService.getPurchaseVolume(dealerCode, year, month);

        if (response['data'] != null) {
          setState(() {
            _purchaseData = response['data'];
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No Purchase Data found.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code not found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching Purchase Data: $e';
      });
    }
  }


  Future<void> selectYear(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime day) => day.day == 1, 
    );
    if (pickedDate != null) {
      setState(() {
        yearController.text = pickedDate.year.toString();
        _updateMonthLabels();
      });
    }
  }

  void selectMonth(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: months.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(months[index]),
              onTap: () {
                setState(() {
                  monthController.text = months[index];
                  _updateMonthLabels();
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void toggleDetailsCard() {
    setState(() {
      _isDetailsCardVisible = !_isDetailsCardVisible;
     
      if (_isDetailsCardVisible) {
        _isQtyValueCardVisible = false;
        _isAmountValueCardVisible = false;
      }
    });
  }

  void toggleQtyValueCard() {
    setState(() {
      if (_isQtyValueCardVisible) {
        
        return;
      }
      _isQtyValueCardVisible = true;
      _isDetailsCardVisible = false;
      _isAmountValueCardVisible = false;
    });
  }

  
 void toggleAmountValueCard() {
    setState(() {
      if (_isAmountValueCardVisible) {
        
        return;
      }
      _isAmountValueCardVisible = true;
      _isDetailsCardVisible = false;
      _isQtyValueCardVisible = false;
    });
  }

  void resetForm() {
    yearController.clear();
    monthController.clear();
    setState(() {
      _isDetailsCardVisible = false;
      _isQtyValueCardVisible = false;
      _isAmountValueCardVisible = false;
      _purchaseData = [];
    });
    _fetchPurchaseData();
  }

   void _updateMonthLabels() {
    final DateTime now = DateTime.now();
    int year = yearController.text.isNotEmpty ? int.parse(yearController.text) : now.year;
    String selectedMonth = monthController.text.isNotEmpty ? monthController.text : DateFormat('MMMM').format(now);
    
    
    final DateTime baseDate = DateTime(
      year,
      months.indexOf(selectedMonth) + 1, 
    );

    
    final DateTime firstPrevious = DateTime(baseDate.year, baseDate.month - 1);
    final DateTime secondPrevious = DateTime(baseDate.year, baseDate.month - 2);

    setState(() {
      _currentMonthLabel = DateFormat('MMM yyyy').format(baseDate);
      _previousMonthLabel = DateFormat('MMM yyyy').format(firstPrevious);
      _secondPreviousMonthLabel = DateFormat('MMM yyyy').format(secondPrevious);
    });
  }

  Widget _buildIconButton({
   
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Colors.white, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : secondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
               
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? secondaryColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String formatZsMonth(String zsmonth) {
  if (zsmonth.length != 6) return "Invalid Date";

  String year = zsmonth.substring(0, 4); 
  String monthNumber = zsmonth.substring(4, 6); 

  
  int monthIndex = int.parse(monthNumber);
  if (monthIndex < 1 || monthIndex > 12) return "Invalid Month";

  String monthName = months[monthIndex - 1]; 

  return "$year - $monthName"; 
}

 Widget _buildMonthCircle({required String label, required Gradient gradient}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final circleSize = screenWidth * 0.07;
        final fontSize = screenWidth * 0.03;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize.clamp(24, 36),
              height: circleSize.clamp(24, 36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
            SizedBox(
              width: screenWidth * 0.2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize.clamp(12, 14),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "Quarter Comparison",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectYear(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: yearController,
                          decoration: InputDecoration(
                            labelText: "Year",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: Icon(Icons.calendar_today, color: secondaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectMonth(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: monthController,
                          decoration: InputDecoration(
                            labelText: "Month",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            prefixIcon: Icon(Icons.calendar_view_month, color: secondaryColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
          

          //----------------

        Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF000000).withOpacity(0.8),
                        const Color(0xFF154FA3).withOpacity(0.9),
                        const Color(0xFF154FA3).withOpacity(0.9),
                           const Color(0xFF000000).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (yearController.text.isNotEmpty && monthController.text.isNotEmpty) {
                                  _fetchPurchaseDataBySearch(
                                    yearController.text,
                                    (months.indexOf(monthController.text) + 1).toString(),
                                  );
                                } else {
                                  _fetchPurchaseData();
                                }
                                toggleDetailsCard();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isDetailsCardVisible ? secondaryColor : Colors.transparent,
                                side: BorderSide(color: secondaryColor),
                              ),
                              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Search By",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                toggleQtyValueCard();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isQtyValueCardVisible ? secondaryColor : Colors.transparent,
                                side: BorderSide(color: secondaryColor),
                              ),
                               child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Search By",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Qty",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                toggleAmountValueCard();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isAmountValueCardVisible ? secondaryColor : Colors.transparent,
                                side: BorderSide(color: secondaryColor),
                              ),
                              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Search By",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Amount",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                            ),
                          ),
                          SizedBox(
                            width: 130,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: resetForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide(color: secondaryColor),
                              ),
                              child: Text(
                                "Reset",
                                 textAlign: TextAlign.center,
                                style: TextStyle(color: secondaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),


          //------------------
              const SizedBox(height: 16),
              
               if (!_isQtyValueCardVisible && !_isAmountValueCardVisible && _purchaseData.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _purchaseData.length,
                  itemBuilder: (context, index) {
                    final purchaseData = _purchaseData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DetailsCard(
                        secondaryColor: secondaryColor,
                        onViewMore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseVolumeDetailsScreen(
                                zsmonth: formatZsMonth(purchaseData['zsmonth'] ?? "N/A"),
                                totalQuantity: purchaseData['totalQuantity'].toString(),
                                totalPurchases: purchaseData['totalAmount'].toString(),
                                purchaseList: purchaseData['materialGroups'],
                      
                              ),
                            ),
                          );
                        },
                        zsmonth: formatZsMonth(purchaseData['zsmonth'] ?? "N/A"),
                        totalQuantity: purchaseData['totalQuantity'].toString(),
                        totalAmount: purchaseData['totalAmount'].toString(),
                      ),
                    );
                    
                  },
                ),
                
               if (_isQtyValueCardVisible)
              SingleChildScrollView(
                 scrollDirection: Axis.vertical, 
                  child: QtyValueCard(
                    key: const ValueKey('qty_value_card'),
                    selectedYear: yearController.text,
                    selectedMonth: monthController.text,
            
                  )
                ),        

              if (_isAmountValueCardVisible)
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AmountValueCard(
                     key: const ValueKey('amount_value_card'),
                    selectedYear: yearController.text,
                    selectedMonth: monthController.text,
                  ),
                ),
              const SizedBox(height: 16),
              
            ],
          ),
        ),
      ),
    );
    
  }


  Widget _buildCustomButton(String option, bool isSelected, VoidCallback onPressed) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6), 
        ],
      ),
    );
  }


}

