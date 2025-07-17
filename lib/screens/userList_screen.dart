import 'package:chitchat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chitchat/services/database_service.dart';

  class UserListScreen extends StatelessWidget {
    final String currentUserId;
  const UserListScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select users to chat'),
        backgroundColor: Colors.grey[400],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUserId).snapshots(), 
        builder: (context, snapshot)
        {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index ){
              final userData = users[index].data() as Map <String, dynamic>;
              final userId = users[index].id;
              final userName = userData['username'] ?? 'unnamed' ;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(userName[0].toUpperCase())),
                  title: Text(userName),
                  onTap: () async {
                    final chatId = await DatabaseService().getOrCreateChat(currentUserId, userId);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, chatName: userName
                    ),
                    ),
                    );
                 },
              );
            },
          );
        },
      ),
    );
  }
  }

