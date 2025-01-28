import 'package:digitaler_notarzt/microphone_helper.dart';
import 'package:flutter/foundation.dart';

class StreamNotifier extends ChangeNotifier {
  bool isRecording = false;
  String? backendResponse;
  String audioStatus = "idle";
  final MicrophoneHelper microphoneHelper;
  int startTime = 0;
  String? formatedDuration;

  StreamNotifier({required this.microphoneHelper});

  void startRecording() {
    isRecording = true;
    startTime = DateTime.now().millisecondsSinceEpoch;
    audioStatus = "streaming";
    backendResponse = null;
    microphoneHelper.startStreaming();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    isRecording = false;
    audioStatus = "processing";

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    Duration duration = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch-startTime);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    formatedDuration = "$twoDigitMinutes:$twoDigitSeconds";

    notifyListeners();

    await microphoneHelper.stopStreaming();
    backendResponse = microphoneHelper.lastTranscription;
    audioStatus = "done";
    notifyListeners();
  }

  void reset() {
    isRecording = false;
    backendResponse = null;
    audioStatus = "idle";
    startTime = 0;
    formatedDuration = null;
  }
}