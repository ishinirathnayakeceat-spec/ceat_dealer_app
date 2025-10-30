import 'package:flutter/material.dart';
import '../widgets/claim_status_detail_card_widget.dart';

class ViewClaimStatusScreen extends StatelessWidget {
  final String clNumber; 
  final List<Map<String, dynamic>> claimDetails;

  const ViewClaimStatusScreen({
    super.key,
    required this.clNumber,
    required this.claimDetails,
  });

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "View Claim Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: claimDetails.length,
        itemBuilder: (context, index) {
          return ClaimStatusDetailCardWidget(
            clNumber: clNumber, 
            claimDetail:
                claimDetails[index], 
          );
        },
      ),
    );
  }
}
