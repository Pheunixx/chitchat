import 'package:chitchat/main.dart';
import 'package:chitchat/screens/chat_screen.dart';
import 'package:chitchat/screens/chat_bot.dart';
import 'package:chitchat/screens/login_screen.dart';
import 'package:chitchat/screens/settings_screen.dart';
import 'package:chitchat/screens/userList_screen.dart';
import 'package:chitchat/screens/user_screen.dart';
import 'package:chitchat/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';


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

//final deleteChat = await FirebaseFirestore.instance.collection('chats').doc(chatId)
  
 Widget _buildChatListBody() {
  return
  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'search...',
              hintStyle: TextStyle( fontSize: 15
                //color: Colors.white
              ),
               prefixIcon: Icon(Icons.search, ),
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
              final Map<String, dynamic> namesMap = Map<String, dynamic>.from(chatData['participantNames'] ?? {});
              String chatName = 'Unnamed chat';
    if (namesMap.isNotEmpty && currentUserId != null && namesMap.containsKey(currentUserId)) {
    chatName = namesMap[currentUserId] ?? 'Unnamed chat';
    }
    
    
              final String lastMessage = chatData['lastMessage']?.toString() ?? 'No Message';
              final bool lastMessageDeleted = chatData['lastMessageDeleted'] == true;
              final String messageToShow = lastMessageDeleted ? 'This message was deleted' : lastMessage;
    
              final Timestamp? rawTimestamp = chatData ['lastMessageTimestamp'] as Timestamp?;
              final DateTime lastMessageDateTime = rawTimestamp?.toDate()?? DateTime.now();
    
           return  GestureDetector(
            onLongPress: () {
            HapticFeedback.lightImpact();
              showDialog(
                context: context, 
                builder: (context) =>AlertDialog(
                  title: Text("Delete chat"),
                  content: Text('Are you sure you want to delete this chat?'),
                  actions: [
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                    }, child: Text("Cancel")),
                    TextButton(onPressed: () async {
                     await FirebaseFirestore.instance.
                     collection('chats').
                     doc(chatId).delete();
                     Navigator.pop(context);
                     setState(() {
                       
                     });
                    }, 
                    child: Text('delete'),
                     )
                  ],
                )
              );
            },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(chatName.isNotEmpty? chatName[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.white,
                    ),
                    ),
                backgroundColor: Colors.deepPurpleAccent),
                  title: Text(chatName, 
                  style:TextStyle(fontWeight: FontWeight.bold, 
                  //color: Colors.white),
                  )
                  ),
                    subtitle: Text(messageToShow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                       style: TextStyle(fontFamily: 'Tiktok', fontSize: 16 //color: Colors.grey[400]
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
                  ),
              );
                
              
            },
            );
         }
           
         else {
         return const Text('No messages here yet');
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
    if (currentUserId != null) {
    _databaseService.fixChatNamesForUser(currentUserId!);
  }
  
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
  
    return Scaffold(
     // backgroundColor: Colors.black12,
      appBar: AppBar(
        title: const Text("Chats",
       style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        //foregroundColor: Colors.white,
 actions: [
        Switch(value: isDark, 
        onChanged: (bool value) {
          MyApp.of(context)?.toggleTheme(value);
        }),
           IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserListScreen(currentUserId: currentUserId!,)));
           }, 
           icon: Icon(Icons.person_add), color:Colors.white ,
           tooltip: 'New message',),

           IconButton(onPressed: (){
            print('Create Group');
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBotScreen()));
          },
           icon: Icon(Icons.group_add), color: Colors.white,
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
          //BottomNavigationBarItem(icon: Icon(Icons.people),
          //label: 'Group'),
          BottomNavigationBarItem(icon: Icon(Icons.logout),
          label: 'Logout',
          ),
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 2, 10),
        unselectedItemColor: Colors.white,
        //backgroundColor: Colors.deepPurpleAccent,
        type: BottomNavigationBarType.fixed,
        onTap: (index)  async {
  if (index == 2) { 
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Logout'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
    } else {
        
          setState(() {
            _selectedIndex = index;
          });
        }
        },
      )
     // backgroundColor: Colors.grey[900]
    );

    
    
  }
  }