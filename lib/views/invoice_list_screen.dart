import 'package:flutter/material.dart';
import 'package:ceat_dealer_portal/views/invoice_detail_screen.dart';
import 'package:ceat_dealer_portal/widgets/side_menu_widget.dart';
import 'package:ceat_dealer_portal/widgets/invoice_card_widget.dart';
import 'package:ceat_dealer_portal/services/invoice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  String? _zsDelCode;
  List<dynamic> _invoices = [];
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadDealerCodeAndFetchInvoices();
  }

  Future<void> _loadDealerCodeAndFetchInvoices() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final zsDelCode = prefs.getString('dealerCode');

      if (zsDelCode != null) {
        setState(() {
          _zsDelCode = zsDelCode;
        });

        final response = await _invoiceService.fetchDueInvoices(zsDelCode);

        if (response['invoices'] != null) {
          setState(() {
            _invoices = response['invoices'];
            _message = response['message'] ?? '';
          });
        } else {
          setState(() {
            _message = response['message'] ?? 'No invoices found.';
          });
        }
      } else {
        setState(() {
          _message = 'Dealer code not found.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error fetching invoices: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3),
        title: const Text(
          "Your Due Invoices",
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
      drawer: const SideMenuWidget(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoices.isEmpty
              ? Center(
                  child: Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _invoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _invoices[index];
                      return InvoiceCardWidget(
                        documentDate: invoice['dtdocdate']?? 'N/A',
                        invoiceNumber: invoice['InvDocNo'] ?? 'N/A',
                        daysDue: invoice['DaysDue'] != null
                            ? '${invoice['DaysDue']} Days'
                            : 'N/A',
                        amount: invoice['dbAmount'] != null
                            ? '${invoice['dbAmount']}'
                            : 'N/A',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvoiceDetailScreen(
                                invoiceNumber: invoice['InvDocNo'] ?? 'N/A',
                                documentDate: invoice['dtdocdate']?? 'N/A',
                                documentType: invoice['zsDocType'] ?? 'N/A',
                                amount: invoice['dbAmount']?.toString() ?? 'N/A',
                                deliveryDate: invoice['DelivDate']?? 'N/A',
                                dueDate:invoice['DuDate']?? 'N/A',
                                daysDue: invoice['DaysDue']?.toString() ?? 'N/A',
                                chequeNo: invoice['ChqNumber'] ?? 'CNR',
                                chequeAmount:
                                    invoice['ChequeAmt']?.toString() ?? '0.00',
                                chequeDepositDate: 
                                    invoice['DepDate']?? 'N/A',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
