import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OTPScreen extends StatefulWidget {
  OTPScreen(
      {required this.name,
      required this.email,
      required this.image_url,
      required this.verificationID
      });

  String? name, email, image_url, verificationID;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _auth = FirebaseAuth.instance;

  var code;

  Future<void> _signInWithPhoneNumber(String smsCode) async {
   try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationID!,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      print('User signed in: ${_auth.currentUser!.uid}');
   } catch (e) {
      print('Error signing in with phone number: $e');
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP'.toUpperCase(),
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 40.0),
            const SizedBox(height: 20.0),
            OtpTextField(
              mainAxisAlignment: MainAxisAlignment.center,
              numberOfFields: 6,
              fillColor: Colors.black.withOpacity(0.1),
              filled: true,
              onSubmit: (code) {
                this.code = code;
                print(this.code);
              },
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent),
                onPressed: () async {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationID!, smsCode: code);

                  await _auth.signInWithCredential(credential);
                  FirebaseFirestore.instance.collection('userDetails').add({
                    'name': widget.name,
                    'profile_pic': widget.image_url,
                    'email': widget.email,
                  });
                  Navigator.pushNamed(context, ChatScreen.id);
                },
                child:
                    const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
