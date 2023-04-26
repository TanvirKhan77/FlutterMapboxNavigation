import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/Global/global.dart';
import 'package:users/Screens/forgot_password_screen.dart';
import 'package:users/Screens/home_screen.dart';
import 'package:users/Screens/login_screen.dart';
import 'package:users/Screens/phone_login_screen.dart';
import 'package:users/Screens/verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  // static String verify = "";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  // declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    // validate all the form fields
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;

        if(currentUser != null){
          //Save to Firestore
          // FirebaseFirestore.instance
          //     .collection("users")
          //     .doc(currentUser!.uid)
          //     .set(
          //     {
          //       "uid": currentUser!.uid,
          //       "email": currentUser!.email,
          //       "name": nameTextEditingController.text.trim(),
          //       "address": addressTextEditingController.text.trim(),
          //       "phone": phoneTextEditingController.text.trim(),
          //     });

          Map userMap = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
          };

          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);



          //save locally
          // sharedPreferences = await SharedPreferences.getInstance();
          // await sharedPreferences!.setString("uid", currentUser!.uid);
          // await sharedPreferences!.setString("email", currentUser!.email!);
          // await sharedPreferences!.setString("name", nameTextEditingController.text.trim());
          // await sharedPreferences!.setString("phone", phoneTextEditingController.text.trim());
          // await sharedPreferences!.setString("address", addressTextEditingController.text.trim());
        }
        await Fluttertoast.showToast(msg: "Successfully Registered!");
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
      }).catchError((errorMesaage){
        Fluttertoast.showToast(msg: "Error Occured: \n $errorMesaage");
      });
      // print("All fields are valid");
    }
    else {
      Fluttertoast.showToast(msg: "Not all fields are valid.");
      // print("All fields are not valid");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  signInWithGoogle(BuildContext context) async {

    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth!.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential? userCredential = await firebaseAuth.signInWithCredential(
        credential
    ).then((auth) async {
      currentUser = auth.user;

    });

    if(currentUser != null){
      // FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(currentUser!.uid)
      //     .set(
      //     {
      //       "uid": currentUser!.uid,
      //       "email": userCredential!.user!.email.toString(),
      //       "name": userCredential.user!.displayName.toString(),
      //       // "address": addressTextEditingController.text.trim(),
      //       // "phone": ,
      //     });

      Map userMap = {
        "id": currentUser!.uid,
        "name":  userCredential!.user!.displayName.toString(),
        "email":  userCredential.user!.email.toString(),
        "address": addressTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
      userRef.child(currentUser!.uid).set(userMap);

      //save locally
      // sharedPreferences = await SharedPreferences.getInstance();
      // await sharedPreferences!.setString("uid", currentUser!.uid);
      // await sharedPreferences!.setString("email", userCredential.user!.email.toString());
      // await sharedPreferences!.setString("name", userCredential.user!.displayName.toString());
      // await sharedPreferences!.setString("phone", widget.phone);
      // await sharedPreferences!.setString("address", addressTextEditingController.text.trim());
    }
    Fluttertoast.showToast(msg: "Successfully logged in.");

    // print(userCredential.user!.displayName);
    // print(userCredential.user!.email);
    // print(userCredential.user!.phoneNumber); //Not working
    // print(userCredential.user!.photoURL);
    // print(userCredential.user!.uid);

    Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
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
                  "Register",
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
                                hintText: 'Name',
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
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amberAccent.shade400 : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Name can\'t be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid name';
                                }
                                if(text.length > 49){
                                  return 'Name can\'t be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                nameTextEditingController.text = text;
                              }),
                            ),

                            const SizedBox(height: 20,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
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
                                if(text.length > 100){
                                  return 'Email can\'t be more than 100 characters';
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

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              decoration: InputDecoration(
                                hintText: 'Address',
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
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amberAccent.shade400 : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return 'Name can\'t be empty';
                                }
                                if (text.length < 2) {
                                  return 'Please enter a valid name';
                                }
                                if(text.length > 99){
                                  return 'Address can\'t be more than 100 characters';
                                }
                              },
                              onChanged: (text) => setState(() {
                                addressTextEditingController.text = text;
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
                                if(text == null || text.isEmpty) {
                                  return 'Password can\'t be empty';
                                }
                                if(text.length < 6) {
                                  return 'Please enter a valid password';
                                }
                                if(text.length > 49){
                                  return 'Password can\'t be more than 50';
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                passwordTextEditingController.text = text;
                              }),
                            ),

                            const SizedBox(height: 20,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50)
                              ],
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
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
                                  return 'Confirm password can\'t be empty';
                                }
                                if (text.length < 6) {
                                  return 'Please enter a valid password';
                                }
                                if(text != passwordTextEditingController.text){
                                  return "Password do not match";
                                }
                                if(text.length > 49){
                                  return 'Confirm password can\'t be more than 50';
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                confirmPasswordTextEditingController.text = text;
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
                              onPressed: () async {
                                _submit();
                              },
                              child: const Text(
                                'Register',
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

                      const SizedBox(height: 20,),

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
                          //         Icon(Icons.phone,color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
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
                            "Have an account?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(width: 5,),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 15,
                                color: darkTheme ? Colors.amberAccent.shade400 : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),

                ),
              ],
            )
          ],
        ),
      ),
    );
  }

}
