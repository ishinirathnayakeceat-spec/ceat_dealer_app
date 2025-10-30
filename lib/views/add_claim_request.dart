import 'dart:io';
import 'package:ceat_dealer_portal/services/claim_request_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class AddClaimRequestScreen extends StatefulWidget {
  const AddClaimRequestScreen({super.key});

  @override
  State<AddClaimRequestScreen> createState() => _AddClaimRequestScreenState();
}

class _AddClaimRequestScreenState extends State<AddClaimRequestScreen> {
  final TextEditingController _zsDelCodeController = TextEditingController();
  final TextEditingController _tyreSizeController = TextEditingController();
  final TextEditingController _tyreSerialNumberController =
      TextEditingController();
  final TextEditingController _nonSkipDepthController = TextEditingController();
  final TextEditingController _defectTypeController = TextEditingController();
  List<String> _uploadedImages = [];
  bool _isSubmitting = false; // Fix: Initialize submission state

  @override
  void initState() {
    super.initState();
    _loadDealerCode(); // Load dealer code on screen init
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _addImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _uploadedImages.add(pickedFile.path);
      });
    }
  }

  /// 🔍 Load dealer code from SharedPreferences
  Future<void> _loadDealerCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? zsDelCode = prefs.getString('dealerCode');

    if (zsDelCode == null || zsDelCode.isEmpty) {
      print("❌ Dealer code NOT found in SharedPreferences!");
      return;
    }

    print("✅ Retrieved Dealer Code: $zsDelCode");

    setState(() {
      _zsDelCodeController.text = zsDelCode;
    });
  }

  /// 📑 Open PDF Guidelines
  void _openGuidelinesPDF() async {
    const String assetPath = "assets/uploads/Guidelines-for-Taking-Photos.pdf";

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/guidelines.pdf');

      if (!await file.exists()) {
        final byteData = await rootBundle.load(assetPath);
        await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }

      await OpenFilex.open(file.path);
    } catch (e) {
      print("Error opening PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open PDF guidelines: $e")),
      );
    }
  }

  Future<void> _submitClaimRequest() async {
    if (_zsDelCodeController.text.isEmpty ||
        _tyreSizeController.text.isEmpty ||
        _tyreSerialNumberController.text.isEmpty ||
        _nonSkipDepthController.text.isEmpty ||
        _defectTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    // 🚨 Check if at least 5 images are uploaded
    if (_uploadedImages.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload 5 images according to guidlines"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await TyreUploadService.uploadTyreData(
        zsDelCode: _zsDelCodeController.text,
        tyreSize: _tyreSizeController.text,
        tyreSerialNumber: _tyreSerialNumberController.text,
        estimatedNonSkidDepth: _nonSkipDepthController.text,
        defectType: _defectTypeController.text,
        images: _uploadedImages.map((path) => File(path)).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Upload successful!")),
      );

      // Clear fields after successful submission
      _tyreSizeController.clear();
      _tyreSerialNumberController.clear();
      _nonSkipDepthController.clear();
      _defectTypeController.clear();
      setState(() => _uploadedImages.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainColor = Color(0xFF154FA3);
    const Color accentColor = Color(0xFFFFFFFF);
    const Color secondaryColor = Color(0xFFEF7300);
    const Color blackColor = Color(0xFF000000);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainColor,
        title: const Text(
          "Add Claim Request",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: accentColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  blackColor.withOpacity(0.9),
                  secondaryColor.withOpacity(0.9),
                  blackColor.withOpacity(0.9),
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
                _buildInputField("Dealer Code :", _zsDelCodeController, true),
                _buildInputField("Tyre Size :", _tyreSizeController),
                _buildInputField(
                    "Tyre Serial Number :", _tyreSerialNumberController),
                _buildInputField(
                    "Estimated Non-Skid Depth (%) :", _nonSkipDepthController),
                _buildInputField("Defect Type :", _defectTypeController),
                const SizedBox(height: 16),

                /// **Upload Images Section**
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Upload Images :",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: _openGuidelinesPDF,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "View Guidelines",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 12), // Add spacing before the new row
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center-align buttons
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo),
                          label: const Text("Gallery"),
                          onPressed: () => _addImage(ImageSource.gallery),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Camera"),
                          onPressed: () => _addImage(ImageSource.camera),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildImageUploadSection(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _submitClaimRequest, // Calls the function on click
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: const Text(
                      "Submit Claim",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      [bool isReadOnly = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          children: _uploadedImages.map((imagePath) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePath),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _uploadedImages.remove(imagePath)),
                    child:
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
