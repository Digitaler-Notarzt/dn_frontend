import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;

class MicrophoneHelper {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioRecorder streamer = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;
  late Stream<List<int>> _audioStreamSubscription;

  Future<void> toggleRecording() async {
    if (isRecording) {
      if (kIsWeb) {
        await streamer.stop();
        isRecording = false;
        print('Stream stopped');
      } else {
        String? filePath = await audioRecorder.stop();
        await streamer.stop();
        print('Stopped stream and record');
        if (filePath != null) {
          isRecording = false;
          recordingPath = filePath;
          print('Audio saved under: $recordingPath');
        }
      }
    } else {
      if (kIsWeb) {
        if (await streamer.hasPermission()) {
          isRecording = true;
          await startStreaming('http://192.168.175.168:8000/upload');
          print('Stream started');
        }
      } else {
        if (await audioRecorder.hasPermission() &&
            await streamer.hasPermission()) {
          isRecording = true;
          recordingPath = null;
          final Directory path = await getApplicationDocumentsDirectory();
          final String timestamp =
              '${DateTime.timestamp().hour}_${DateTime.timestamp().minute}';
          final String filePath = p.join(path.path, 'recording$timestamp.wav');
          await audioRecorder.start(const RecordConfig(), path: filePath);
          await startStreaming('http://192.168.175.168:8000/upload');
          print('Started stream and record');
        }
      }
    }
  }

  // Future<void> toggleRecording() async {
  //   if(isRecording) {
  //     await streamer.stop();
  //     isRecording = false;
  //   } else {
  //     if (await streamer.hasPermission()) {
  //       isRecording = true;
  //       await startStreaming('http://10.0.0.112:8000/upload');
  //       print('stream started');
  //     }
  //   }
  // }

  Future<void> startStreaming(String backendUrl) async {
    if (await streamer.hasPermission()) {
      final url = Uri.parse(backendUrl);

      _audioStreamSubscription = await streamer.startStream(
        const RecordConfig(encoder: AudioEncoder.pcm16bits),
      );

      _audioStreamSubscription.listen((audioStreamData) async {
        if (audioStreamData.isNotEmpty) {
          try {
            var response = await http.post(
              url,
              headers: {
                'Content-Type': 'application/octet-stream',
              },
              body: streamer
                  .convertBytesToInt16(Uint8List.fromList(audioStreamData)),
            );

            if (response.statusCode != 200) {
              print('Fehler beim Senden des Streams: ${response.statusCode}');
            }
            print(response.body);
          } catch (e) {
            print(e);
          }
        }
      });
    }
  }
}
