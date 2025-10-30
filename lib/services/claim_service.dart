import 'dart:convert';
import 'package:ceat_dealer_portal/services/base_url.dart';
import 'package:http/http.dart' as http;

class ClaimService {
  final String baseUrl = BaseUrl.baseUrl;

  
  Future<Map<String, dynamic>> fetchClaimDetails(String dealerCode) async {
    final String url = '$baseUrl/claims/$dealerCode'; 
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'claimSummary': data['claimSummary'],
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


  Future<Map<String, dynamic>> getClaimDetailsByDateAndDocket(
    String dealerCode, String docketNo, String fromDate, String toDate) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/filter'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'zsDelCode': dealerCode,
        'docketNo': docketNo,
        'fromDate': fromDate,
        'toDate': toDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'No message provided',
        'claimSummary': data['claimSummary'],
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to search claims: ${response.statusCode} - ${response.body}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: $e',
    };
  }
}



  Future<Map<String, dynamic>> getClaimDetailsByDocketNo(
    String dealerCode, String docketNo) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/filter-by-docketNo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'zsDelCode': dealerCode,
        'docketNo': docketNo,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'No message provided',
        'claimSummary': data['claimSummary'],
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to search claims: ${response.statusCode} - ${response.body}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: $e',
    };
  }
}




  Future<Map<String, dynamic>> getClaimDetailsByDateRange(
    String dealerCode, String fromDate, String toDate) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/claims/filter-by-dateRange'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'zsDelCode': dealerCode,
        'fromDate': fromDate,
        'toDate': toDate,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'No message provided',
        'claimSummary': data['claimSummary'],
      };
    } else {
      return {
        'success': false,
        'message': 'Failed to search claims: ${response.statusCode} - ${response.body}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'An error occurred: $e',
    };
  }

}

}

