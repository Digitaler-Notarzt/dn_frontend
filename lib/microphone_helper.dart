import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class MicrophoneHelper {
  final AudioRecorder streamer = AudioRecorder();
  bool isStreaming = false;
  late Stream<List<int>> _audioStreamSubscription;

  Future<void> stopStreaming() async {
    await streamer.stop();
    isStreaming = false;
  }

  Future<void> startStreaming() async {
    await streamer.hasPermission();
    _audioStreamSubscription = await streamer.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 2,
        sampleRate: 44100,
        bitRate: 128000,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );
    isStreaming = true;
    await stream('http://127.0.0.1:8000/audio-stream');
  }

  Future<void> toggleStreaming() async {
    if (isStreaming) {
      await stopStreaming();
      print("Stream stopped");
    } else {
      await startStreaming();
      print("Stream started");
    }
  }

  Future<void> stream(String backendUrl) async {
    final url = Uri.parse(backendUrl);

    _audioStreamSubscription.listen((audioStreamData) async {
      if (audioStreamData.isNotEmpty) {
        // if may not work
        try {
          var response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/octet-stream',
            },
            body: audioStreamData,
          );

          if (response.statusCode != 200) {
            print('Fehler beim Senden des Streams: ${response.statusCode}');
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }
}
