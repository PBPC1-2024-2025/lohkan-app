import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
              timestamp: DateTime.parse(msg['timestamp']),
            )),
          ),
        );
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Membalik urutan pesan
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
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: message.isFromCurrentUser
                                ? Colors.blue.withOpacity(0.8)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isFromCurrentUser
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                message.timestamp.toString(),
                                style: TextStyle(
                                  color: message.isFromCurrentUser
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
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