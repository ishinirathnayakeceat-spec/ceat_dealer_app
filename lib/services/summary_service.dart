import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class SummaryService {
 
  Future<Map<String, dynamic>> getSummaryDetails(String zsDelCode) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/summary/$zsDelCode'),
    );

    if (response.statusCode == 200) {
      
      return json.decode(response.body);
    } else {
      
      throw Exception('Failed to load summary details');
    }
  }

  
  Future<Map<String, dynamic>> getTotalChequesReceived(String zsDelCode) async {
    final response = await http.get(
      Uri.parse('${BaseUrl.baseUrl}/chequeReceived/$zsDelCode'),
    );

    if (response.statusCode == 200) {
      
      return json.decode(response.body);
    } else {
      
      throw Exception('Failed to load total cheques received');
    }
  }
}
