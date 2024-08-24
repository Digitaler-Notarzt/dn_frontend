import 'package:flutter/material.dart';
import 'package:digitaler_notarzt/messages.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isKeyboardVisibl = false;

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        messages
            .add(Message(text: _controller.text.trim(), isUserMessage: true));
        _controller.clear();

        messages.add(Message(text: 'Nachricht erhalten', isUserMessage: false));

        _scrollToBottom();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Digitaler Notarzt'),
          actions: [
            _buildPopupMenu(context),
          ],
        ),
        body: GestureDetector(
          onTap: _dismissKeyboard,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                ),
              ),
              _buildMessageInput()
            ],
          ),
        ));
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: message.isUserMessage
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.isUserMessage ? 'Ich' : 'Digitaler Notarzt',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65),
              decoration: BoxDecoration(
                color: message.isUserMessage ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                message.text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        // child:
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Nachricht eingeben...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'logout':
            print('User pressed logout');
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'settings',
          child: Text('Einstellungen'),
        ),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('Profil'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Abmelden'),
        ),
      ],
    );
  }
}
