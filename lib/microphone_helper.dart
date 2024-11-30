import 'dart:convert';

import 'package:digitaler_notarzt/streamreceiver.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MicrophoneHelper {
  final AudioRecorder streamer = AudioRecorder();
  bool isStreaming = false;
  late Stream<List<int>> _audioStreamSubscription;

  Future<void> stopStreaming() async {
    if (!isStreaming) return;

    await streamer.stop();
    _audioStreamSubscription = const Stream.empty();
    isStreaming = false;
    print("Streaming stopped");
  }

  Future<void> startStreaming() async {
    if (isStreaming) {
      print("Already streaming");
      return;
    }

    final hasPermission = await streamer.hasPermission();
    if (!hasPermission) {
      print("Microphone permission denied");
      return;
    }

    _audioStreamSubscription = await streamer.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 44100,
        //bitRate: 128000,
        //echoCancel: true,
        //noiseSuppress: true,
      ),
    );
    isStreaming = true;

    try {
      await stream('ws://192.168.27.122:8000/audio-stream');
    } catch (e) {
      print("Error while streaming: $e");
    }
  }

  Future<void> toggleStreaming() async {
    if (isStreaming) {
      await stopStreaming();
    } else {
      await startStreaming();
    }
  }

  //https://docs.flutter.dev/cookbook/networking/web-sockets
  //https://pub.dev/packages/web_socket_channel
  //https://docs.flutter.dev/data-and-backend/serialization/json

  Future<void> stream(String backendUrl) async {
    final channel = WebSocketChannel.connect(Uri.parse(backendUrl));
    const startmsg = {'type': 'start_audio'};
    const endmsg = {'type': 'stop_audio'};

    final receiver = StreamReceiver(channel);
    receiver.listen();
    try {
      await channel.ready.timeout(const Duration(seconds: 3));
      // Verbindung starten
      print('WebSocket gestartet, Nachricht gesendet: ${jsonEncode(startmsg)}');
      channel.sink.add(jsonEncode(startmsg));

      // Stream-Daten anhören
      _audioStreamSubscription.listen((audioStreamData) {
        if (audioStreamData.isNotEmpty) {
          try {
            // Senden der Audio-Daten über den WebSocket
            channel.sink.add(audioStreamData);
            print('Audio-Datenpaket gesendet');
          } catch (e) {
            print('Fehler beim Senden von Audio-Daten: $e');
          }
        }
      }, onDone: () {
        // Beenden der Verbindung, wenn der Stream abgeschlossen ist
        print('Stream beendet, Nachricht gesendet: ${jsonEncode(endmsg)}');
        channel.sink.add(jsonEncode(endmsg));
        channel.sink.close();
      }, onError: (error) {
        print('Fehler beim Streamen: $error');
        channel.sink.close();
      });
    } catch (e) {
      print('WebSocket-Fehler: $e');
    }
  }
}
