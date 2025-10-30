import 'package:flutter/material.dart';
import '../views/cheque_invoice_detail_screen.dart';

class ChequeCardWidget extends StatelessWidget {
  final String? paymentReturnNo;
  final String chequeNo;
  final String date;
  final String amount;
  final String? reason;
  final String? receivedDate;
  final String? bank;
  final String? area;
  final String? belnr;
  final String? invoiceNumber;
  final String? invoice_Rnumber;
  final String? invoiceAmount;
  final Color secondaryColor;
  final Color accentColor;
  final bool isReturnOption;

  const ChequeCardWidget({
    super.key,
    this.paymentReturnNo,
    required this.chequeNo,
    required this.date,
    required this.amount,
    this.reason,
    this.receivedDate,
    this.bank,
    this.area,
    this.belnr,
    this.invoiceNumber,
    this.invoice_Rnumber,
    this.invoiceAmount,
    required this.secondaryColor,
    required this.accentColor,
    required this.isReturnOption,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: isSmallScreen ? 8 : 16,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.9),
                  secondaryColor.withOpacity(0.8),
                  accentColor.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              vertical: 16,
              horizontal: isSmallScreen ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (paymentReturnNo != null)
                  _buildSummaryRow(
                      "Payment Return No.", paymentReturnNo!, isSmallScreen),
                if (paymentReturnNo != null)
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                _buildSummaryRow("Cheque No.", chequeNo, isSmallScreen),
                const Divider(
                    color: Colors.white54, thickness: 0.8, height: 24),
                _buildSummaryRow("Date", date, isSmallScreen),
                const Divider(
                    color: Colors.white54, thickness: 0.8, height: 24),
                _buildSummaryRow("Amount", amount, isSmallScreen),
                if (reason != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildResponsiveReasonRow(reason!, isSmallScreen),
                ],
                if (receivedDate != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildSummaryRow(
                      "Received Date", receivedDate!, isSmallScreen),
                ],
                if (bank != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildSummaryRow("Bank", bank!, isSmallScreen),
                ],
                if (area != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildSummaryRow("Area", area!, isSmallScreen),
                ],
                if (belnr != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildSummaryRow("BELNR", belnr!, isSmallScreen),
                ],
                if (invoiceNumber != null) ...[
                  const Divider(
                      color: Colors.white54, thickness: 0.8, height: 24),
                  _buildSummaryRow(
                      "Invoice Number", invoiceNumber!, isSmallScreen),
                ],
                const Divider(
                    color: Colors.white54, thickness: 0.8, height: 24),
                if (isReturnOption) // Only show the button if it's a return option
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceDetailScreen(
                              paymentReturnNo: paymentReturnNo ?? '',
                              InvNo: invoice_Rnumber ?? '',
                              InvAmount: invoiceAmount ?? '',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        shadowColor: Colors.transparent,
                        side: BorderSide.none,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.6),
                              secondaryColor.withOpacity(0.6),
                              accentColor.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: isSmallScreen ? 24 : 40,
                          ),
                          child: Text(
                            "View Invoice",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveReasonRow(String value, bool isSmallScreen) {
    return isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reason",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          )
        : _buildSummaryRow("Reason", value, isSmallScreen);
  }

  Widget _buildSummaryRow(String label, String value, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 4,
              horizontal: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
