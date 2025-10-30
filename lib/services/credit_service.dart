import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class CreditService {
  Future<double> getCreditLimit(String zsDelCode) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/credit-limit/$zsDelCode'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return double.tryParse(data['zdCreditLmt'].toString()) ?? 0.0;
    } else {
      throw Exception('Failed to load credit limit');
    }
  }
}
