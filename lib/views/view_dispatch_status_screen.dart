import 'package:flutter/material.dart';
import '../widgets/dispatch_details_card.dart';

class ViewDispatchStatusScreen extends StatelessWidget {
  final String dispatch_no; // Pass relevant data from the previous screen
  final List<Map<String, dynamic>> dispatchDetails;

  const ViewDispatchStatusScreen({
    super.key,
    required this.dispatch_no,
    required this.dispatchDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "View Dispatch Details",
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
        itemCount: dispatchDetails.length,
        itemBuilder: (context, index) {
          return DispatchDetailCardWidget(
            dispatchDetails: dispatchDetails[index]
                .map((key, value) => MapEntry(key, value.toString())),
            dispatch_no: dispatch_no,
          );
        },
      ),
    );
  }
}
