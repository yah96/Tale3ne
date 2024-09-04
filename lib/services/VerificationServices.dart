import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

Future<String> sendVerificationCode(String phoneNumber, String countryCode) async {
  final Completer<String> completer = Completer();
  print(countryCode + "" + phoneNumber);
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: '$countryCode$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback is triggered if the phone number is instantly verified
        // You can auto-sign in the user here if needed
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Failed to send verification code: ${e.message}');
        completer.completeError(Exception('Failed to send verification code'));
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID somewhere
        // This is needed to verify the code later
        print('Code sent to $phoneNumber. Verification ID: $verificationId');
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when the automatic code retrieval times out
      },
    );
  } catch (error) {
    print('Error in sendVerificationCode: $error');
    completer.completeError(Exception('Failed to send verification code'));
  }

  return completer.future;
}
Future<void> verifyPhoneNumber(String verificationId, String smsCode) async {
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    print('Phone number verified successfully');
  } catch (error) {
    print('Error in verifyPhoneNumber: $error');
    throw Exception('Failed to verify phone number');
  }
}