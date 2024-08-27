class Message{
  final String? text;
  final String? audioFilePath;
  final String? audioDuration;
  final bool isUserMessage;

  Message({this.text, this.audioFilePath, this.audioDuration, required this.isUserMessage});

  bool get isAudioMessage => audioFilePath != null;
}