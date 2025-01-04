import 'package:flutter/material.dart';

class Message{
  final Text? text;
  final String? audioFilePath;
  final String? audioDuration;
  final bool isUserMessage;

  Message({this.text, this.audioFilePath, this.audioDuration, required this.isUserMessage});

  bool get isAudioMessage => audioFilePath != null;
}