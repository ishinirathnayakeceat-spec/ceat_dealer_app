import 'package:ceat_dealer_portal/widgets/purchase_card_widget.dart';
import 'package:ceat_dealer_portal/widgets/purchase_sub_material_card_widget.dart';
import 'package:flutter/material.dart';

class PurchaseVolumeDetailsScreen extends StatefulWidget {
  final String zsmonth;
  final String totalQuantity;
  final String totalPurchases;
  final List<dynamic> purchaseList;

  const PurchaseVolumeDetailsScreen({
    Key? key,
    required this.zsmonth,
    required this.totalQuantity,
    required this.totalPurchases,
    required this.purchaseList,
  }) : super(key: key);

  @override
  _PurchaseVolumeDetailsScreenState createState() =>
      _PurchaseVolumeDetailsScreenState();
}

class _PurchaseVolumeDetailsScreenState
    extends State<PurchaseVolumeDetailsScreen> {

  
  int? _expandedIndex;
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF154FA3), 
        title: const Text("Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSummaryCard(), 
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.purchaseList.length,
                itemBuilder: (context, index) {
                  final purchase = widget.purchaseList[index];
                  bool isExpanded = _expandedIndex == index; 

                  return Column(
                    children: [
                      PurchaseCardWidget(
                        title: purchase['materialName']!,
                        quantity: purchase['groupQuantity']!,
                        amount: purchase['groupAmount']!,
                        onTap: () {
                          setState(() {
                            
                            _expandedIndex = isExpanded ? null : index;
                            
                          });
                        },
                      ),
                      
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: purchase['subMaterials']?.length ?? 0,
                            itemBuilder: (context, subIndex) {
                              final subMaterial = purchase['subMaterials'][subIndex];
                              return SubMaterialCard(
                                subTitle: subMaterial['subMaterialName']!,
                                quantity: subMaterial['subGroupQuantity']!,
                                amount: subMaterial['subGroupAmount']!,
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF000000).withOpacity(0.8),
            const Color(0xFF154FA3).withOpacity(0.8),
            const Color(0xFF1E88E5).withOpacity(0.9),
            const Color(0xFF154FA3).withOpacity(0.8),
            const Color(0xFF000000).withOpacity(0.8),
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Text(
              widget.zsmonth,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow("Total Quantity", widget.totalQuantity),
          const Divider(
            color: Colors.white54,
            thickness: 0.8,
            height: 24,
          ),
          _buildSummaryRow("Total Purchases", widget.totalPurchases),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}



