import 'package:chitchat/screens/home_screen.dart';
import 'package:chitchat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(
           body: Center(
            child: CircularProgressIndicator(),
           ),
          );
        }else if (snapshot.hasData){
          return const HomeScreen();
        } else {
          return LoginScreen();
        }
      }
      );
  }
}