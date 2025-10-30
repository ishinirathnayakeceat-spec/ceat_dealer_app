import 'package:ceat_dealer_portal/services/purchase_amt_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'curved_bar_list.dart';
import 'package:intl/intl.dart';


class AmountValueCard extends StatefulWidget {
  final String selectedYear;
  final String selectedMonth;

  AmountValueCard({
    Key? key,
    required this.selectedYear, 
    required this.selectedMonth, 
  }) : super(key: key);

  @override
  State<AmountValueCard> createState() => _AmountValueCardState();
}

class _AmountValueCardState extends State<AmountValueCard> {

  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  final PurchaseAmtService _purchaseAmtService = PurchaseAmtService();
   bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _purchaseAmtData = [];
   bool _isDisposed = false;
   int? _expandedIndex;


  @override
  void initState() {
    super.initState();
    _fetchPurchaseData();
  }

  Future<void> _fetchPurchaseData() async {
    if (widget.selectedYear.isNotEmpty && widget.selectedMonth.isNotEmpty) {
      await _fetchPurchaseAmtDatabySearch(widget.selectedYear,
                              (months.indexOf(widget.selectedMonth) + 1).toString(),);
    } else {
      await _fetchPurchaseAmtData();
    }
  }

  Future<void> _fetchPurchaseAmtData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Dealer code not found.';
        });
        return;
      }

      final response = await _purchaseAmtService.getPurchaseAmt(dealerCode);
      
      if (!mounted) return;

      if (response['data'] != null && response['data'] is List) {
        List<Map<String, dynamic>> filteredData = List<Map<String, dynamic>>.from(response['data'])
            .where((item) =>
                _parseToDouble(item['latestMonthAmount']) > 0 ||
                _parseToDouble(item['secondLatestMonthAmount']) > 0 ||
                _parseToDouble(item['thirdLatestMonthAmount']) > 0)
            .toList();

        setState(() {
          _purchaseAmtData = filteredData;
          _isLoading = false;
          _errorMessage = filteredData.isEmpty ? 'No data available.' : '';
        });
      } else {
        setState(() {
          _errorMessage = 'No purchase data available.';
          _isLoading = false;
        });
      }

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error fetching purchase data: $e';
        _isLoading = false;
      });
    }
  }

  
  //------search

  Future<void> _fetchPurchaseAmtDatabySearch(String year, String month) async {
    if (_isDisposed) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (_isDisposed) return;

      if (dealerCode == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Dealer code not found.';
        });
        return;
      }

      final response = await _purchaseAmtService.getPurchaseAmtBySearch(
        dealerCode,
        year,
        month,
      );

      if (_isDisposed || !mounted) return;

     if (response['data'] != null && response['data'] is List) {
        List<Map<String, dynamic>> filteredData = List<Map<String, dynamic>>.from(response['data'])
            .where((item) =>
                _parseToDouble(item['latestMonthAmount']) > 0 ||
                _parseToDouble(item['secondLatestMonthAmount']) > 0 ||
                _parseToDouble(item['thirdLatestMonthAmount']) > 0)
            .toList();

        setState(() {
                    _purchaseAmtData = filteredData;
          _isLoading = false;
          _errorMessage = filteredData.isEmpty ? 'No data available.' : '';
        });
      } else {
        setState(() {
          _errorMessage = 'No purchase data available.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _errorMessage = 'Error fetching purchase data: $e';
        _isLoading = false;
      });
    }
  }


  Map<String, String> calculateLabels() {
    String year = widget.selectedYear.isNotEmpty ? widget.selectedYear : DateFormat('yyyy').format(DateTime.now());
    String month = widget.selectedMonth.isNotEmpty ? widget.selectedMonth : DateFormat('MMMM').format(DateTime.now());

    DateTime selectedDate = DateFormat("yyyy-MMMM").parse("$year-$month");
    DateTime previousDate = DateTime(selectedDate.year, selectedDate.month - 1);

    return {
      "currentLabel": "$year-$month",
      "previousLabel": "${DateFormat("yyyy").format(previousDate)}-${DateFormat("MMMM").format(previousDate)}",
    };
  }


   double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      double? parsedValue = double.tryParse(value);
      return (parsedValue != null && parsedValue.isFinite) ? parsedValue : 0.0;
    } else if (value is num) {
      return value.isFinite ? value.toDouble() : 0.0;
    }
    return 0.0;
  }


  OverlayEntry? _overlayEntry;

  void _showTooltip(
      BuildContext context,
      String title,
      double value,
      double comparisonValue,
      GlobalKey key,
      String currentLabel,
      String previousLabel,
      ) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

   
    _removeOverlay();

    
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              left: position.dx + renderBox.size.width / 2 - 75,
              top: position.dy - 80,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent, 
                child: TooltipCard(
                  title: title,
                  currentLabel: currentLabel,
                  previousLabel: previousLabel,
                  value: value,
                  comparisonValue: comparisonValue,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 10), _removeOverlay);
  }

   void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final double maxDataValue = _purchaseAmtData.isNotEmpty
    ? _purchaseAmtData
    .map((item) => [
                _parseToDouble(item['latestMonthAmount']).clamp(0.0, double.infinity),
                _parseToDouble(item['secondLatestMonthAmount']).clamp(0.0, double.infinity),
                _parseToDouble(item['thirdLatestMonthAmount']).clamp(0.0, double.infinity),
              ].reduce((a, b) => a > b ? a : b))
          .reduce((a, b) => a > b ? a : b)
      : 0.0;
          
    
    final labels = calculateLabels();

    return GestureDetector(
      onTap: _removeOverlay, 
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
         
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
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white)))
                    : _purchaseAmtData.isEmpty
                        ? const Center(child: Text('No data available', style: TextStyle(color: Colors.white)))
                    : Column(
                        children: _purchaseAmtData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final GlobalKey barKey = GlobalKey();
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedIndex = _expandedIndex == index ? null : index;
                              });
                            
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CurvedBar(
                                key: barKey,
                                title: item['materialName'] ?? '',
                                value: _parseToDouble(item['latestMonthAmount']),
                                comparisonValue: _parseToDouble(item['secondLatestMonthAmount']),
                                secondComparisonValue: _parseToDouble(item['thirdLatestMonthAmount']),
                                maxValue: maxDataValue,
                                primaryColor: Colors.black,
                                secondaryColor: const Color(0xFF01579B),
                                titleColor: Colors.white,
                                isExpanded: _expandedIndex == index,
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = _expandedIndex == index ? null : index;
                                  });
                                },
                                selectedYear: widget.selectedYear,
                                selectedMonth: widget.selectedMonth,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ),
        ),
      ),
    );
  }

   @override
  void dispose() {
    _removeOverlay();
    _isDisposed = true;
    super.dispose();
  }
}

class TooltipCard extends StatelessWidget {
  final String title;
  final String currentLabel;
  final String previousLabel;
  final double value;
  final double comparisonValue;

  const TooltipCard({
    Key? key,
    required this.title,
    required this.currentLabel,
    required this.previousLabel,
    required this.value,
    required this.comparisonValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4), 
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$currentLabel: ${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$previousLabel: ${comparisonValue.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
