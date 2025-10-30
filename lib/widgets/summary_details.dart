import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/summary_service.dart';

class SummaryDetails extends StatefulWidget {
  const SummaryDetails({super.key});

  @override
  _SummaryDetailsState createState() => _SummaryDetailsState();
}

class _SummaryDetailsState extends State<SummaryDetails> {
  final SummaryService _summaryService = SummaryService();
  Map<String, dynamic>? summaryData;
  Map<String, dynamic>? totalCheques;
  String? zsDelCode;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDealerCodeAndFetchData();
  }

  Future<void> _loadDealerCodeAndFetchData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        zsDelCode = prefs.getString('dealerCode');
      });

      if (zsDelCode != null) {
        final results = await Future.wait([
          _summaryService.getSummaryDetails(zsDelCode!),
          _summaryService.getTotalChequesReceived(zsDelCode!),
        ]);

        setState(() {
          summaryData = results[0];
          totalCheques = results[1];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load summary details: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFF154FA3);
    const secondaryColor = Color(0xFFEF7300);
    const accentColor = Color(0xFF000000);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Text(errorMessage, style: const TextStyle(color: Colors.red));
    }

    return DealerSummaryCard(
      mainColor: mainColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      actualOutstanding: summaryData?['actual_outstanding']?.toString() ?? '0',
      balance: summaryData?['balance_of_cr_notes_adv']?.toString() ?? '0',
      totalCheques: totalCheques?['total_cheques']?.toString() ?? '0',
      days45: summaryData?['days_45']?.toString() ?? '0',
      days60: summaryData?['days_60']?.toString() ?? '0',
      days90: summaryData?['days_90']?.toString() ?? '0',
      days120: summaryData?['days_120']?.toString() ?? '0',
      days180: summaryData?['days_180']?.toString() ?? '0',
      moreThan180: summaryData?['more_than_180']?.toString() ?? '0',
      creditNotesTotal: summaryData?['credit_notes_total']?.toString() ?? '0',
      balanceAmountTotal:
          summaryData?['balance_amount_total']?.toString() ?? '0',
    );
  }
}

class DealerSummaryCard extends StatefulWidget {
  final Color mainColor;
  final Color secondaryColor;
  final Color accentColor;
  final String actualOutstanding;
  final String balance;
  final String totalCheques;
  final String days45;
  final String days60;
  final String days90;
  final String days120;
  final String days180;
  final String moreThan180;
  final String creditNotesTotal;
  final String balanceAmountTotal;

  const DealerSummaryCard({
    super.key,
    required this.mainColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.actualOutstanding,
    required this.balance,
    required this.totalCheques,
    required this.days45,
    required this.days60,
    required this.days90,
    required this.days120,
    required this.days180,
    required this.moreThan180,
    required this.creditNotesTotal,
    required this.balanceAmountTotal,
  });

  @override
  State<DealerSummaryCard> createState() => _DealerSummaryCardState();
}

class _DealerSummaryCardState extends State<DealerSummaryCard> {
  bool _showActualOutstandingDetails = false;
  bool _showBalanceDetails = false;

  String _formatCurrency(String value) {
    try {
      final number = double.parse(value);
      final absNumber = number.abs();
      final formatted = absNumber.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
      return '${number < 0 ? '-' : ''} $formatted';
    } catch (e) {
      return value;
    }
  }

  Widget _buildExpandableRow(
      String label, String value, bool isExpanded, List<Widget> children) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (label.contains('Actual Outstanding')) {
                _showActualOutstandingDetails = !_showActualOutstandingDetails;
                _showBalanceDetails = false;
              } else {
                _showBalanceDetails = !_showBalanceDetails;
                _showActualOutstandingDetails = false;
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatCurrency(value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _formatCurrency(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.accentColor.withOpacity(0.9),
            widget.secondaryColor.withOpacity(0.9),
            widget.accentColor.withOpacity(0.9),
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
      child: Column(
        children: [
          _buildExpandableRow(
            'Actual Outstanding',
            widget.actualOutstanding,
            _showActualOutstandingDetails,
            [
              _buildDetailItem('45 days', widget.days45),
              _buildDetailItem('60 days', widget.days60),
              _buildDetailItem('90 days', widget.days90),
              _buildDetailItem('120 days', widget.days120),
              _buildDetailItem('180 days', widget.days180),
              _buildDetailItem('More than 180 days', widget.moreThan180),
            ],
          ),
          const Divider(color: Colors.white54, height: 20),
          _buildExpandableRow(
            'Balance of Credit \nNotes/Advances',
            widget.balance,
            _showBalanceDetails,
            [
              _buildDetailItem('Credit note total', widget.creditNotesTotal),
              _buildDetailItem(
                  'Balance amount total', widget.balanceAmountTotal),
            ],
          ),
          const Divider(color: Colors.white54, height: 20),
          _buildSummaryRow(
            'Total Cheques \nReceived (Not set off)',
            _formatCurrency(widget.totalCheques),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
