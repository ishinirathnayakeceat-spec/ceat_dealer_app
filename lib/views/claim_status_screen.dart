import 'package:ceat_dealer_portal/services/claim_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/claim_card_widget.dart';

class ClaimStatusScreen extends StatefulWidget {
  const ClaimStatusScreen({super.key});

  @override
  State<ClaimStatusScreen> createState() => _ClaimStatusScreenState();
}

class _ClaimStatusScreenState extends State<ClaimStatusScreen> {
  final Color secondaryColor = const Color(0xFFEF7300); // Orange
  final Color accentColor = const Color(0xFF000000); // Black

  
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController docketNoController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  List<dynamic> _claimData = [];
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClaimDetails();
  }

  
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month}-${date.day}";
  }

  
  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          if (toDate != null && pickedDate.isAfter(toDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("From date cannot be after To date"),
              ),
            );
          } else {
            fromDate = pickedDate;
            fromDateController.text = formatDate(fromDate);
          }
        } else {
          if (fromDate != null && pickedDate.isBefore(fromDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("To date cannot be before From date"),
              ),
            );
          } else {
            toDate = pickedDate;
            toDateController.text = formatDate(toDate);
          }
        }
      });
    }
  }

  Future<void> _fetchClaimDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await ClaimService().fetchClaimDetails(dealerCode);

        if (response['success'] == true) {
          setState(() {
            _claimData = response['claimSummary']?.take(5).toList() ?? []; 
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No claim details found.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching claim details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClaimDetailsByDateAndDocket(String docketNo, String fromDate, String toDate) async {
    setState(() {
      _isLoading = true; 
      _errorMessage = ''; 
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await ClaimService().getClaimDetailsByDateAndDocket(
          dealerCode,
          docketNo,
          fromDate,
          toDate,
        );

        if (response['success'] == true) {
          
          setState(() {
            _claimData = response['claimSummary'] != null && response['claimSummary'].isNotEmpty
                ? [response['claimSummary'][0]] 
                : [];
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No claim details found.';
            _claimData = []; 
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching claim details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }


  //-----------for search by docketNo
  Future<void> _fetchClaimDetailsByDocketNo(String docketNo) async {
    setState(() {
      _isLoading = true; 
      _errorMessage = ''; 
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await ClaimService().getClaimDetailsByDocketNo(
          dealerCode,
          docketNo,
        );

        if (response['success'] == true) {
          
          setState(() {
            _claimData = response['claimSummary'] != null && response['claimSummary'].isNotEmpty
                ? [response['claimSummary'][0]] 
                : [];
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No claim details found.';
            _claimData = []; 
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching claim details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }



  //-------------------------search by date range

  Future<void> _fetchClaimDetailsByDateRange(String fromDate, String toDate) async {
    setState(() {
      _isLoading = true; 
      _errorMessage = ''; 
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await ClaimService().getClaimDetailsByDateRange(
          dealerCode,
          fromDate,
          toDate,
        );

        if (response['success'] == true) {
          
          setState(() {
            _claimData = response['claimSummary'] ?? [];
            _errorMessage = response['message'] ?? '';
          });
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'No claim details found.';
            _claimData = []; 
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching claim details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }




//--------------------------------------------------------------------------------

  void handleSearch() {
    if (docketNoController.text.isNotEmpty) {
      _fetchClaimDetailsByDocketNo(docketNoController.text);
    
    } 
    else if (fromDateController.text.isNotEmpty && toDateController.text.isNotEmpty) {
      _fetchClaimDetailsByDateRange(
        fromDateController.text,
        toDateController.text,
      );
    }
    
    else if (docketNoController.text.isNotEmpty && (fromDateController.text.isNotEmpty && toDateController.text.isNotEmpty)) {
      _fetchClaimDetailsByDateAndDocket(
        docketNoController.text,
        fromDateController.text,
        toDateController.text,
      );
    } else {
      _fetchClaimDetails();
    }
  }

  //------------------------- 

  void resetForm() {
    setState(() {
      docketNoController.clear();
      fromDateController.clear();
      toDateController.clear();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Claim Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: docketNoController,
                    decoration: InputDecoration(
                      labelText: "Docket No",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(
                        Icons.article,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: fromDateController,
                        decoration: InputDecoration(
                          labelText: "From",
                          filled: true,
                          fillColor: Colors.white,
                          hintText: formatDate(fromDate),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(
                            Icons.date_range,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: toDateController,
                        decoration: InputDecoration(
                          labelText: "To",
                          filled: true,
                          fillColor: Colors.white,
                          hintText: formatDate(toDate),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(
                            Icons.date_range,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
                OutlinedButton(
                  onPressed: () {
                    resetForm();
                    _fetchClaimDetails();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: secondaryColor),
                  ),
                  child: Text(
                    "Reset",
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _claimData.isEmpty
                    ? Center(
                        child: Text(
                          _errorMessage.isNotEmpty
                              ? _errorMessage
                              : "No claim details available.",
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _claimData.length,
                          itemBuilder: (context, index) {
                            final claim = _claimData[index];
                            final claimDetails = List<Map<String, dynamic>>.from(claim['claimDetails'] ?? []);
                            return ClaimCardWidget(
                              clNumber: claim['cl1_number']?.toString() ?? 'Unknown',
                              receivedDate: claim['received_date']?.toString() ?? 'Unknown',
                              totalReceivedQty: claim['total_received_qty']?.toString() ?? '0',
                              secondaryColor: secondaryColor,
                              accentColor: accentColor,
                              claimDetails: claimDetails,
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}