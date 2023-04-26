import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/Assistants/assistant_methods.dart';
import 'package:users/Global/global.dart';
import 'package:users/InfoHandler/app_info.dart';
import 'package:users/Screens/home_screen.dart';
import 'package:users/Screens/login_screen.dart';
import 'package:users/Screens/register_screen.dart';
import 'package:users/testNavigation/fao_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if(await firebaseAuth.currentUser != null){
        firebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    startTimer();
  }
  
  
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Text(
          'Uber Clone',
          style: TextStyle(
            color: darkTheme ? Colors.white : Colors.blue,
            fontSize: 50,
          ),
        ),
      ),
    );
  }
}
