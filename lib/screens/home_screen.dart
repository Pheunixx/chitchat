import 'package:chitchat/screens/chat_screen.dart';
import 'package:chitchat/screens/chat_bot.dart';
import 'package:chitchat/screens/login_screen.dart';
import 'package:chitchat/screens/settings_screen.dart';
import 'package:chitchat/screens/user_screen.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  int _selectedIndex = 0;

  late final List <Widget> _widgetOptions;

  
 Widget _buildChatListBody() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'search...',
            hintStyle: TextStyle(
              color: Colors.white
            ),
             prefixIcon: Icon(Icons.search, color:Colors.white ,),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 3.0)
          ),
        ),
        ),
        Expanded(child: 
  StreamBuilder(
        stream: _databaseService.getUsersChat(currentUserId!),
       builder: (context, snapshot){
        if (snapshot.connectionState ==ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError){
            print('StreamBuilder Error: ${snapshot.error}');
         return const Center(
          child: const Text('An error occured: '),
         );
       }
       else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty){
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final chatDocument = snapshot.data!.docs [index];
            final Map<String, dynamic> chatData = chatDocument.data() as Map<String, dynamic>;
            final String chatId = chatDocument.id;
            final String chatName = chatData['chatName']?.toString() ?? 'Unnamed chat';
            final String lastMessage = chatData['lastMessage']?.toString() ?? 'No Message';
            final bool lastMessageDeleted = chatData['lastMessageDeleted'] == true;
            final String messageToShow = lastMessageDeleted ? 'This message was deleted' : lastMessage;

            final Timestamp? rawTimestamp = chatData ['lastMessageTimestamp'] as Timestamp?;
            final DateTime lastMessageDateTime = rawTimestamp?.toDate()?? DateTime.now();

            return ListTile(
              leading: CircleAvatar(
                child: Text(chatName.isNotEmpty? chatName[0].toUpperCase() : '?',
                style: TextStyle(color: Colors.white,
                ),
                ),
            backgroundColor: Colors.deepPurpleAccent),
              title: Text(chatName, 
              style:TextStyle(fontWeight: FontWeight.bold, 
              color: Colors.white),
              ),
                subtitle: Text(messageToShow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                   style: TextStyle(fontFamily: 'Tiktok', color: Colors.grey[400]
                    ),
                      ),

                  
                  
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                      chatId : chatId,
                      chatName: chatName,

                    
                    ),
                    ),
                    );
                    print('Tapped on chat : $chatName (ID: $chatId )');
                  },
              );
              
            
          },
          );
       }
       
       
       else {
       return const Text('No chat yet');
       }
       
 }
 )
  )
  ]
  );
          
       
       
       


 }
 @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
    _buildChatListBody(),
    const UserScreen(),
    const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chats",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,

        actions: [
        
           IconButton(onPressed: (){}, 
           icon: Icon(Icons.person_add),
           tooltip: 'New message',),

           IconButton(onPressed: (){
            print('Create Group');
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen()));
          },
           icon: Icon(Icons.group_add),
           tooltip: 'Create New Group',
           
           ),

        ],
      ),

      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.chat),
          label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.call),
          label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.people),
          label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.settings),
          label: 'Settings',
          ),
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 2, 10),
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      backgroundColor: Colors.grey[900]
    );
    
    
  }
  }