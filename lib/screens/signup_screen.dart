import 'package:chitchat/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:chitchat/screens/home_screen.dart';
class SignUpScreen extends StatefulWidget {
  
  const SignUpScreen({super.key, });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _emailController,_passwordController, _usernameController;
  String? _errorMessage;
  bool _isLoading =false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  @override
   void initState() {
  
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose(); 
    _usernameController.dispose();}

   Future<void>_signUp () async{
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    if(email.isEmpty || password.isEmpty || username.isEmpty){
      setState(() {
        _errorMessage = 'Please fill all provided fields';
      });
      setState(() {
        _isLoading = false;
      });
      return;
      }
      if( !emailRegex.hasMatch(email)){
        setState(() {
          _errorMessage = 'Plase enter a valid email address';
        });
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if(password.length < 6){
        setState(() {
          _errorMessage = 'Password must be at least 6 characters long';
        });
        setState(() {
          _isLoading =false;
        });
        return;
      }
     try {
      final UserCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
           print('user registered successfully: ${UserCredential.user?.uid}');
      if (UserCredential.user != null){
        await _dbService.createNewUserDocument(
          UserCredential.user!.uid,
          email,
          username,
        );
        //await _dbService.createNewUserDocument(
          //UserCredential.user!.uid,
          //email,
          //username,
        //);
        print("User credentials stored successfully on firestore for : ${UserCredential.user!.uid}");
      
      }
        print('DEBUG: Attempting to navigate to Home Screen...');
        if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
        
    } on FirebaseAuthException catch (e){
      setState(() {
        if (e.code == 'weak-password'){
        _errorMessage = 'password is weak';
        }
        else if (e.code == 'email-already-in-use'){
          _errorMessage = 'Email is already in use';
        } else if (e.code == 'invalid-email'){
          _errorMessage = 'Invalid email address';
        } else {
          _errorMessage = 'An unknown error occurred';
        }
      });
    
      
      } finally{
        setState(() {
          _isLoading = false;
        });
      }
    }

    Future<void> _signInWithGoogle () async {
    
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
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueAccent,
      
      
    ),
    body: SingleChildScrollView( // Allows scrolling if content exceeds screen height (e.g., keyboard appears)
      padding: const EdgeInsets.all(24.0), // Consistent padding around the form
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Vertically center content if space allows
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons and fields stretch horizontally
        children: [
          const SizedBox(height:50), // Top spacing for visual balance

          // --- SCREEN TITLE/HEADER ---
          const Text(
            'Create Your ChitChat Account', // Clear and welcoming title
            style: TextStyle(
              fontSize: 28, // Increased font size for prominence
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            textAlign: TextAlign.center, // Center the text
          ),
          const SizedBox(height: 40), // Spacer after the title

          // --- EMAIL TEXT FIELD (IMPROVED DECORATION) ---
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            obscureText: false,
            decoration: const InputDecoration( // Added label, border, and icon
              hintText: 'Enter your Email here',
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16), // Consistent spacing between fields

          // --- PASSWORD TEXT FIELD (IMPROVED DECORATION) ---
          TextField(
            controller: _passwordController,
            enableSuggestions: false,
            obscureText: true, // Password should be obscured
            decoration: const InputDecoration( // Added label, border, and icon
              hintText: 'Enter your password here',
              labelText: 'Password', // Corrected label
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock), // Corrected icon
            ),
          ),
          const SizedBox(height: 16), // Consistent spacing

          // --- USERNAME TEXT FIELD (IMPROVED DECORATION) ---
          TextField(
            controller: _usernameController,
            enableSuggestions: true, // Username can have suggestions
            obscureText: false, // Username should NOT be obscured
            decoration: const InputDecoration( // Added label, border, and icon
              hintText: 'Enter your username here',
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 24), // Spacer before buttons

          // --- MANUAL SIGN UP BUTTON & LOADING INDICATOR ---
          // Button is disabled and shows a spinner if _isLoading is true
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // Centered spinner when loading
              : ElevatedButton(
                  onPressed: _signUp, // Linked to your manual sign-up method
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Full width, decent height
                    backgroundColor: Colors.blueAccent, // Consistent primary color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
            
                ),
          const SizedBox(height: 16), // Spacer after manual button

          // --- ERROR MESSAGE DISPLAY ---
          // Only displayed if _errorMessage has content
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0), // Padding above the error message
              child: Text(
                _errorMessage!, // Display the error message content
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center, // Center the error text
              ),
            ),
          const SizedBox(height: 20), // Spacer after error message

          // --- "OR" SEPARATOR ---
          const Text(
            '— OR —',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // Spacer after "OR"

          // --- GOOGLE SIGN-IN BUTTON ---
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _signInWithGoogle, // Disabled if loading
            icon: Image.asset( // Image for Google logo (ensure asset path is correct!)
              'assets/google_logo.png',
              height: 24.0, // Adjusted height for better visual
            ),
            label: const Text('Sign in with Google', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              elevation: 2, // A subtle shadow
            ),
          ),
          const SizedBox(height: 20), // Spacer after Google button

          // --- NAVIGATE TO LOGIN SCREEN BUTTON ---
          TextButton(
            onPressed: () {
              // Navigate to Login Screen (assuming '/login' route is defined)
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));;
            },
            child: const Text(
              'Already have an account? Log in',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    ),
  );
}}