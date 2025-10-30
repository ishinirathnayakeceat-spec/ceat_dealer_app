import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class AuthService {
  static const String baseUrl = BaseUrl.baseUrl;

 
  static Future<Map<String, dynamic>> login(
      String dealerCode, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'zsDelCode': dealerCode,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
