import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tale3ne/pages/passwordManagment/ResetPassword.dart';
import 'package:tale3ne/pages/passwordManagment/VerificationPage.dart';
import 'package:tale3ne/services/user_service.dart';
import 'package:tale3ne/services/VerificationServices.dart' as verf;
class ForgotPasswordPage extends StatefulWidget {
  final String fcmToken;
  ForgotPasswordPage({
    required this.fcmToken
  });

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController idController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final _userService = UserService();
  String? fcmToken;
  void getFcm() async{
    fcmToken = await FirebaseMessaging.instance.getToken();
  }
 @override
  void initState() {
    super.initState();
    getFcm();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: 'Enter ID'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Enter Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  print("this is pressed");
                  // Call the confirmUser function
                  await _userService.confirmUser(
                    idController.text,
                    phoneNumberController.text,
                    fcmToken!,
                  );

                  // If the user is confirmed, send a verification code
                  String verificationId = await verf.sendVerificationCode(
                    phoneNumberController.text,
                    '+961',
                  );

                  // Now you can use the verificationId to verify the phone number
                  // For example, you can navigate to another page to enter the verification code
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerificationCodePage(
                        verificationId: verificationId,
                          userId: idController.text,
                        onVerify: (verificationId) {
                          print("hi");
                          // Handle verification completion, e.g., navigate to the next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordPage(userId: idController.text),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } catch (error) {
                  // Handle errors here
                  print('Error: $error');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}