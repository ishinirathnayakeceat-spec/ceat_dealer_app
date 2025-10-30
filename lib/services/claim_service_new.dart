import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_url.dart';

class ClaimServiceNew {
  final String baseUrl = BaseUrl.baseUrl;

  /// Fetch Claim Request History
  Future<Map<String, dynamic>> fetchClaimRequestHistory(
      String zsDelCode) async {
    final String url = '$baseUrl/claimrequest-history/$zsDelCode';

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10), // Set a timeout of 10 seconds
        onTimeout: () {
          throw Exception("Request timeout. Please try again.");
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'success': true,
          'message': data['message'] ?? "Claim request history fetched.",
          'ClaimRequests':
              data.containsKey('ClaimRequests') ? data['ClaimRequests'] : [],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? "Failed to fetch claim requests.",
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
