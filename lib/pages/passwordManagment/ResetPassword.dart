import 'package:flutter/material.dart';
import 'package:tale3ne/pages/Start/Login_page.dart';
import 'package:tale3ne/services/user_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userId;
  ResetPasswordPage ({
    required this.userId
  });


  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _userService = UserService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'Enter New Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Check if the passwords match
                if (newPasswordController.text == confirmPasswordController.text) {
                  // Passwords match, reset the password and navigate to LoginPage
                  resetPassword(newPasswordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password updated.'),
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                } else {
                  // Passwords don't match, show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Passwords do not match. Please try again.'),
                    ),
                  );
                }
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  // Replace this function with your actual password reset logic
  void resetPassword(String newPassword) {
    try {
      _userService.updatePassword(widget.userId, newPassword);
    } catch (e){
      print (e);
      }
    }
}
