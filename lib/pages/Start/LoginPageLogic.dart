import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tale3ne/pages/Main/HomeTabBar_page.dart';
import 'package:tale3ne/services/user_service.dart';

class LoginPageLogic {
  static Future<void> login(BuildContext context,
      TextEditingController idController,
      TextEditingController passwordController,
      UserService userService,
      String fcmToken)
  async {
    // Check if ID is empty
    final id = idController.text;
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID cannot be empty. Please enter a valid ID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if ID is numeric
    if (!isNumeric(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID must be a numeric value.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if password is empty
    final password = passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password cannot be empty. Please enter a valid password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set a timeout duration (e.g., 15 seconds)
    const Duration timeoutDuration = Duration(seconds: 10);

    try {
      // Show loading screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Fetch user's current location
      Position currentPosition = await _getCurrentLocation();

      // Authenticate user and update location with timeout
      await Future.any([
        userService.authenticateUser(
          id,
          password,
          currentPosition.latitude,
          currentPosition.longitude,
          fcmToken,
        ),
        Future.delayed(timeoutDuration).then((_) {
          // Throw a TimeoutException after the specified duration
          throw TimeoutException('Authentication timed out');
        }),
      ]);

      final userData = userService.userData;

      Navigator.pop(context); // Close loading screen

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeTabBar(
            firstName: userData!['firstname'],
            lastName: userData['lastname'],
            ID: userData['ID'],
          ),
        ),
      );
    } catch (e) {
      print('Authentication failed: $e');
      Navigator.pop(context); // Close loading screen

      // Check if the error is due to a timeout
      if (e is TimeoutException) {
        // Show timeout error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication timed out. Please check your connection and try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Show regular authentication error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed. Please check your credentials and try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper function to check if a string is numeric
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static Future<Position> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return Position(
        speedAccuracy: 0,
        latitude: 0,
        longitude: 0,
        timestamp: null,
        accuracy: 0,
        heading: 0,
        speed: 0,
        altitude: 0,
      );
    }  }
}
