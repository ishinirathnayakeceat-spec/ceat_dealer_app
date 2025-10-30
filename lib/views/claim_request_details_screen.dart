import 'package:flutter/material.dart';

class ClaimRequestDetailsScreen extends StatelessWidget {
  final String tyreId;
  final String receivedDate;
  final String tyreSize;
  final String tyreSerialNumber;
  final String estimatedNonSkidDepth;
  final String defectType;
  final List<Map<String, dynamic>> images;

  // ✅ Corrected Backend Uploads URL
  final String baseUrl = "http://20.33.35.180/ceat_dealer_app/backend/uploads";

  const ClaimRequestDetailsScreen({
    super.key,
    required this.tyreId,
    required this.receivedDate,
    required this.tyreSize,
    required this.tyreSerialNumber,
    required this.estimatedNonSkidDepth,
    required this.defectType,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainColor1 = Color(0xFF154FA3);
    const Color mainColor = Color(0xFFEF7300); // Orange
    const Color accentColor2 = Color(0xFF000000); // Black

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor1,
        title: const Text(
          "Claim Request Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor2.withOpacity(0.9),
                mainColor.withOpacity(0.9),
                accentColor2.withOpacity(0.9),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Tyre ID", tyreId),
              const Divider(color: Colors.white54, thickness: 0.8, height: 24),
              _buildDetailRow("Received Date", receivedDate),
              const Divider(color: Colors.white54, thickness: 0.8, height: 24),
              _buildDetailRow("Tyre Size", tyreSize),
              const Divider(color: Colors.white54, thickness: 0.8, height: 24),
              _buildDetailRow("Serial Number", tyreSerialNumber),
              const Divider(color: Colors.white54, thickness: 0.8, height: 24),
              _buildDetailRow("Non-Skid Depth", estimatedNonSkidDepth),
              const Divider(color: Colors.white54, thickness: 0.8, height: 24),
              _buildDetailRow("Defect Type", defectType),
              const SizedBox(height: 20),
              const Text("Uploaded Images:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
              const SizedBox(height: 8),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String filePath = images[index]['filepath'] ?? "";
                  String fullUrl = filePath.startsWith("http")
                      ? filePath
                      : "$baseUrl/${filePath.split('/').last}"; // ✅ Ensure '/' before filename

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image,
                              size: 50, color: Colors.red),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
