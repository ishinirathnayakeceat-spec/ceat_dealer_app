import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class InvoiceService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> fetchDueInvoices(String zsDelCode) async {
    final url = Uri.parse('$baseUrl/due-invoices/$zsDelCode');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'message': data['message'],
          'dueInvoiceCount': data['dueInvoiceCount'],
          'invoices': data['invoices'],
        };
      } else if (response.statusCode == 404) {
        return {
          'message': 'No due invoices found',
          'dueInvoiceCount': 0,
          'invoices': [],
        };
      } else {
        throw Exception('Failed to fetch due invoices');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}



