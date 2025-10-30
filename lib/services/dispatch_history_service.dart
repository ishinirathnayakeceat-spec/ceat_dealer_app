import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class DispatchHistoryService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> fetchDispatchDetails(String dealerCode) async {
    final String url = '$baseUrl/dispatch-history/$dealerCode'; // Endpoint URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'DispatchSummary': data['DispatchSummary'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': json.decode(response.body)['message'],
        };
      } else {
        return {
          'success': false,
          'message': 'Unexpected server response.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> searchDispatchHistory(String zsDelCode,
      String dispatchNo, String fromDate, String toDate) async {
    final String url = '$baseUrl/search-dispatch-history';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'zsDelCode': zsDelCode,
          'dispatch_no': dispatchNo,
          'fromDate': fromDate,
          'toDate': toDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'DispatchSummary': data['DispatchSummary'],
        };
      } else {
        throw Exception('Failed to search dispatch history');
      }
    } catch (error) {
      throw Exception('Error searching dispatch history: $error');
    }
  }

// search from dispatch no
  Future<Map<String, dynamic>> searchDispatchNumber(
      String zsDelCode, String dispatchNo) async {
    final String url = '$baseUrl/search-dispatch-number';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'zsDelCode': zsDelCode,
          'dispatch_no': dispatchNo,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'DispatchSummary': data['DispatchSummary'],
        };
      } else {
        throw Exception('Failed to search dispatch number');
      }
    } catch (error) {
      throw Exception('Error searching dispatch number: $error');
    }
  }

  // search from status and date range
  Future<Map<String, dynamic>> searchDispatchbystatus(
      String zsDelCode, String status, String fromDate, String toDate) async {
    final String url = '$baseUrl/search-dispatch-status';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'zsDelCode': zsDelCode,
          'status': status,
          'fromDate': fromDate,
          'toDate': toDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'DispatchSummary': data['DispatchSummary'],
        };
      } else {
        throw Exception('Failed to search dispatch history');
      }
    } catch (error) {
      throw Exception('Error searching dispatch history: $error');
    }
  }

// search by material description
  Future<Map<String, dynamic>> searchMaterialDescription(
      String zsDelCode, String description) async {
    final String url = '$baseUrl/search-material';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Ensure JSON response
        },
        body: utf8.encode(json.encode({
          // Encode properly
          'zsDelCode': zsDelCode,
          'description': description,
        })),
      );

      print("Request Body: ${json.encode({
            'zsDelCode': zsDelCode,
            'description': description
          })}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'DispatchSummary': data['DispatchSummary'],
        };
      } else {
        throw Exception('Failed to search material description');
      }
    } catch (error) {
      throw Exception('Error searching material description: $error');
    }
  }

  // Fetch Materials from API
  Future<List<dynamic>> fetchMaterials() async {
    final response = await http.get(Uri.parse('$baseUrl/material-list'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['materials']; // Extract the list of materials
    } else {
      throw Exception('Failed to load materials');
    }
  }
}
