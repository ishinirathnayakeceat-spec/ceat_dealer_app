import 'package:flutter/material.dart';
import 'package:ceat_dealer_portal/widgets/promotion_option_card.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PromotionScreen extends StatelessWidget {
  const PromotionScreen({super.key});

  Future<void> _openPDF(
      BuildContext context, String assetPath, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      if (!await file.exists()) {
        final byteData = await rootBundle.load('lib/uploads/$fileName');
        await file.writeAsBytes(byteData.buffer.asUint8List());
      }

      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the PDF file'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3); // Dark Blue
    const Color secondaryColor = Color(0xFFEF7300); // Orange
    const Color accentColor2 = Color(0xFFFFFFFF); // White

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor,
        title: const Text(
          "Promotions",
          style: TextStyle(color: accentColor2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentColor2),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  PromotionOptionCard(
                    icon: Icons.filter_9_plus_outlined,
                    label: "Tread Communication Letter",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () => _openPDF(
                        context,
                        'lib/uploads/TRADE-COMMUNICATION-LETTER.pdf',
                        'TRADE-COMMUNICATION-LETTER.pdf'),
                  ),
                  const SizedBox(height: 16),
                  PromotionOptionCard(
                    icon: Icons.list_alt_outlined,
                    label: "Tread Communication",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () => _openPDF(
                        context,
                        'lib/uploads/TRADE-COMUNICATION.pdf',
                        'TRADE-COMUNICATION.pdf'),
                  ),
                  const SizedBox(height: 16),
                  PromotionOptionCard(
                    icon: Icons.list_alt_outlined,
                    label: "Price List",
                    gradientColors: [
                      Colors.black.withOpacity(0.9),
                      mainColor.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                    iconBackgroundColor: secondaryColor,
                    onTap: () => _openPDF(
                        context,
                        'lib/uploads/CEAT-RETAIL-PRICE.pdf',
                        'CEAT-RETAIL-PRICE.pdf'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
