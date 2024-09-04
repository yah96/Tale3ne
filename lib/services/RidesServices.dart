import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tale3ne/services/RequestsServices.dart';
import 'package:tale3ne/models/RideData.dart';

class RidesService {

  final String baseUrl = RequestsServices.baseUrl;

  Future<List<RideData>> fetchRideData() async {
    final url = Uri.parse('$baseUrl/rides');
    try {
      final response = await http.get(url);

      if (response.statusCode == 204) {
        // Response code 204 means empty content
        throw EmptyRideDataListException();
      } else if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> ridesData = responseData['result'];
        List<RideData> ridesList = [];

        for (var rideData in ridesData) {
          // Create a RideData object for each entry in the response
          RideData ride = RideData.fromJson(rideData);
          ridesList.add(ride);
        }

        return ridesList;
      } else {
        throw Exception('Failed to load rides');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }
  Future<bool> addRide(RideData rideData) async {
    final url = Uri.parse('$baseUrl/addRide');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = json.encode(rideData.toJson());

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  Future<void> deleteRide(String rideId) async {
    final url = Uri.parse('$baseUrl/deleteRide');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = json.encode({'rideId': rideId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete the ride');
    }
  }
  Future<bool> removePassenger(String rideId, Map<String, dynamic> passengerData) async {
    final url = Uri.parse('$baseUrl/removePassenger');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'rideId': rideId,
      'passengerData': passengerData,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  Future<bool> addPassenger(String rideId, Map<String, dynamic> passengerData) async {
    final url = Uri.parse('$baseUrl/addPassenger');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'rideId': rideId,
      'passengerData': passengerData,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
class EmptyRideDataListException implements Exception {
  final String message = 'No rides available.';
}