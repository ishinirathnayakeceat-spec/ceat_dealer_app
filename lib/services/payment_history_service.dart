import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class PaymentHistoryService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<List<dynamic>> fetchPaymentHistory(String zsDelCode) async {
    final String url = '$baseUrl/payment-history/$zsDelCode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['results'] != null) {
          return data['results'];
        } else {
          throw Exception('No results found');
        }
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (error) {
      throw Exception('Error fetching payment history: $error');
    }
  }

  Future<List<dynamic>> searchPaymentHistory(String zsDelCode, String paymentNo,
      String fromDate, String toDate) async {
    final String url = '$baseUrl/search-payment-history';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'zsDelCode': zsDelCode,
          'paymentNo': paymentNo.isNotEmpty ? paymentNo : null,
          'fromDate': fromDate.isNotEmpty ? fromDate : null,
          'toDate': toDate.isNotEmpty ? toDate : null,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['results'] ?? [];
      } else {
        throw Exception('Failed to search payment history');
      }
    } catch (error) {
      throw Exception('Error searching payment history: $error');
    }
  }
}
