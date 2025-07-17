import 'package:chitchat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';


class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future <void> createNewUserDocument (String uid, String email, String username) async  {
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

  

Future<void> sendMessage({
  required String chatId,
  required String senderId,
  required String message,
   
  }) async {
    final chatDoc =FirebaseFirestore.instance.collection('chats').doc(chatId);
await chatDoc.collection('messages').add({
  'text': message,
  'senderId' :senderId,
  'timestamp': FieldValue.serverTimestamp(),
  'deleted': false,
});
await chatDoc.update({
  'lastMessage': message,
  //'lastMessageTimestamp':FieldValue.serverTimestamp()
});
  }

   Stream<QuerySnapshot> getChatMessage(String chatId ) {
    return FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: false).snapshots();
   }  

   Future<void> deleteMessage ({
    required String chatId,
    required String messageId,
    }) async {
      final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final messageDoc = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').doc(messageId);
  await messageDoc.update({
    'text': 'This message was deleted',
    'deleted': true,
     'lastMessageDeleted': true,
    'lastMessage': 'this message was deleted',
  });

    await chatDoc.update({ 
      'lastMessage': 'This message was deleted',
    'lastMessageTimestamp': FieldValue.serverTimestamp(), 
    });
  
   }

  Future<String> getOrCreateChat(String user1, String user2) async {
  final chatsRef = FirebaseFirestore.instance.collection('chats');

  // Check if a chat already exists between the two users
  final query = await chatsRef.where('Participants', arrayContains: user1).get();

  for (var doc in query.docs) {
    final data = doc.data();
    if ((data['Participants'] as List).contains(user2)) {
      return doc.id;
    }
  }

  // Get usernames
  final user1Doc = await FirebaseFirestore.instance.collection('users').doc(user1).get();
  final user2Doc = await FirebaseFirestore.instance.collection('users').doc(user2).get();

  final user1Name = user1Doc.data()?['username'] ?? 'User1';
  final user2Name = user2Doc.data()?['username'] ?? 'User2';

  // Create the participantNames map
  final participantNames = {
    user1: user2Name,
    user2: user1Name,
  };

  // Create the new chat
  final newChat = await chatsRef.add({
    'Participants': [user1, user2],
    'participantNames': participantNames,
    'lastMessage': '',
    'lastMessageTimestamp': FieldValue.serverTimestamp(),
  });

  return newChat.id;
}


Future<void> fixChatNamesForUser(String userId) async {
  final chatsRef = FirebaseFirestore.instance.collection('chats');

  final querySnapshot = await chatsRef
      .where('Participants', arrayContains: userId)
      .get();

  for (var doc in querySnapshot.docs) {
    final data = doc.data();

    // Skip if chatName already exists
    if (data.containsKey('chatName') && data['chatName'].toString().trim().isNotEmpty) {
      continue;
    }

    final participants = List<String>.from(data['Participants']);
    final otherUserId = participants.firstWhere((id) => id != userId);

    // Get other user's name
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
    final otherUsername = userDoc.data()?['username'] ?? 'User';

    // Update chatName
    await doc.reference.update({
      'chatName': otherUsername,
    });
  }
}

//delete chats
Future <void> deleteChat (String chatId) async {
  await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
}
  }

