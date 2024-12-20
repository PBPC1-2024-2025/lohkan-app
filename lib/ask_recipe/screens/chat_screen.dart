import 'dart:convert';
import 'package:http/http.dart' as http;
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
  final ScrollController _scrollController = ScrollController();

  // Map untuk menyimpan warna pesan untuk setiap pengguna
  final Map<String, Color> _userColors = {}; // Definisikan variabel _userColors di sini

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _sendMessage(String message) async {
    final url = 'http://10.0.2.2:8000/ask_recipe/send_chat_message/';
    
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      
      // Print debug information
      print('Sending message to group: ${widget.groupId}');
      print('Message content: $message');
      
      // Make sure the data is properly formatted
      final data = {
        'group_id': widget.groupId,
        'message': message,
      };
      
      print('Sending data: $data');  // Debug print
      
      final response = await request.postJson(
        url,
        jsonEncode(data),
      );
      
      print('Received response: $response');  // Debug print

      if (response != null) {
        _messageController.clear();
        await _fetchMessages();
        _scrollToBottom();
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
      print('Error sending message: $e');  // Debug print
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

  // Also update the fetch messages method to ensure consistent authentication
  Future<void> _fetchMessages() async {
    final url = 'http://10.0.2.2:8000/ask_recipe/chat-messages/?group_id=${widget.groupId}';

    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final response = await request.get(url);

      if (response['messages'] != null) {
        setState(() {
          _messages.clear();
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
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch messages: $e')),
        );
      }
    }
}

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), // Smooth scroll duration
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _refreshMessages(String messageId) {
    setState(() {
      _messages.removeWhere((msg) => msg.id == messageId);
    });
    _scrollToBottom(); // Gulir ke bawah setelah pesan dihapus
  }

  // Fungsi untuk menentukan warna pesan berdasarkan sender
  Color _getMessageColor(String sender) {
    // Jika sender adalah admin, gunakan warna khusus
    if (sender == 'admin') {
      return const Color.fromARGB(255, 85, 3, 0); // Warna khusus untuk admin
    }

    // Jika sender belum memiliki warna, tetapkan warna acak dalam rumpun merah
    if (!_userColors.containsKey(sender)) {
      final hash = sender.hashCode;
      final red = 100 + (hash % 156);
      final green = 0 + (hash % 101);
      final blue = 0 + (hash % 101);
      _userColors[sender] = Color.fromARGB(255, red, green, blue);
    }

    return _userColors[sender]!;
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
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
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
                                                color: Colors.white.withOpacity(0.8),
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