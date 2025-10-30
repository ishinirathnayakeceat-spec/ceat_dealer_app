import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class ProfileService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, dynamic>> fetchProfileDetails(String zsDelCode) async {
    final url = Uri.parse('$baseUrl/profile/$zsDelCode');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['profile'];
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found');
      } else {
        throw Exception('Failed to load profile details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
