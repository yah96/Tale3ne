import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tale3ne/services/RequestsServices.dart';

class UserService {
  final String baseUrl = "${RequestsServices.baseUrl}/users";


  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>>? _userLocations;

  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>>? get userLocations => _userLocations;

  Future<void> authenticateUser(String id, String password, double latitude, double longitude, String fcmToken) async {
    final url = Uri.parse('$baseUrl/authentication');

    final body = json.encode({'ID': id, 'password': password, 'latitude': latitude, 'longitude': longitude, 'fcmToken': fcmToken});
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userData = data['result'];
      } else {
        throw Exception('Failed to authenticate user');
      }
    } catch (error) {
      print('Error in authenticateUser: $error');
      throw Exception('Failed to authenticate user');
    }
  }
  Future<void> confirmUser(String id, String phoneNumber, String fcmToken) async {
    final url = Uri.parse('$baseUrl/confirmUser');
    final body = json.encode({'ID': id, 'phoneNumber': phoneNumber, 'fcmToken': fcmToken});
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to authenticate user');
      }
    } catch (error) {
      print('Error in authenticateUser: $error');
      throw Exception('Failed to authenticate user');
    }
  }
  Future<void> updatePassword(String id, String password) async {
    final url = Uri.parse('$baseUrl/updatePassword');
    final body = json.encode({'ID': id, 'password': password});
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to authenticate user');
      }
    } catch (error) {
      print('Error in updating password : $error');
      throw Exception('Failed to update password');
    }
  }
  Future<void> signUpUser(String firstname, String ID, String lastname,
      String phoneNumber, String countryCode, String password, double latitude, double longitude) async {
    try {
      final url = Uri.parse('$baseUrl/signup');
      final body = json.encode({
        'ID': ID,
        'firstname': firstname,
        'lastname': lastname,
        'password': password,
        'latitude': latitude,
        'longitude': longitude,
        'phoneNumber' : phoneNumber,
      });
      print(body);
      final headers = {'Content-Type': 'application/json'};

      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 201) {
        print('User created successfully');
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Failed to create user';
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('Error in signUpUser: $error');
      throw Exception(error);
    }
  }

  void saveUserInfo(String firstname, String email, String lastname, String password) {
    _userData = {
      'Firstname': firstname,
      'Email': email,
      'Lastname': lastname,
      'Password': password,
    };
  }

  Future<void> getAllUserLocations() async {
    final url = Uri.parse('$baseUrl/getLocations');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userLocations = List<Map<String, dynamic>>.from(data['userLocations']);
        print(_userLocations);
      } else {
        throw Exception('Failed to get user locations');
      }
    } catch (error) {
      print('Error in getAllUserLocations: $error');
      throw Exception('Failed to get user locations');
    }
  }

  Future<void> updateLocation(String id, String latitude, String longitude) async {
    final url = Uri.parse('$baseUrl/updateLocation');
    final body = json.encode({'ID': id, 'latitude': latitude, 'longitude': longitude});
    final headers = {'Content-Type': 'application/json'};
    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 201) {
        print('Updated user location successfully');
      } else {
        throw Exception('Failed to update user location');
      }
    } catch (error) {
      print('Error in updateLocation: $error');
      throw Exception('Failed to update user location');
    }
  }
}
