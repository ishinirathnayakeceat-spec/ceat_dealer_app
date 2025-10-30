import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ppd_service.dart';
import '../widgets/ppd_card_widget.dart';
import 'ppd_report_screen.dart';
import 'package:intl/intl.dart';

class PPDDetailsScreen extends StatefulWidget {
  const PPDDetailsScreen({Key? key}) : super(key: key);

  @override
  _PPDDetailsScreenState createState() => _PPDDetailsScreenState();
}

class _PPDDetailsScreenState extends State<PPDDetailsScreen> {
  final PPDService _ppdService = PPDService();

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  List<dynamic> ppdData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPPDData();
  }

  Future<void> _loadPPDData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dealerCode = prefs.getString('dealerCode');

      if (dealerCode == null) {
        setState(() {
          errorMessage = 'Dealer code not found';
          isLoading = false;
        });
        return;
      }

      final response = await _ppdService.getPPDDetailsAndSummary(dealerCode);

      setState(() {
        if (response['success'] == true) {
          ppdData = response['data'];
        } else {
          errorMessage = response['message'];
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading PPD data: $e';
        isLoading = false;
      });
    }
  }

  String formatZsMonth(String zsmonth) {
    if (zsmonth.length != 6) return "Invalid Date";

    String year = zsmonth.substring(0, 4); 
    String monthNumber = zsmonth.substring(4, 6); 

    
    int monthIndex = int.parse(monthNumber);
    if (monthIndex < 1 || monthIndex > 12) return "Invalid Month";

    String monthName =
        months[monthIndex - 1]; 

    return "$year - $monthName"; 
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3);
    const Color accentColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          "PPD Details",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPPDData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (ppdData.isEmpty) {
      return const Center(child: Text('No PPD data available'));
    }

    return ListView.builder(
      itemCount: ppdData.length,
      itemBuilder: (context, index) {
        final ppd = ppdData[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PPDReportScreen(
                yearMonth: formatZsMonth(ppd['YearMonth']),
                details: ppd['Details'],
              ),
            ),
          ),
          child: PPDCardWidget(
            title: formatZsMonth(ppd['YearMonth']),
            amount: NumberFormat('#,##0.00;(#,##0.00)')
                .format(double.parse(ppd['Total_NetPPD_Amt'].toString())),
          ),
        );
      },
    );
  }
}
