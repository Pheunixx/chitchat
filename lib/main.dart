import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_state.dart';
import 'package:chitchat/services/seesion_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SessionManager().initSession();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) => 
  context.findAncestorStateOfType<_MyAppState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  void toggleTheme(bool isDark){
    //ThemeMode themeMode = ThemeMode.light;
    setState(() {
      _themeMode = isDark? ThemeMode.dark : ThemeMode.light;
    });
  }
  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode ,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.deepPurple,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: Colors.grey[300],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18)
        )
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black87,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
          
        )
      ),
      home: AuthGate(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'ChitChat',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const AuthGate(),
//     );
//   }
// }

  

