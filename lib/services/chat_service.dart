import 'package:dio/dio.dart';
import 'chat_session.dart';

class ChatService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://legendai.onrender.com/api/chat';

  Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          "message": message,
          if (ChatSession().sessionId != null) "session_id": ChatSession().sessionId,
          if (ChatSession().customerId != null) "customer_id": ChatSession().customerId,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        ChatSession().sessionId = data['session_id']?.toString();
        ChatSession().customerId = data['customer_id']?.toString();
        ChatSession().customerName = data['customer_name'];

        return data['response'];
      } else {
        return "Oops! Something went wrong (${response.statusCode})";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
