// lib/views/dispatch_order_status_screen.dart
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:shared_preferences/shared_preferences.dart';

import '../services/dispatch_history_service.dart'; // Adjust the import based on your project structure
import 'package:flutter/material.dart';
import '../widgets/dispatch_order_card_widget.dart';

class DispatchOrderStatusScreen extends StatefulWidget {
  const DispatchOrderStatusScreen({super.key});

  @override
  State<DispatchOrderStatusScreen> createState() =>
      _DispatchOrderStatusScreenState();
}

class _DispatchOrderStatusScreenState extends State<DispatchOrderStatusScreen> {
  final DispatchHistoryService service = DispatchHistoryService();
  String? _zsDelCode;
  List<dynamic> results = [];
  bool isLoading = true;
  String _message = '';
  bool showAllData =
      true; // To toggle between showing all data and filtered data
  List<dynamic> allMaterials = []; // Stores all fetched materials
  List<dynamic> filteredMaterials = []; // Stores filtered results
  bool isDropdownVisible = false; // Controls dropdown visibility

  @override
  void initState() {
    super.initState();
    _fetchDispatchDetails();
  }

  Future<void> _fetchDispatchDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response =
            await DispatchHistoryService().fetchDispatchDetails(dealerCode);

        if (response['success'] == true) {
          setState(() {
            results = response['DispatchSummary']?.take(5).toList() ??
                []; // Limit to 5 claims
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No dispatch details found.';
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching dispatch details: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  final Color secondaryColor = const Color(0xFFEF7300); // Orange
  final Color accentColor = const Color(0xFF000000); // Black

  // Date controllers
  DateTime? fromDate;
  DateTime? toDate;

  TextEditingController dispatchNoController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  // Format date to display in the TextField
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month}-${date.day}";
  }

  // Function to show the date picker
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

  // Search function
  Future<void> searchDispatch(
      String dispatchNo, String fromDate, String toDate) async {
    setState(() {
      isLoading = true; // Start loading
      _message = ''; // Clear previous error messages
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await DispatchHistoryService().searchDispatchHistory(
          dealerCode,
          dispatchNo,
          fromDate,
          toDate,
        );

        if (response['success'] == true) {
          // Assuming the API returns a single claim for a specific docket number
          setState(() {
            results = response['DispatchSummary'] != null &&
                    response['DispatchSummary'].isNotEmpty
                ? [response['DispatchSummary'][0]] // Only take the first claim
                : [];
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No dispatch details found.';
            results = []; // Clear claim data if no claims found
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching dispatch details: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  //search by dispatch number

  // Search function
  Future<void> searchDispatchNum(String dispatchNo) async {
    setState(() {
      isLoading = true; // Start loading
      _message = ''; // Clear previous error messages
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await DispatchHistoryService()
            .searchDispatchNumber(dealerCode, dispatchNo);

        if (response['success'] == true) {
          // Assuming the API returns a single claim for a specific docket number
          setState(() {
            results = response['DispatchSummary'] != null &&
                    response['DispatchSummary'].isNotEmpty
                ? [response['DispatchSummary'][0]] // Only take the first claim
                : [];
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No dispatch number found.';
            results = []; // Clear claim data if no claims found
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching dispatch details: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

//search by status

  // Search function
  Future<void> searchDispatchStatus(
      String status, String fromDate, String toDate) async {
    setState(() {
      isLoading = true; // Start loading
      _message = ''; // Clear previous error messages
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dealerCode = prefs.getString('dealerCode');

      if (dealerCode != null && dealerCode.isNotEmpty) {
        final response = await DispatchHistoryService().searchDispatchbystatus(
          dealerCode,
          status,
          fromDate,
          toDate,
        );

        if (response['success'] == true) {
          setState(() {
            results = response['DispatchSummary'] ?? [];
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No dispatch details found.';
            results = []; // Clear dispatch data if no claims found
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code is missing or invalid.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching dispatch details: $e';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

// search description
  Future<void> searchMaterialDescription(
      String dealerCode, String description) async {
    if (description.isEmpty) {
      setState(() {
        _message = 'Please enter a material description to search.';
        filteredMaterials = []; // ✅ Reset list if input is empty
      });
      return;
    }

    setState(() {
      isLoading = true;
      _message = '';
      results = [];
    });

    try {
      final response = await DispatchHistoryService()
          .searchMaterialDescription(dealerCode, description);

      print("API Response: ${response.toString()}"); // ✅ Debugging log

      if (response['success'] == true) {
        setState(() {
          results = response['DispatchSummary'] ?? [];
          filteredMaterials =
              results; // ✅ Update dropdown list with API response
          _message = response['message'] ?? 'No records found.';
        });

        // ✅ Ensure `descriptionController` updates with the valid searched value
        descriptionController.text = description;
      } else {
        setState(() {
          _message = response['message'] ?? 'No material found.';
          results = [];
          filteredMaterials = []; // ✅ Reset dropdown if no materials found
        });
      }
    } catch (e) {
      print("Error fetching dispatch details: $e"); // ✅ Log error for debugging
      setState(() {
        _message = 'Error fetching dispatch details. Please try again later.';
        filteredMaterials = []; // ✅ Reset dropdown on error
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  // Function to toggle between showing all data and filtered data
  void toggleExpand() {
    setState(() {
      showAllData = !showAllData; // Toggle showing all data
      if (showAllData) {
        _fetchDispatchDetails(); // Fetch all data again
      } else {
        results.clear(); // Clear the list if not showing all
      }
    });
  }

  // // Search functionality
  // void searchOrders() {
  //   print("Searching Dispatch Orders...");
  //   print("Dispatch No: ${dispatchNoController.text}");
  //   print("From Date: $fromDate");
  //   print("To Date: $toDate");
  //   print("Status: ${statusController.text}");
  // }
  //
  void filterMaterials(String query) {
    setState(() {
      filteredMaterials = allMaterials
          .where((material) => material['description']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void search() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? dealerCode = prefs.getString('dealerCode');

    if (dispatchNoController.text.isNotEmpty &&
        (fromDateController.text.isNotEmpty &&
            toDateController.text.isNotEmpty)) {
      searchDispatch(dispatchNoController.text, fromDateController.text,
          toDateController.text);
    } else if (dispatchNoController.text.isNotEmpty) {
      searchDispatchNum(dispatchNoController.text);
    } else if (statusController.text.isNotEmpty &&
        fromDateController.text.isNotEmpty &&
        toDateController.text.isNotEmpty) {
      searchDispatchStatus(
        statusController.text,
        fromDateController.text,
        toDateController.text,
      );
    } else if (descriptionController.text.isNotEmpty && dealerCode != null) {
      searchMaterialDescription(
          dealerCode, descriptionController.text); // ✅ Fixed
    } else {
      setState(() {
        _message = "Please enter valid search criteria.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Dispatch Order Status",
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
            // Dispatch No Field
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: TextField(
                    controller: dispatchNoController,
                    decoration: InputDecoration(
                      labelText: "Dispatch No",
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
            // From, To, and Status Fields
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
            // Status Field
            DropdownButtonFormField<String>(
              value: statusController.text.isNotEmpty
                  ? statusController.text
                  : null,
              decoration: InputDecoration(
                labelText: "Status",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(
                  Icons.assignment_ind,
                  color: secondaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Delivered",
                  child: Text("Delivered"),
                ),
                DropdownMenuItem(
                  value: "Goods On the way",
                  child: Text("Goods On the way"),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  statusController.text = value;
                }
              },
            ),
            const SizedBox(height: 10),
            // Material Description
            Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Search Material",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                      ),
                      onChanged: (value) {
                        filterMaterials(value); // ✅ Filter the material list
                        setState(() {
                          isDropdownVisible =
                              value.isNotEmpty && filteredMaterials.isNotEmpty;
                        });
                      },
                    ),
                  ],
                ),

                // Dropdown list appearing below TextField
                if (isDropdownVisible)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 60, // Adjust this value as per your layout
                    child: Material(
                      elevation: 4, // Adds a shadow effect
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        constraints:
                            BoxConstraints(maxHeight: 200), // Limit height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredMaterials.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title:
                                  Text(filteredMaterials[index]['description']),
                              onTap: () {
                                setState(() {
                                  descriptionController.text =
                                      filteredMaterials[index]['description'];
                                  isDropdownVisible =
                                      false; // Hide dropdown after selection
                                });
                                print(
                                    'Selected Material: ${filteredMaterials[index]['description']}');
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: search,
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
                    _fetchDispatchDetails();
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
            // Dispatch Order List
            Expanded(
              child: ListView.builder(
                itemCount: showAllData ? results.length : results.length,
                itemBuilder: (context, index) {
                  final dispatchHistory = results[index];
                  final dispatchDetails = List<Map<String, dynamic>>.from(
                      dispatchHistory['dispatchDetails'] ?? []);
                  return DispatchOrderCardWidget(
                    dispatchNo: dispatchHistory['dispatch_no'] ?? 'N/A',
                    // invoiceNo: dispatchHistory['invoice_no'] ?? 'N/A',
                    invoiceDate: dispatchHistory['invoice_date'] ?? 'N/A',
                    // driverName: "John Doe",
                    // vehicleCode: "V123",
                    status: dispatchHistory['status'] ?? 'N/A',
                    deliveryDate: dispatchHistory['delivery_date'] ?? 'N/A',
                    secondaryColor: secondaryColor,
                    accentColor: accentColor,
                    dispatchDetails: dispatchDetails,
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
