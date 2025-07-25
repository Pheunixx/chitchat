import 'package:chitchat/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/screens/home_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final TextEditingController _message = TextEditingController();
final DatabaseService _databaseService = DatabaseService();
final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
final ScrollController _scroll = ScrollController();
int? _expandedIndex;

@override
  void initState() {
    super.initState();


  }

void _sendMessage () async {
  final text = _message.text.trim();
  if(text.isEmpty) return;


  await _databaseService.sendMessage(
    chatId : widget.chatId,
    senderId :currentUserId,
    message: text,
  );
  
_message.clear();
await Future.delayed(Duration(milliseconds: 300));
if (_scroll.hasClients){
_scroll.animateTo(_scroll.position.maxScrollExtent, duration: Duration(milliseconds: 100), curve: Curves.easeOut);}

  
  //Focus.of(context).unfocus();
}
@override
  void dispose() {
    super.dispose();
    _message.dispose();
  }

  Widget _chatScreenContent () {
    return
    Column(
      children: [
        Expanded(
          child: StreamBuilder(stream: _databaseService.getChatMessage(widget.chatId),
                     builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty){
                        return const Center(child: Text("No messages here yet"));
                        
                      }
                       final messages = snapshot.data!.docs;
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                  
                    if (_scroll.hasClients){
                _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  
                });
                    
                      return ListView.builder(
                       //reverse: true,
                       controller: _scroll,
                       keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: messages.length ,
                        itemBuilder: (context, index){
                          final message = messages[index].data() as Map <String , dynamic>;
                          final isMe = message ['senderId'] == currentUserId;
                          //final content = message ['text'] ?? '';
                          final Timestamp timestamp = message['timestamp'] as Timestamp;
                          final DateTime time = timestamp.toDate();
                          final formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                          final isDeleted = message ['deleted'] == true; 
                         final content = isDeleted ? 'This message was deleted' : message['text'] ?? ''; 
                         final isExpanded = _expandedIndex == index;
                
                          
                return GestureDetector(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                    if (isMe && !isDeleted) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Delete Message?'),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _databaseService.deleteMessage(
                            chatId: widget.chatId,
                            messageId: messages[index].id,
                          );
                        },
                        child: Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                );
                    }
                  },
                  onDoubleTap:() {
                    setState(() {
                      _expandedIndex = isExpanded ? null: index;

                    });
                  },
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    
                    child: AnimatedContainer( 
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                padding:  EdgeInsets.all(isExpanded ? 20: 12),
                decoration: BoxDecoration(
                  color: _expandedIndex == index
        ? (isMe ? Colors.deepPurple : Colors.blueGrey)
        : (isMe ? Colors.blue[50] : Colors.grey),
                  borderRadius: BorderRadius.circular(isExpanded? 25 : 15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isDeleted ? "This message was deleted" : content,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
                    ),
                  ),
                );
                
                    //               alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    //               child: ConstrainedBox(constraints: BoxConstraints(
                    //   // Max width will be 75% of the screen width. Adjust 0.75 as needed.
                    //   maxWidth: MediaQuery.of(context).size.width * 0.65,
                    // ),
                    //                 child: Container(
                    //                   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //                   padding: EdgeInsets.all(12) ,
                    //                   decoration: BoxDecoration(
                    //                     color: isMe ? Colors.purple[50] : Colors.blueGrey,
                    //                     borderRadius: BorderRadius.circular(15)
                    //                   ),
                    //                   child:  Column(
                    //                   crossAxisAlignment: CrossAxisAlignment.end,
                    //                   children: [
                    //                     Text(
                    //                       content,
                    //                       style: const TextStyle(color: Colors.black87, fontFamily: 'Tiktok', fontSize: 18),
                    //                     ),
                    //                     const SizedBox(height: 4),
                    //                     Text(
                    //                       formattedTime,
                    //                       style: const TextStyle(color: Colors.blue, fontSize: 10),
                    //                     ),
                    //                   ],
                    //                 ),
                              
                    //                 ),
                    //               ),
                    //             );
                
                        }
                        );
                     }
                     ),
        ),
        _buildMessageInput(),
      ],
    );
  }
  Widget _buildMessageInput () {
return
                Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
               color: Colors.white,
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller: _message,
                      style: TextStyle(fontFamily: 'Roboto'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      
                    ),
                    
                    ),
                    SizedBox(width: 8,),
                    IconButton(onPressed: _sendMessage, 
                    icon: Icon(Icons.send, color: Colors.deepPurpleAccent),
                    
                    ),
                  ],
               )
               );
            
          
  }

    @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isSmallScreen = constraints.maxHeight < 600;

      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: isSmallScreen
              ? Column(
                  children: [
                    Expanded(child: _chatScreenContent()),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _chatScreenContent()),
                  ],
                ),
        ),
      );
    },
  );
}

}