import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String email;
  final String username;
  final String uid;
  final Timestamp createdAt;
  final Timestamp? lastActive;
  final String? profileImageUrl;
  final List<String> chatIds;
  const AppUser({
    required this.email,
    required this.username,
    required this.uid,
     required this.createdAt,
    this.lastActive,
     this.profileImageUrl,
     this.chatIds = const [],


  });

  factory AppUser.fromFirestore(DocumentSnapshot doc){
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(email: data['email']?? '',
  
      username: data['username']?? 'Unknown username', 
     uid: doc.id,
      createdAt: data ['createdAt']?? Timestamp.now(),
      lastActive: data['lastAcive'] ?? '',
      profileImageUrl: data ['profileImageUrl'] ?? '',
      chatIds: List<String>.from(data['chatIds'] ?? []),

      );
  }
  Map<String, dynamic> toFirestore(){
    return{
      'email': email,
      'username': username,
      'createdAt': createdAt,
      'lastActive': lastActive ?? Timestamp.now(),
      'profileImageUrl': profileImageUrl, 
      'chatIds': chatIds,
      };
  }

}
