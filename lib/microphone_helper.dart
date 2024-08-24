import 'package:another_audio_recorder/another_audio_recorder.dart';
import 'dart:io';

class MicrophoneHelper {
  late AnotherAudioRecorder _audioRecorder;
  bool _isRecording = false;
  final String _filePath;

  MicrophoneHelper(this._filePath) {
    _audioRecorder = AnotherAudioRecorder(_filePath);
  }

  Future<void> toggleRecording() async {
    if(_isRecording) {
      final recording = await _audioRecorder.stop();
      _isRecording = false;

      if(recording != null) {
        print('Aufnahme gespeichert unter: ${recording.path}');
      }
    }else{
      try {
        await _audioRecorder.start();
        _isRecording = true;
      } catch(e) {
        print('Fehler beim Aufnahme starten: $e');
      }
    }
  }

  bool get isRecording => _isRecording;
}

