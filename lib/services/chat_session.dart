class ChatSession {
  static final  ChatSession _instance = ChatSession._internal();
  factory ChatSession () => _instance;
  ChatSession._internal();

  String? sessionId;
  String? customerId;
  String? customerName;


  void clear(){
    sessionId = null;
    customerId =null;
    customerName = null;
  }

   bool get hasSession => sessionId != null && customerId != null;
}