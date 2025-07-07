import 'package:chitchat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';


class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> createNewUserDocument (String uid, String email, String username) async  {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'profileImageUrl': null, 
      'chatIds': [],
    });

   }

     Future<AppUser?>  getAppuser (String uid) async {
    try{
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists){
      return AppUser.fromFirestore(doc);
    }else {
      print('User does not exist for uid: $uid');
      return null;
    }
    } catch (e){
      print('Error in getting user data: $e');
    }

  }

  Future<void> updateLastActive (String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastActive': FieldValue.serverTimestamp(),
    });

  }


  

  Stream<QuerySnapshot> getUsersChat(String userID) {
    // This query fetches chat documents where the 'Participants' array
    // contains the 'userID' of the currently logged-in user.
    // Ensure 'Participants' matches the exact casing in your Firestore database.
    return _firestore
        .collection('chats')
        .where('Participants', arrayContains: userID) //
        .orderBy('lastMessageTimestamp', descending: true) // Orders by last message time
        .snapshots(); // Returns a stream of QuerySnapshots
  }

  }

