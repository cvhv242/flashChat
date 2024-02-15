

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'otp_screen.dart';

class PhoneAuthRegisterScreen extends StatefulWidget {
  PhoneAuthRegisterScreen({super.key});

  @override
  State<PhoneAuthRegisterScreen> createState() => _PhoneAuthRegisterScreenState();
}

class _PhoneAuthRegisterScreenState extends State<PhoneAuthRegisterScreen> {
  String? email, phoneNumber, name, image_url;


  final _firestore = FirebaseFirestore.instance;

  bool profile_updated = false;

  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  var verificationID = '';



  Future<void> selectImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    print(file?.path);
    Reference reference = FirebaseStorage.instance.ref().child('profilePicture').child('${name!}.jpg');
    try{
      reference.putFile(File(file!.path));
      image_url = await reference.getDownloadURL();
    }catch(e){
      print(e);
    }
    setState(() {
      profile_updated = true;
      print(image_url);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                Center(
                  child: Stack(
                    children: [
                      profile_updated ?
                      CircleAvatar(
                        backgroundImage: NetworkImage(image_url!),
                        radius: 65,
                      )
                          :  CircleAvatar(
                        backgroundImage: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/9/9a/No_avatar.png'),
                        radius: 65,
                      ),

                      Positioned(
                        child: IconButton(
                          onPressed: selectImage,//() async {
                          //   ImagePicker imagePicker = ImagePicker();
                          //   XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                          //   print(file?.path);
                          //   Reference reference = FirebaseStorage.instance.ref().child('profilePicture').child('${name!}.jpg');
                          //   try{
                          //     reference.putFile(File(file!.path));
                          //     image_url = await reference.getDownloadURL();
                          //   }catch(e){
                          //     print(e);
                          //   }
                          // },
                          icon: Icon(Icons.add_a_photo, color: Colors.black,),
                        ),
                        bottom: -10,
                        left: 80,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    name = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: Colors.black12),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(color: Colors.black12),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your Phone Number',
                    hintStyle: TextStyle(color: Colors.black12),
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Hero(
                  tag: 'register',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: ()  async {
                          setState(() {
                            showSpinner = true;
                          });

                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: phoneNumber,
                            verificationCompleted: (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {},
                            codeSent: (String verificationId, int? resendToken) {
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {},
                          );
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPScreen(name: name, email: email,image_url: image_url, verificationID: verificationID,)));
                          setState(() {
                            showSpinner=false;
                          });
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Send OTP',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
