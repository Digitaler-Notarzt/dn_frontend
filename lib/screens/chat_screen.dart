import 'package:flutter/material.dart';
import 'package:digitaler_notarzt/messages.dart';
import 'package:digitaler_notarzt/microphone_helper.dart';
import 'package:digitaler_notarzt/widgets/popup_menu.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MicrophoneHelper _microphoneHelper;
  bool isKeyboardVisibl = false;
  bool _isRecording = false;
  int startTime = 0;

  @override
  void initState() {
    super.initState();
    _microphoneHelper = MicrophoneHelper();
  }

  void _toggleRecording() async {
    await _microphoneHelper.toggleRecording();
    if (!_microphoneHelper.isRecording) {
      int duration = DateTime.timestamp().millisecondsSinceEpoch - startTime;
      _sendAudioMessage(_microphoneHelper.recordingPath!, duration);
    }
    setState(() {
      _isRecording = _microphoneHelper.isRecording;
      startTime = DateTime.timestamp().millisecondsSinceEpoch;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _sendAudioMessage(String audioFilePath, int durationMillis) {
    Duration duration = Duration(milliseconds: durationMillis);
    String formattedDuration = _formatDuration(duration);

    setState(() {
      messages.add(Message(audioFilePath: audioFilePath, audioDuration: formattedDuration, isUserMessage: true));
      _scrollToBottom();
    });

    messages.add(Message(text: 'Nachricht erhalten', isUserMessage: false));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Digitaler Notarzt'),
          actions: const [
            PopupMenu(),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: _dismissKeyboard,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                    if (message.isAudioMessage) {
                      return _buildAudioMessageBubble(message);
                    } else {
                      return _buildTextMessageBubble(message);
                    }
                    },
                  ),
                ),
                _buildMessageInput()
              ],
            ),
          ),
        ));
  }

  Widget _buildTextMessageBubble(Message message) {
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65),
              decoration: BoxDecoration(
                color: message.isUserMessage ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(
                message.text!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: message.isUserMessage
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isAudioMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.isUserMessage ? 'Ich' : 'Digitaler Notarzt',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65),
              decoration: BoxDecoration(
                color: message.isUserMessage ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.audio_file_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Audio ${message.audioDuration}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal:  8.0),
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
            onPressed: _toggleRecording,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            color: Colors.greenAccent,
            iconSize: 40.0,
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.blueAccent,
            iconSize: 40.0,
          ),
        ],
      ),
    );
  }
}
