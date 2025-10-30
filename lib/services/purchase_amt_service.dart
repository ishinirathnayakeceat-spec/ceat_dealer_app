import 'dart:convert';
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:http/http.dart' as http;

class PurchaseAmtService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> getPurchaseAmt(String dealerCode) async {
    final url = Uri.parse('$baseUrl/purchase-amt/$dealerCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && data['data'] is List) {
          return {
            'message': data['message'],
            'data': data['data'],
          };
        } else {
          return {
            'message': 'No data available',
            'data': [],
          };
        }
      } else {
        return {
          'message': 'Failed to fetch data',
          'error': 'Status Code: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'message': 'Server error',
        'error': error.toString(),
      };
    }
  }





Future<Map<String, dynamic>> getPurchaseAmtBySearch(String zsDelCode, String selectedYear, String selectedMonth) async {

    final url = Uri.parse('$baseUrl/purchase-amt');
    final Map<String, String> requestBody = {
      'zsDelCode': zsDelCode,
      'selectedYear': selectedYear,
      'selectedMonth': selectedMonth,
    };
 
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data'] is List) {
          return {
            'message': data['message'],
            'data': data['data'],
          };
        } else {
          return {
            'message': data['message'] ?? 'No data available',
            'data': [],
          };
        }
      } else {
        return {
          'message': 'Failed to fetch data',
          'error': 'Status Code: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'message': 'Server error',
        'error': error.toString(),
      };
    }
  }

}