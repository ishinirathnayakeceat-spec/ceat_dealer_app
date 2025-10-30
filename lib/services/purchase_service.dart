import 'dart:convert';
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:http/http.dart' as http;

class PurchaseService {
  final String baseUrl = BaseUrl.baseUrl;

 
  Future<Map<String, dynamic>> fetchPurchaseVolume(String dealerCode) async {
    final String url = '$baseUrl/purchase-volume/$dealerCode';

    try {
   
      final response = await http.get(Uri.parse(url));

      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch data',
          'error': errorData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred while fetching purchase volume data',
        'error': e.toString(),
      };
    }
  }



Future<Map<String, dynamic>> getPurchaseVolume(String zsDelCode, String selectedYear, String selectedMonth) async {
    final url = Uri.parse('$baseUrl/purchase-volume');
    
    
    final Map<String, String> requestBody = {
      'zsDelCode': zsDelCode,
      'selectedYear': selectedYear,
      'selectedMonth': selectedMonth,
    };
    
    try {
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
      
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) {
        return {
          'success': true,
          'message': data['message'] ?? 'Data fetched successfully',
          'data': data['data'], 
        };
      } else {
        return {
          'success': false,
          'message': 'Unexpected response format',
          'error': data,
        };
      }
    } else {
      
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to fetch data',
        'error': errorData,
      };
    }
  } catch (e) {
    
    return {
      'success': false,
      'message': 'Error occurred while fetching purchase volume data',
      'error': e.toString(),
    };
  }
  }

}
