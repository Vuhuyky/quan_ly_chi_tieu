import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Thư viện Gemini
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Thư viện giấu key
import 'package:intl/intl.dart';
// import 'package:quan_ly_chi_tieu/services/transaction_service.dart'; // (Tùy chọn)

// Model để chứa tin nhắn
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Khởi tạo Model Gemini
  GenerativeModel? _model;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  void _initializeChatbot() {
    // Lấy API Key từ file .env đã load ở main.dart
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      // Xử lý lỗi nếu không tìm thấy key
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Lỗi: Không tìm thấy GEMINI_API_KEY trong file .env",
            isUser: false,
          ),
        );
      });
      return;
    }

    _model = GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey);
  }

  // Gửi tin nhắn
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || _model == null) return;

    final userMessage = _controller.text;
    _controller.clear();

    // Thêm tin nhắn của người dùng vào UI
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      // === Đây là bước quan trọng: Lấy dữ liệu ngữ cảnh ===
      final String contextData = await _getFinancialContext();

      // Xây dựng Prompt hoàn chỉnh
      final fullPrompt = """
        CHỈ THỊ HỆ THỐNG: 
        Bạn là một chuyên gia tư vấn tài chính cá nhân tên là FinBot. 
        Bạn thân thiện, thông minh và đưa ra lời khuyên dựa trên dữ liệu. 
        Hãy trả lời ngắn gọn (dưới 100 từ) và tập trung vào việc giúp người dùng tiết kiệm tiền.

        DỮ LIỆU NGỮ CẢNH: 
        $contextData

        CÂU HỎI CỦA NGƯỜI DÙNG: 
        $userMessage
      """;

      final content = [Content.text(fullPrompt)];

      // Gọi Gemini API trực tiếp
      final response = await _model!.generateContent(content);

      // Hiển thị câu trả lời của Bot
      setState(() {
        _messages.add(
          ChatMessage(
            text: response.text ?? "Xin lỗi, tôi không thể trả lời câu này.",
            isUser: false,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Đã xảy ra lỗi: $e', isUser: false));
      });
      print("Lỗi_Gemini: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // === Nâng cao: Lấy dữ liệu ngữ cảnh ===
  Future<String> _getFinancialContext() async {
    // Đây là nơi bạn sẽ gọi Firestore để lấy dữ liệu thật
    // Ví dụ (bạn cần tự viết các hàm service này):
    // final double totalExpense = await TransactionService.getTotalExpense(DateTime.now().month, DateTime.now().year);
    // final double foodBudget = await BudgetService.getBudget("Ăn uống");

    // Dữ liệu giả lập để demo
    final double totalExpense = 5000000;
    final double foodExpense = 2000000;
    final double foodBudget = 1500000;

    // Trả về một chuỗi tóm tắt
    return """
      - Tổng chi tiêu tháng này: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalExpense)}
      - Tổng chi cho 'Ăn uống': ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(foodExpense)}
      - Ngân sách cho 'Ăn uống': ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(foodBudget)}
    """;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tư vấn chi tiêu (AI)')),
      body: Column(
        children: [
          // Khu vực hiển thị chat
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true, // Tin nhắn mới nhất ở dưới
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildChatBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          // Khu vực nhập liệu
          _buildTextInput(),
        ],
      ),
    );
  }

  // Bong bóng chat
  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Ô nhập text
  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Hỏi AI Bot điều gì đó...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
