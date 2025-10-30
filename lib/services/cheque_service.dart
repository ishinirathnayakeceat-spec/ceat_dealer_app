

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class ChequeService {
  Future<List<dynamic>> fetchCheques({
    required String selectedOption,
    required String chequeNo,
    required String fromDate,
    required String toDate,
    required String zsDelCode,
  }) async {
    final response = await http.get(Uri.parse(
        '${BaseUrl.baseUrl}/cheques?selectedOption=$selectedOption&chequeNo=$chequeNo&fromDate=$fromDate&toDate=$toDate&zsDelCode=$zsDelCode'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cheques');
    }
  }
}
