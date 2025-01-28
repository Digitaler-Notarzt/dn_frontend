import 'package:flutter/material.dart';

abstract class ChatMessage {
  final String id;
  final bool isUserMessage;
  
  ChatMessage({required this.id, required this.isUserMessage});
}

class TextMessage extends ChatMessage{
  final Text text;

  TextMessage({
    required String id,
    required bool isUserMessage,
    required this.text
  }) : super(id: id, isUserMessage: isUserMessage);
}

class AudioMessage extends ChatMessage {
  final String status;
  final String audioDuration;

  AudioMessage({
    required String id,
    required bool isUserMessage,
    required this.status,
    required this.audioDuration
  }) : super(id: id, isUserMessage: isUserMessage);
}

class Message{
  final Text? text;
  final String? audioFilePath;
  final String? audioDuration;
  final bool isUserMessage;

  Message({this.text, this.audioFilePath, this.audioDuration, required this.isUserMessage});

  bool get isAudioMessage => audioFilePath != null;
}