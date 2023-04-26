import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:users/Screens/home_screen.dart';
import 'package:users/Screens/phone_login_screen.dart';
import 'package:users/Screens/register_screen.dart';

import '../Global/global.dart';

final codeTextEditingController = TextEditingController();

class VerifyScreen extends StatefulWidget {
  String phone="";
  VerifyScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  final phoneTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_dark.jpg': 'images/city.jpg'),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Phone Verification",
                        style: TextStyle(
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "We need to register your phone without getting started!",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Pinput(
                        length: 6,
                        // defaultPinTheme: defaultPinTheme,
                        // focusedPinTheme: focusedPinTheme,
                        // submittedPinTheme: submittedPinTheme,

                        showCursor: true,
                        onChanged: (value) {
                          setState(() {
                            codeTextEditingController.text = value;
                          });
                        },
                        onCompleted: (pin) {
                          codeTextEditingController.text = pin;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                            ),
                            onPressed: () async {
                              //print("Verification ID: " + RegisterScreen.verify);
                              try {
                                print("Code: " + codeTextEditingController.text);
                                PhoneAuthCredential credential = PhoneAuthProvider.credential(
                                    verificationId: PhoneLoginScreen.verify,
                                    smsCode: codeTextEditingController.text,
                                );
                                print(credential);
                                // Sign the user in (or link) with the credential
                                await firebaseAuth.signInWithCredential(
                                    credential,
                                ).then((auth) async {
                                  currentUser = auth.user;
                                  if(currentUser != null){
                                    FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(currentUser!.uid)
                                        .set(
                                        {
                                          "uid": currentUser!.uid,
                                          // "email": currentUser!.email,
                                          // "name": nameTextEditingController.text.trim(),
                                          // "address": addressTextEditingController.text.trim(),
                                          "phone": widget.phone,
                                        });

                                    //save locally
                                    // sharedPreferences = await SharedPreferences.getInstance();
                                    // await sharedPreferences!.setString("uid", currentUser!.uid);
                                    //await sharedPreferences!.setString("email", currentUser!.email!);
                                    // await sharedPreferences!.setString("name", nameTextEditingController.text.trim());
                                    // await sharedPreferences!.setString("phone", widget.phone);
                                    // await sharedPreferences!.setString("address", addressTextEditingController.text.trim());
                                  }
                                  Fluttertoast.showToast(msg: "Successfully Logged in.");
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                                }).catchError((errorMesaage){
                                  Fluttertoast.showToast(msg: "Error Occured: \n $errorMesaage");
                                });
                              } catch (e) {
                                Fluttertoast.showToast(msg: "Wrong OTP");
                                //print("wrong otp");
                              }
                            },
                            child: Text("Verify Phone Number")),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}