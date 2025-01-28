import 'package:digitaler_notarzt/notifier/stream_notifier.dart';
import 'package:digitaler_notarzt/widgets/error_listener.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:digitaler_notarzt/messages.dart';
import 'package:digitaler_notarzt/microphone_helper.dart';
import 'package:digitaler_notarzt/widgets/popup_menu.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StreamNotifier(microphoneHelper: MicrophoneHelper()),
      child: const ChatScreenContent(),
    );
  }
}

class ChatScreenContent extends StatefulWidget {
  const ChatScreenContent({super.key});

  @override
  _ChatScreenContentState createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<ChatScreenContent> {
  List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isKeyboardVisibl = false;
  int startTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissKeyboard();
    });
  }

  void _toggleRecording() async {
    final streamNotifier = Provider.of<StreamNotifier>(context, listen: false);

    if (!streamNotifier.isRecording) {
      // Aufnahme starten
      streamNotifier.startRecording();
    } else {
      // Aufnahme beenden
      streamNotifier.stopRecording();

      // Nach Beenden der Aufnahme sofort die Benutzer-Audio-Nachricht anzeigen
      final duration = streamNotifier.formatedDuration;
      final pendingId = UniqueKey().toString();

      setState(() {
        // Zeige die Audio-Nachricht
        messages.add(AudioMessage(
          id: UniqueKey().toString(),
          status: "pending", // Zeigt an, dass die Antwort noch verarbeitet wird
          audioDuration: duration!,
          isUserMessage: true,
        ));

        // Zeige eine Placeholder-Nachricht mit Ladeindikator
        messages.add(TextMessage(
          id: pendingId,
          text: const Text(
            "Antwort wird verarbeitet...",
            style: TextStyle(color: Colors.grey),
          ),
          isUserMessage: false,
        ));
        _scrollToBottom();
      });

      // Warte auf die Antwort des Backends
      streamNotifier.addListener(() {
        if (streamNotifier.audioStatus == "done") {
          // Backend-Antwort erhalten
          setState(() {
            // Ersetze die Placeholder-Nachricht durch die tatsächliche Antwort
            final index = messages.indexWhere((m) => m.id == pendingId);
            if (index != -1) {
              messages[index] = TextMessage(
                id: UniqueKey().toString(),
                text: Text(
                  streamNotifier.backendResponse ?? "Keine Antwort erhalten.",
                  style: const TextStyle(color: Colors.white),
                ),
                isUserMessage: false,
              );
            }
            _scrollToBottom();
          });
        }
      });
    }
  }

  void _sendAudioMessage(String duration, String transcription) {
    setState(() {
      messages.add(AudioMessage(
          id: UniqueKey().toString(),
          status: "done",
          audioDuration: duration,
          isUserMessage: true));
      _scrollToBottom();
    });

    messages.add(TextMessage(
      id: UniqueKey().toString(),
      text: Text(transcription),
      isUserMessage: false,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      // Nachricht senden und das UI aktualisieren
      setState(() {
        messages.add(TextMessage(
            id: UniqueKey().toString(),
            text: Text(
              _controller.text.trim(),
              style: const TextStyle(color: Colors.white),
            ),
            isUserMessage: true));
        _controller.clear();
        _scrollToBottom();
      });

      if (kIsWeb) {
        // Verzögerte Antwort im Web
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            messages.add(TextMessage(
                id: UniqueKey().toString(),
                text: const Text('Nachricht erhalten'),
                isUserMessage: false));
            _scrollToBottom(); // Scroll nach dem Empfang der Antwort
          });
        });
      } else {
        // Verzögerte Antwort auf mobilen Geräten
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            messages.add(TextMessage(
                id: UniqueKey().toString(),
                text: const Text('Nachricht erhalten'),
                isUserMessage: false));
            _scrollToBottom(); // Scroll nach dem Empfang der Antwort
          });
        });
      }

      // Scroll nach dem Senden der Nachricht
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _sendFailMessage() {
    messages.add(TextMessage(
        id: UniqueKey().toString(),
        isUserMessage: true,
        text: const Text(
          "Nachricht konnte nicht versendet werden",
          style: TextStyle(color: Colors.red),
        )));
  }

  void _dismissKeyboard() {
    _focusNode.unfocus();
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
    final streamNotifier = Provider.of<StreamNotifier>(context);

    /*if (streamNotifier.audioStatus == "done" &&
        streamNotifier.backendResponse != null) {
      _sendAudioMessage(streamNotifier.formatedDuration ?? "00:00",
          streamNotifier.backendResponse!);

      if (mounted) {
        Provider.of<StreamNotifier>(context, listen: false).reset();
      }
    }*/

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text('Digitaler Notarzt'),
          actions: [
            PopupMenu(dismissKeyboard: _dismissKeyboard),
          ],
        ),
        body: ErrorListener(
          child: SafeArea(
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
                        if (message is AudioMessage) {
                          return _buildAudioMessageBubble(message);
                        } else {
                          return _buildTextMessageBubble(
                              message as TextMessage);
                        }
                      },
                    ),
                  ),
                  _buildMessageInput(context, streamNotifier)
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTextMessageBubble(TextMessage message) {
  bool isPending = message.text.data!.contains("Antwort wird verarbeitet...");

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
              color: message.isUserMessage
                  ? Colors.grey[400]
                  : Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: isPending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.text.data!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : message.text,
          ),
        ],
      ),
    ),
  );
}


  Widget _buildAudioMessageBubble(AudioMessage message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: message.isUserMessage
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
                color:
                    message.isUserMessage ? Colors.grey[400] : Colors.redAccent,
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

  Widget _buildMessageInput(
      BuildContext context, StreamNotifier streamNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              autofocus: false,
              focusNode: _focusNode,
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
            onPressed: _toggleRecording/*() {
              if (streamNotifier.isRecording) {
                streamNotifier.stopRecording();
              } else {
                streamNotifier.startRecording();
              }
            },*/,
            icon: Icon(streamNotifier.isRecording ? Icons.stop : Icons.mic),
            color: Colors.green[400],
            iconSize: 40.0,
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.red[400],
            iconSize: 40.0,
          ),
        ],
      ),
    );
  }
}
