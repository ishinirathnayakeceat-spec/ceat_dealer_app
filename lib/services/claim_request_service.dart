import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Import for MediaType
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'base_url.dart';

class TyreUploadService {
  static const String baseUrl = BaseUrl.baseUrl;

  // Upload Tyre Data & Images
  static Future<Map<String, dynamic>> uploadTyreData({
    required String zsDelCode,
    required String tyreSize,
    required String tyreSerialNumber,
    required String estimatedNonSkidDepth,
    required String defectType,
    required List<File> images,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['zsDelCode'] = zsDelCode;
      request.fields['tyre_size'] = tyreSize;
      request.fields['tyre_serial_number'] = tyreSerialNumber;
      request.fields['estimated_non_skid_depth'] = estimatedNonSkidDepth;
      request.fields['defect_type'] = defectType;

      // Attach images
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

        var multipartFile = http.MultipartFile(
          'images', // Matches Node.js `req.files['images']`
          stream,
          length,
          filename: basename(image.path),
          contentType: MediaType.parse(mimeType), // Fixed MediaType issue
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Upload failed: $responseBody');
      }
    } catch (e) {
      throw Exception('Error uploading tyre data: $e');
    }
  }
}
