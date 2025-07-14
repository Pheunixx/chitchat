import 'package:chitchat/screens/home_screen.dart';
import 'package:chitchat/screens/signup_screen.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final  TextEditingController _emailController, _passwordController;
  bool _isLoading = false;
  String? _errorMessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
   
   @override


  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {

    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _Login () async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
  setState(() {
    _errorMessage = null;
    _isLoading = true;
  });

  if(email.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = 'Please fill both fields';
    });
    setState(() {
      _isLoading = false;
    });
    return;
  }
  if (!emailRegex.hasMatch(email)){
        setState(() {
          _errorMessage = 'Plase enter a valid email address';
        });
        setState(() {
          _isLoading = false;
        });
        return;
  }
  try{
    final UserCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    print('User successfully signed in : ${UserCredential.user?.uid}');
    if (mounted){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
    }


  } on FirebaseAuthException catch (e){
    setState(() {
      if(e.code == 'user-not-found'){
        _errorMessage = 'No user found for this email';
    }
    else if (e.code == 'wrong-password'){
      _errorMessage = 'Password is incorrect';
    }
    else if(e.code == 'invalid-credential'){
       _errorMessage = 'Incorrect Email or Password';
    
    }else {
      _errorMessage = 'Unknown error!';
  }
    });
    
  } 
  finally {
    setState(() {
      _isLoading = false;
    });
    
  }

  }

  Future <void> _googleLogIn () async {
    try{
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn.standard(scopes: ['email']).signIn();

      if(googleUser == null){
        setState(() {
          _isLoading = false;
        });
        return;
      } 
        final GoogleSignInAuthentication googleauth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleauth.accessToken,
          idToken: googleauth.idToken );
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          
          if(userCredential.additionalUserInfo!.isNewUser){
            String username = googleUser.displayName ?? googleUser.email.split('@')[0];
            await _dbService.createNewUserDocument(userCredential.user!.uid, 
            userCredential.user!.email!, username);
            print('New google user data Stored in firestore for : ${userCredential.user!.uid}');

          } else {
            await _dbService.updateLastActive(userCredential.user!.uid);
            print('Existing google user signed in : ${userCredential.user!.uid}');
          }
          print('DEBUG: Attempting to navigate to Home Screen...');
          if (mounted){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
    
    } on FirebaseAuthException catch (e){
      setState(() {
        _errorMessage = e.message;
        print('Firebase Auth Googke sign in error :${e.code}-${e.message}');
      });

    } catch (e){
      setState(() {
        _errorMessage = 'Google sign in failed. Please try again : $e';
        print('Google sign in general errror : $e');
      });
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
      ),
      
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Login To your ChitChat Account',
            style: TextStyle(fontSize: 20, color: Colors.deepPurple,fontWeight: FontWeight.bold),
            ),
            const SizedBox( height: 25,),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox (height:16,),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 35,),

            _isLoading ? const Center(
              child: CircularProgressIndicator())
              :ElevatedButton(onPressed: _Login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                )
              ),
               child: Text('Login',
               style: TextStyle(fontSize: 18,),
               )
               ),
            const SizedBox(height: 20,),

            if (_errorMessage != null)
            Padding(padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            ),

            const SizedBox(height: 2 ,),

          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
          }, child: Text('New user? Tap to Register')),

            const Text('-OR-',
            style: TextStyle( fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
            textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20,),

            ElevatedButton.icon(onPressed: _isLoading ? null: _googleLogIn, 
            icon: Image.asset('assets/google_logo.png',
            height: 20,
            ),
            label: const Text('Sign in with google', 
            style: TextStyle(fontSize: 18,),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 50),
              shape:RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              elevation: 2.0,
            ),
            )

            
          ],
          
        ),
      ),
    );
  }
}