import 'package:ceat_dealer_portal/services/target_month_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'curved_bar.dart';

class TargetMonthCard extends StatefulWidget {
  const TargetMonthCard({Key? key}) : super(key: key);

  @override
  State<TargetMonthCard> createState() => _TargetMonthCardState();
}

class _TargetMonthCardState extends State<TargetMonthCard> {
  final TargetMonthService _targetMonthService = TargetMonthService();

  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _targetMonthData = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _fetchTargetMonthData();
  }

  Future<void> _fetchTargetMonthData() async {
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

      final response = await _targetMonthService.getMaterialGroupPerformance(dealerCode);

      if (!mounted) return;

       if (response['data'] != null && response['data'] is List) {
        List<Map<String, dynamic>> filteredData = List<Map<String, dynamic>>.from(response['data'])
            .where((item) =>
                _parseToDouble(item['TotalTarget']) > 0 ||
                _parseToDouble(item['TotalAchievement']) > 0 
                )
            .toList();

        setState(() {
          _targetMonthData = filteredData;
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
        _errorMessage = 'Error fetching target-month data: $e';
        _isLoading = false;
      });
    }
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

  void _showTooltip(BuildContext context,GlobalKey key, String title, double target, double achievement) {

    final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
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
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(8),
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Achievement: $achievement",
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Target: $target", 
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ]
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
    // final double maxDataValue = _targetMonthData.isNotEmpty
    //     ? _targetMonthData
    //         .map((item) => _parseToDouble(item['TotalAchievement']).clamp(0.0, double.infinity))
    //         .reduce((a, b) => a > b ? a : b)
    //     : 0.0;

    final double maxDataValue = _targetMonthData.isNotEmpty
        ? _targetMonthData
            .map((item) => [
              _parseToDouble(item['TotalAchievement'])
              ].where((value) => value.isFinite).reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a > b ? a : b)
        : 0.0;

        

    return GestureDetector(
      onTap: () {
        _removeOverlay(); 
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.only(top: 16, bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
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
                    : _targetMonthData.isEmpty
                        ? const Center(child: Text('No data available', style: TextStyle(color: Colors.white)))
                    : Column(
                        children: _targetMonthData.map((item) {
                          final GlobalKey barKey = GlobalKey();
                          return GestureDetector(
                            onTapDown: (details) {
                              _showTooltip(
                                context,
                                barKey,
                                item['materialName'] ?? '',
                                _parseToDouble(item['TotalTarget']),
                                _parseToDouble(item['TotalAchievement']),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CurvedBar(
                                key: barKey,
                                title: item['materialName'] ?? '',
                                value: _parseToDouble(item['TotalAchievement']),
                                comparisonValue: _parseToDouble(item['TotalTarget']),
                                maxValue: maxDataValue,
                                primaryColor: Colors.black,
                                secondaryColor: const Color(0xFF01579B),
                                titleColor: Colors.white,
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
    super.dispose();
  }
}