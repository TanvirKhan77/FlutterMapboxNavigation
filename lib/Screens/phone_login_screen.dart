import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/Screens/verify_screen.dart';

import '../Global/global.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {

  final phoneTextEditingController = TextEditingController();

  // declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    void _submit() async {
      // validate all the form fields
      if (_formKey.currentState!.validate()) {
        await firebaseAuth.verifyPhoneNumber(
          phoneNumber: '${phoneTextEditingController.text}',
          timeout: Duration(seconds: 20),
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {},
          codeSent: (String VerificationId, int? resendToken) {
            PhoneLoginScreen.verify = VerificationId;
            Navigator.push(context, MaterialPageRoute(builder: (c) => VerifyScreen(phone: phoneTextEditingController.text,)));
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
        // Navigator.push(context, MaterialPageRoute(builder: (c) => VerifyScreen()));
        // print("All fields are valid");
      }
      else {
        Fluttertoast.showToast(msg: "Field is not valid.");
        // print("All fields are not valid");
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_dark.jpg': 'images/city.jpg'),

                const SizedBox(height: 20,),

                Text(
                  "Phone Login",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10,),

                Text(
                  "Phone enter your phone number for verfication.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // const SizedBox(height: 20,),

                Padding(
                  padding: EdgeInsets.fromLTRB(20,20,20,20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Phone',
                            hintStyle: TextStyle(
                              color: darkTheme ? Colors.grey : Colors.grey,
                            ),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                          initialCountryCode: 'BD',
                          onChanged: (text) {
                            phoneTextEditingController.text = text.completeNumber;
                            //when phone number country code is changed
                            // print(phone.completeNumber); //get complete number
                            // print(phone.countryCode); // get country code only
                            // print(phone.number); // only phone number
                          },
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: darkTheme ? Colors.amberAccent.shade400 : Colors.blue,
                            onPrimary: darkTheme ? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            // validateForm(context);
                            _submit();
                            // Navigator.push(context, MaterialPageRoute(builder: (c) => VerifyScreen()));
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),

                      ],
                    ),
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
