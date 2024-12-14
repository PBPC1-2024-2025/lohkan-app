import 'dart:convert';
import 'dart:math' as math; // Tambahkan import untuk math
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Tambahkan import untuk intl

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  late CookieRequest _request;
  final ScrollController _scrollController = ScrollController();

  // Map untuk menyimpan warna pesan untuk setiap pengguna
  final Map<String, Color> _userColors = {}; // Definisikan variabel _userColors di sini

  @override
  void initState() {
    super.initState();
    _request = Provider.of<CookieRequest>(context, listen: false);
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final url = 'http://127.0.0.1:8000/ask_recipe/chat-messages/?group_id=${widget.groupId}';
    final response = await _request.get(url);

    if (response['messages'] != null) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          List<Message>.from(
            response['messages'].map((msg) => Message(
              sender: msg['user'],
              text: msg['message'],
              isFromCurrentUser: msg['user'] == widget.currentUserName,
              timestamp: DateTime.parse(msg['timestamp']).toLocal(), // Konversi ke zona waktu lokal
            )),
          ),
        );
      });
      _scrollToBottom(); // Gulir ke bawah setelah pesan dimuat
    }
  }

  Future<void> _sendMessage(String message) async {
    final url = 'http://127.0.0.1:8000/ask_recipe/send_chat_message/';
    final response = await _request.post(
      url,
      json.encode({
        'group_id': widget.groupId,
        'message': message,
      }),
    );

    if (response != null && response['id'] != null) {
      _messageController.clear();
      _fetchMessages(); // Refresh pesan setelah mengirim
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // Fungsi untuk menentukan warna pesan berdasarkan sender
  Color _getMessageColor(String sender) {
    // Jika sender adalah admin, gunakan warna khusus
    if (sender == 'admin') {
      return const Color.fromARGB(255, 85, 3, 0); // Warna khusus untuk admin
    }

    // Jika sender belum memiliki warna, tetapkan warna acak dalam rumpun merah
    if (!_userColors.containsKey(sender)) {
      _userColors[sender] = _generateRandomRedColor();
    }

    // Kembalikan warna yang telah ditetapkan untuk sender
    return _userColors[sender]!;
  }

  // Fungsi untuk menghasilkan warna acak dalam rumpun merah
  Color _generateRandomRedColor() {
    final random = math.Random(); // Gunakan math.Random untuk menghasilkan angka acak
    final redValue = 100 + random.nextInt(156); // Nilai merah antara 100-255
    final greenValue = 0 + random.nextInt(101); // Nilai hijau antara 0-100
    final blueValue = 0 + random.nextInt(101); // Nilai biru antara 0-100
    return Color.fromARGB(255, redValue, greenValue, blueValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF800000),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Gunakan ScrollController
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: message.isFromCurrentUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: message.isFromCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.sender != widget.currentUserName)
                          Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        SizedBox(height: 4),
                        IntrinsicWidth(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 100, // Batasan minimum lebar pesan
                              maxWidth: MediaQuery.of(context).size.width * 0.6, // Batasan maksimum lebar pesan
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getMessageColor(message.sender), // Gunakan fungsi untuk menentukan warna
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                    softWrap: true, // Membungkus teks jika terlalu panjang
                                  ),
                                  SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.bottomRight, // Posisi timestamp di kanan bawah
                                    child: Text(
                                      DateFormat('HH:mm').format(message.timestamp), // Format hanya jam dan menit
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null, // Memungkinkan teks membungkus ke bawah jika terlalu panjang
                    onSubmitted: (text) {
                      // Mengirim pesan saat tombol Enter ditekan
                      if (text.trim().isNotEmpty) {
                        _sendMessage(text.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Mengirim pesan saat tombol Send ditekan
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      _sendMessage(text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender;
  final String text;
  final bool isFromCurrentUser;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.text,
    required this.isFromCurrentUser,
    required this.timestamp,
  });
}