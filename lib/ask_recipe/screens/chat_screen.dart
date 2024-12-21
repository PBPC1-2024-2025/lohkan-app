import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Tambahkan import untuk intl

// Widget untuk layar chatting
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
  final ScrollController _scrollController = ScrollController();

  // Map untuk menyimpan warna pesan untuk setiap pengguna
  final Map<String, Color> _userColors = {}; // Menyimpan warna setiap pengirim pesan

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Memuat pesan saat aplikasi pertama kali dijalankan
  }

  // Fungsi untuk mengirim pesan
  Future<void> _sendMessage(String message) async {
    final url = 'http://10.0.2.2:8000/ask_recipe/send_chat_message/';
    
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      
      // Menyiapkan data yang akan dikirim
      final data = {
        'group_id': widget.groupId,
        'message': message,
      };
      
      final response = await request.postJson(
        url,
        jsonEncode(data),
      );

      // Jika respons berhasil, reset text dan ambil pesan baru
      if (response != null) {
        _messageController.clear();
        await _fetchMessages();
        _scrollToBottom(); // Gulir ke bawah setelah pesan baru dikirim
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send message: No response from server'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fungsi untuk mengambil pesan-pesan dari server
  Future<void> _fetchMessages() async {
    final url = 'http://10.0.2.2:8000/ask_recipe/chat-messages/?group_id=${widget.groupId}';

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.get(url);

      if (response['messages'] != null) {
        setState(() {
          _messages.clear(); // Menghapus pesan sebelumnya
          _messages.addAll(
            List<Message>.from(
              response['messages'].map((msg) => Message(
                sender: msg['user'],
                text: msg['message'],
                isFromCurrentUser: msg['user'] == widget.currentUserName,
                timestamp: DateTime.parse(msg['timestamp']).toLocal(),
                id: msg['id'].toString(),
              ))),
          );
        });
        _scrollToBottom(); // Gulir ke bawah setelah pesan diambil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch messages: $e')),
        );
      }
    }
  }

  // Fungsi untuk menghapus pesan
  Future<void> _deleteMessage(String messageId) async {
    final url = 'http://10.0.2.2:8000/ask_recipe/delete_chat_message/$messageId/';

    try {
      // Ambil cookie dari CookieRequest menggunakan Provider
      final request = Provider.of<CookieRequest>(context, listen: false);
      final cookie = request.cookies.toString();

      // Buat header dengan cookie
      final headers = {
        'Cookie': cookie, // Sertakan cookie dalam header
        'Content-Type': 'application/json',
      };

      // Lakukan permintaan DELETE
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Check if the response is valid JSON
        final jsonResponse = json.decode(response.body);

        // Refresh the message list after successful deletion
        _refreshMessages(messageId);

        // Show a snackbar to confirm deletion
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Handle the error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete message')),
          );
        }
      }
    } catch (e) {
      // Handle any other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  // Fungsi untuk menggulirkan tampilan ke bawah
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // Durasi scroll halus
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Fungsi untuk memperbarui tampilan setelah pesan dihapus
  void _refreshMessages(String messageId) {
    setState(() {
      _messages.removeWhere((msg) => msg.id == messageId);
    });
    _scrollToBottom(); // Gulir ke bawah setelah pesan dihapus
  }

  // Fungsi untuk menentukan warna pesan berdasarkan pengirim
  Color _getMessageColor(String sender) {
    // Jika sender adalah admin, gunakan warna khusus
    if (sender == 'admin') {
      return const Color.fromARGB(255, 85, 3, 0); // Warna khusus untuk admin
    }

    // Jika sender belum memiliki warna, tetapkan warna acak di rumpun merah
    if (!_userColors.containsKey(sender)) {
      final random = Random(sender.hashCode); // Seed dengan hash pengirim
      
      // Menghasilkan nilai untuk red (harus lebih besar dari hijau dan biru)
      final red = random.nextInt(156) + 100;  // Merah lebih dominan
      final green = random.nextInt(101);      // Hijau lebih kecil
      final blue = random.nextInt(101);       // Biru lebih kecil

      // Pastikan nilai red lebih besar dari green dan blue untuk tetap di rumpun merah
      _userColors[sender] = Color.fromARGB(255, red, green, blue);
    }

    return _userColors[sender]!; // Mengembalikan warna pengirim pesan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        widget.groupName,
        style: const TextStyle(
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
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                              fontSize: 16,
                            ),
                          ),
                        SizedBox(height: 4),
                        GestureDetector(
                          child: IntrinsicWidth(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 120,
                                maxWidth: MediaQuery.of(context).size.width * 0.6,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: _getMessageColor(message.sender),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onLongPress: () {
                                      if (message.isFromCurrentUser) {
                                        _showDeleteConfirmationDialog(message.id);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.text,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            softWrap: true,
                                          ),
                                          SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              DateFormat('HH:mm').format(message.timestamp),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
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

  // Fungsi untuk menunjukkan dialog konfirmasi penghapusan pesan
  void _showDeleteConfirmationDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId); // Hapus pesan
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Model pesan untuk digunakan di tampilan pesan
class Message {
  final String sender;
  final String text;
  final bool isFromCurrentUser;
  final DateTime timestamp;
  final String id;

  Message({
    required this.sender,
    required this.text,
    required this.isFromCurrentUser,
    required this.timestamp,
    required this.id,
  });
}
