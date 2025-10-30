import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/claim_service_new.dart';
import '../widgets/claim_request_widget.dart';
import 'add_claim_request.dart';

class ClaimRequestScreen extends StatefulWidget {
  const ClaimRequestScreen({super.key});

  @override
  State<ClaimRequestScreen> createState() => _ClaimRequestScreenState();
}

class _ClaimRequestScreenState extends State<ClaimRequestScreen> {
  final ClaimServiceNew service = ClaimServiceNew();
  List<Map<String, dynamic>> results = []; // ✅ Ensure correct type
  bool isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _fetchClaimRequests();
  }

  Future<void> _fetchClaimRequests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? zsDelCode = prefs.getString('dealerCode');

      if (zsDelCode != null && zsDelCode.isNotEmpty) {
        final response = await service.fetchClaimRequestHistory(zsDelCode);

        if (response['success'] == true) {
          setState(() {
            results = List<Map<String, dynamic>>.from(
                response['ClaimRequests']); // ✅ Fix list type
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No claim requests found.';
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching claim requests: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3);
    const Color secondaryColor = Color(0xFFEF7300);
    const Color accentColor = Color(0xFFFFFFFF);
    const Color black = Color(0xFF000000);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor,
        title: const Text(
          "Claim Request",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
                  ? Center(child: Text(_message))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final claim = results[index];

                        return ClaimRequestWidget(
                          tyreId: claim['tyre_id']?.toString() ?? 'N/A',
                          receivedDate:
                              claim['tyre_created_at']?.toString() ?? 'N/A',
                          tyreSize: claim['tyre_size']?.toString() ?? 'N/A',
                          tyreSerialNumber:
                              claim['tyre_serial_number']?.toString() ?? 'N/A',
                          estimatedNonSkidDepth:
                              claim['estimated_non_skid_depth']?.toString() ??
                                  'N/A',
                          defectType: claim['defect_type']?.toString() ?? 'N/A',
                          images: List<Map<String, dynamic>>.from(
                              claim['images'] ?? []),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddClaimRequestScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
