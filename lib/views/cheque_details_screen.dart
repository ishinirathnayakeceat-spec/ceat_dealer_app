import 'package:flutter/material.dart';
import '../widgets/cheque_card_widget.dart';
import '../services/cheque_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChequeDetailsScreen extends StatefulWidget {
  const ChequeDetailsScreen({super.key});

  @override
  State<ChequeDetailsScreen> createState() => _ChequeDetailsScreenState();
}

class _ChequeDetailsScreenState extends State<ChequeDetailsScreen> {
  final Color secondaryColor = const Color(0xFFEF7300);
  final Color accentColor = const Color(0xFF000000);

  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController chequeNoController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  List<dynamic> chequeData = [];
  String selectedOption = "Return";
  final ChequeService chequeService = ChequeService();
  String? zsDelCode;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  @override
  void dispose() {
    chequeNoController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      zsDelCode = prefs.getString('dealerCode');
    });
  }

  void resetForm() {
    setState(() {
      chequeNoController.clear();
      fromDateController.clear();
      toDateController.clear();
      fromDate = null;
      toDate = null;
      selectedOption = "Return";
      chequeData.clear();
    });
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: secondaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          if (toDate != null && pickedDate.isAfter(toDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("From date cannot be after To date")),
            );
          } else {
            fromDate = pickedDate;
            fromDateController.text = formatDate(fromDate);
          }
        } else {
          if (fromDate != null && pickedDate.isBefore(fromDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("To date cannot be before From date")),
            );
          } else {
            toDate = pickedDate;
            toDateController.text = formatDate(toDate);
          }
        }
      });
    }
  }

  Future<void> searchCheques() async {
    if (zsDelCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User code not found")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await chequeService.fetchCheques(
        selectedOption: selectedOption,
        chequeNo: chequeNoController.text,
        fromDate: fromDate?.toIso8601String() ?? '',
        toDate: toDate?.toIso8601String() ?? '',
        zsDelCode: zsDelCode!,
      );
      setState(() {
        chequeData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cheques: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Cheque Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Container(
            color: Colors.white,
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                TextField(
                  controller: chequeNoController,
                  decoration: InputDecoration(
                    labelText: "Cheque No",
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
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => selectDate(context, true),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: fromDateController,
                            decoration: InputDecoration(
                              labelText: "From",
                              filled: true,
                              fillColor: Colors.white,
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
                    SizedBox(width: isSmallScreen ? 8 : 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => selectDate(context, false),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: toDateController,
                            decoration: InputDecoration(
                              labelText: "To",
                              filled: true,
                              fillColor: Colors.white,
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
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedOption,
                        items: ["Return", "Collect", "Realized"]
                            .map((String option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select Status",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(
                            Icons.filter_alt_outlined,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: searchCheques,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                          horizontal: isSmallScreen ? 16 : 24,
                        ),
                      ),
                      child: const Text(
                        "Search",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                          horizontal: isSmallScreen ? 16 : 24,
                        ),
                        side: BorderSide(color: secondaryColor),
                      ),
                      child: Text(
                        "Reset",
                        style: TextStyle(color: secondaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (chequeData.isEmpty &&
                    chequeNoController.text.isNotEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No cheques found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: chequeData.length,
                      itemBuilder: (context, index) {
                        final cheque = chequeData[index];
                        bool isReturnOption = selectedOption ==
                            "Return"; 
                        if (isReturnOption) {
                          return ChequeCardWidget(
                            paymentReturnNo: cheque['zsRPayDoc'] ?? 'N/A',
                            chequeNo: cheque['ZsChqNo'] ?? 'N/A',
                            date: cheque['ZdtDocDate'] ?? 'N/A',
                            amount: cheque['ZsChqAmount']?.toString() ?? '0',
                            reason: cheque['zsReason'] ?? 'N/A',
                            invoice_Rnumber: cheque['zsinvnum'] ?? 'N/A',
                            invoiceAmount:
                                cheque['zsInvAmt']?.toString() ?? '0',
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            isReturnOption:
                                isReturnOption, 
                          );
                        } else if (selectedOption == "Collect") {
                          return ChequeCardWidget(
                            chequeNo: cheque['zsChqNo'] ?? 'N/A',
                            date: cheque['zsdtDocDate'] ?? 'N/A',
                            amount: cheque['zsChqAmount']?.toString() ?? '0',
                            receivedDate: cheque['zsdtCrtDate'] ?? 'N/A',
                            bank: cheque['zsBankName'] ?? 'N/A',
                            area: cheque['zsLocation'] ?? 'N/A',
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            isReturnOption: false,
                          );
                        } else {
                          return ChequeCardWidget(
                            chequeNo: cheque['ZsChqNo'] ?? 'N/A',
                            date: cheque['ZdtDocDate'] ?? 'N/A',
                            amount: cheque['ZsChqAmount']?.toString() ?? '0',
                            belnr: cheque['zsPayDoc'] ?? 'N/A',
                            invoiceNumber: cheque['ZsInv'] ?? 'N/A',
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            isReturnOption: false, 
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
