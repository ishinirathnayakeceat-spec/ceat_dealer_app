import 'dart:convert';
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:http/http.dart' as http;

class TargetYearService {
  final String baseUrl = BaseUrl.baseUrl;

  
  Future<Map<String, dynamic>> getMaterialGroupPerformanceYear(String dealerCode) async {
    final url = Uri.parse('$baseUrl/target-year/$dealerCode');

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
            'message': 'No data available for the latest year',
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
