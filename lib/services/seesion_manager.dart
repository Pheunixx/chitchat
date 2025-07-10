class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  SessionManager._internal();

  final String customerId = "7354";
  final String customerName = "Aisha";
  late String sessionId;

  void initSession() {
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void clearSession() {
    sessionId = "";
  }
}
