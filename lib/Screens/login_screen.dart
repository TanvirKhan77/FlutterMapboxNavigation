import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:users/Screens/phone_login_screen.dart';
import 'package:users/Screens/register_screen.dart';

import '../Global/global.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // create a TextEditingController
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  // declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    // validate all the form fields
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).then((auth)
        {
          currentUser = auth.user;
          Fluttertoast.showToast(msg: "Successfully Logged in!");
          Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
        }).catchError((errorMessage)
        {
          Fluttertoast.showToast(msg: "Error Occurred: \n $errorMessage");
        });


      } catch (e) {
        Fluttertoast.showToast(msg: "Error Occurred.");
      }
      // print("All fields are valid");
    }
    else {
      Fluttertoast.showToast(msg: "Not all fields are valid.");
      // print("All fields are not valid");
    }
  }

  signInWithGoogle(BuildContext context) async {

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth!.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);

      if(userCredential != null){
        FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
            {
              "uid": userCredential.user!.uid,
              "email": userCredential.user!.email.toString(),
              "name": userCredential.user!.displayName.toString(),
            }
        );

        // //save locally
        // sharedPreferences = await SharedPreferences.getInstance();
        // await sharedPreferences!.setString("uid", userCredential.user!.uid);
        // await sharedPreferences!.setString("email", userCredential.user!.email.toString());
        // await sharedPreferences!.setString("name", userCredential.user!.displayName.toString());
      }

      // print(userCredential.user!.displayName);
      // print(userCredential.user!.email);
      // print(userCredential.user!.phoneNumber); //Not working
      // print(userCredential.user!.photoURL);
      // print(userCredential.user!.uid);

      Fluttertoast.showToast(msg: "Successfully logged in.");
      Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
    } catch (e) {
      print("Error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_dark.jpg': 'images/city.jpg'),

                const SizedBox(height: 20,),

                Text(
                  "Sign In",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                    padding: EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Email',
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
                                  prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.amberAccent.shade400 : Colors.grey,),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Email can\'t be empty';
                                  }
                                  if(EmailValidator.validate(text) == true){
                                    return null;
                                  }
                                  else {
                                    return "Please enter a valid Email";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEditingController.text = text;
                                }),
                              ),

                              const SizedBox(height: 20,),

                              TextFormField(
                                obscureText: !_passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Password',
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
                                  prefixIcon: Icon(Icons.lock, color: darkTheme ? Colors.amberAccent.shade400 : Colors.grey,),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      // Based on passwordVisible state choose the icon
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Update the state i.e. toogle the state of passwordVisible variable
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Password can\'t be empty';
                                  }
                                  if (text.length < 6) {
                                    return 'Please enter a valid password';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  passwordTextEditingController.text = text;
                                }),
                              ),

                              const SizedBox(height: 20,),

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

                        const SizedBox(height: 20,),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) =>ForgotPasswordScreen()));
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: darkTheme ? Colors.amberAccent.shade400 : Colors.blue,
                            ),
                          ),
                        ),

                        const SizedBox(height: 60,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.push(context, MaterialPageRoute(builder: (c) => PhoneLoginScreen()));
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.all(10),
                            //     decoration: BoxDecoration(
                            //       color: darkTheme ? Colors.black12 : Colors.grey.shade100,
                            //       borderRadius: BorderRadius.circular(5),
                            //     ),
                            //     child: Row(
                            //       children: [
                            //         // Image.asset('images/google.png',height: 20,),
                            //         Icon(Icons.phone,color: darkTheme ? Colors.amber.shade400 : Colors.black,),
                            //
                            //         SizedBox(width: 10,),
                            //
                            //         Text("Sign In"),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            //
                            // const SizedBox(width: 20,),

                            GestureDetector(
                              onTap: () {
                                signInWithGoogle(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme ? Colors.black12 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset('images/google.png',height: 20,),

                                    SizedBox(width: 10,),

                                    Text("Sign In"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Doesn't have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(width: 5,),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkTheme ? Colors.amberAccent.shade400 : Colors.blue,
                                ),
                              ),
                            )
                          ],
                        ),

                      ],
                    ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



}
