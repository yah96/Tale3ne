// register_functions.dart
import 'package:flutter/material.dart';
import 'package:tale3ne/pages/passwordManagment/VerificationPage.dart';
import 'package:tale3ne/pages/Start/Login_page.dart';
import 'package:tale3ne/services/user_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tale3ne/services/VerificationServices.dart' as verf;

class RegisterFunctions {
  static final countryCode = '+961';
  static bool _isLoading = false;

  static Future<void> signUp(
      BuildContext context,
      TextEditingController firstNameController,
      TextEditingController lastNameController,
      TextEditingController idController,
      TextEditingController phoneNumberController,
      TextEditingController passwordController,
      TextEditingController confirmPasswordController,
      bool loading,
      UserService _userService,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Signing up..."),
            ],
          ),
        );
      },
    );

    final firstname = firstNameController.text;
    final lastname = lastNameController.text;
    final ID = idController.text;
    final phoneNumber = phoneNumberController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    try {
      // Check if any of the fields are empty
      if (firstname.isEmpty ||
          lastname.isEmpty ||
          ID.isEmpty ||
          phoneNumber.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        Navigator.pop(context); // Close the loading dialog
        showSnackBar(context, 'Fields cannot be empty. Please fill out all the fields.');
        return;
      }
      // Check if ID is numeric and has a length between 6 and 12 digits
      if (!isNumeric(ID) || ID.length < 6 || ID.length > 12) {
        Navigator.pop(context); // Close the loading dialog
        showSnackBar(context, 'ID must be a numeric value between 6 and 12 digits.');
        return;
      }
      // Check if passwords match
      if (password != confirmPassword) {
        Navigator.pop(context); // Close the loading dialog
        showSnackBar(context, "Passwords don't match. Please try again.");
        return;
      }

      // Send verification code and store the verification ID
      final verificationId = await verf.sendVerificationCode(phoneNumber, countryCode);

      // Close the loading dialog before showing the verification code dialog
      Navigator.pop(context);

      // Show the verification code dialog
      await showVerificationCodeDialog(context, idController, verificationId);

      // Show a new loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Completing registration..."),
              ],
            ),
          );
        },
      );

      // Get the user's current location
      Position currentPosition = await getCurrentLocation();

      // Sign up the user
      await _userService.signUpUser(
        firstname,
        ID,
        lastname,
        phoneNumber,
        countryCode,
        password,
        currentPosition.latitude,
        currentPosition.longitude,
      );

      // Save user info
      _userService.saveUserInfo(firstname, ID, lastname, password);
      showSnackBar(context, 'Sign-up Successful!');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      print(e.toString().replaceAll('Exception:', ''));
      showSnackBar(context, 'Sign-up failed:' + e.toString().replaceAll('Exception:', ''));
    } finally {

      setLoading(false);
    }
  }
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
  static Future<void> showVerificationCodeDialog(
      BuildContext context,
      TextEditingController idController,
      String verificationId,
      ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return VerificationCodePage(
              onVerify: (verificationCode) async {
                Navigator.of(context).pop();
              }, userId: idController.text, verificationId: verificationId,
            );
          },
        );
      },
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Future<Position> getCurrentLocation() async {
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
      ); // Provide default or handle accordingly
    }
  }

  static void setLoading(bool value) {
    _isLoading = value;
  }
}
