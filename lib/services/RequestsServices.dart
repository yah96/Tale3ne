import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestsServices {
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  Future<Map<String, dynamic>> addRequest(Map<String, dynamic> requestData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests/addRequest'),
      headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> removeRequest(String passengerId,String passengerName,
      String driverId, String driverName,String rideId, String requestId,bool accepted) async {

    final response = await http.delete(
      Uri.parse('$baseUrl/requests/$requestId/removeRequest'),
      body: jsonEncode({
        'passengerId': passengerId,
        'passengerName': passengerName,
        'driverId': driverId,
        'driverName': driverName,
        'accepted' : accepted,
        'rideId' : rideId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> findRequestsByDriverId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/requests/$userId'));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform the request. Status code: ${response.statusCode}');
    }
  }
}
