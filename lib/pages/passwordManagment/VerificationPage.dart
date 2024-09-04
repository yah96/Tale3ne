import 'package:flutter/material.dart';
import 'package:tale3ne/services/VerificationServices.dart' as verf;
class VerificationCodePage extends StatefulWidget {
  final String verificationId;
  final String userId;
  final Function(String) onVerify;

  VerificationCodePage({
    required this.verificationId,
    required this.userId,
    required this.onVerify,
  });

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Enter Verification Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Verify the phone number using the verification code
                  await verf.verifyPhoneNumber(
                    widget.verificationId,
                    codeController.text,
                  );
                  // Phone number verified successfully, call onVerify callback
                  widget.onVerify(widget.verificationId);

                } catch (error) {
                  // Handle errors here
                  print('Error: $error');
                }
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
