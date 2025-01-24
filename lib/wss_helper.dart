import 'dart:async';
import 'dart:convert';
import 'package:digitaler_notarzt/authentication_helper.dart';
import 'package:digitaler_notarzt/error_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WssHelper {
  late WebSocketChannel _channel;
  Completer<void>? _streamingCompleter;
  String lastTranscription = "";

  Future<bool> initialize(String backendUrl) async {
    print('[WssHelper] Initializing WebSocket connection to $backendUrl');
    try {
      String storageJwt = await AuthenticationHelper.getToken();
      if (storageJwt.isEmpty) {
        throw Exception("JWT Token empty");
      }
      _channel = WebSocketChannel.connect(Uri.parse(backendUrl + storageJwt));
      await _channel.ready.timeout(const Duration(seconds: 5));
      if (_channel.closeCode == null) {
        return true;
      }
      print('[WssHelper] WebSocket connection to $backendUrl established.');
    } catch (e) {
      //print('[WssHelper] Failed to connect: $e');
      ErrorNotifier().showError("Server connection Error:\n${e.toString()}");
      if (e is WebSocketChannelException) {
        print('WebSocketChannelException: ${e.message}');
        if (e.inner != null) {
          final innerError = e.inner as dynamic;
          print('Inner error: ${innerError.message}');
        }
      } else {
        print('Unbekannter Fehler: ${e.toString()}');
      }
      return false;
    }
    return false;
  }

  void sendMessage(String message) {
    try {
      print('[WssHelper] Sending message: $message');
      _channel.sink.add(message);
      print('[WssHelper] Message sent successfully.');
    } catch (e) {
      print('[WssHelper] Error sending message: $e');
    }
  }

  /// Startet das Streamen von Audio-Daten
  Future<bool> streamAudio(Stream<List<int>> audioStream) async {
    const startMsg = {'type': 'start_audio'};
    const endMsg = {'type': 'stop_audio'};
    final Completer<String?> transcription = Completer<String?>();

    _streamingCompleter = Completer<void>();
    try {
      // Start-Nachricht senden
      print('[WssHelper] Sending start audio message.');
      sendMessage(jsonEncode(startMsg));

      _channel.stream.listen(
        (response) {
          print('[WssReceiver] Received message from Server: $response');
          if (response.toString().contains("Transcription")) {
            if (!transcription.isCompleted) {
              transcription.complete(response);
              _streamingCompleter?.complete();
            }
          }
        },
        onDone: () {
          print('[WssReceiver] WebSocket stream closed by server.');
          if (!transcription.isCompleted) {
            transcription.complete(null); // Keine Antwort erhalten
          }
          if (_streamingCompleter != null &&
              !_streamingCompleter!.isCompleted) {
            _streamingCompleter?.complete();
          }
        },
        onError: (error) {
          print('[WssReceiver] WebSocket error: $error');
          ErrorNotifier().showError('Server connection Error:\n$error');
          if (!transcription.isCompleted) {
            transcription.completeError(error);
          }
          _streamingCompleter?.completeError(error);
          _channel.sink.close(status.protocolError);
        },
      );

      // Audio-Daten streamen
      audioStream.listen(
        (audioStreamData) {
          if (audioStreamData.isNotEmpty) {
            try {
              //print('[WssHelper] Sending audio data packet: ${audioStreamData.length} bytes');
              _channel.sink.add(audioStreamData);
              print('[WssHelper] Audio data packet sent successfully.');
            } catch (e) {
              print('[WssHelper] Error sending audio data: $e');
            }
          }
        },
        onDone: () {
          // End-Nachricht senden und Verbindung schließen
          print(
              '[WssHelper] Audio stream completed. Sending stop audio message.');
          sendMessage(jsonEncode(endMsg));
          //_channel.sink.close(status.normalClosure);
          //print('[WssHelper] WebSocket connection closed after audio streaming.');
        },
        onError: (error) {
          print('[WssHelper] Error during audio streaming: $error');
          _channel.sink.close(status.protocolError);
        },
      );

      // Warten bis der Stream abgeschlossen ist
      //await subscription.asFuture();
      print('[WssHelper] Audio stream subscription completed.');
      final resultTranscription = await transcription.future;
      print(
          '[WssReceiver] Transcription Result from Backend: $resultTranscription');
      _channel.sink.close(status.normalClosure);
      RegExp regex = RegExp(r'Transcription:\s*(.*?)\s*LLM Response:');
      Match? match = regex.firstMatch(resultTranscription!);
      if (match != null) {
        // Extrahierten Text auslesen
        String transcription = match.group(1) ?? '';
        print('Extrahierte Transcription: $transcription');
        lastTranscription = transcription;
      } else {
        print('Kein gültiger Text gefunden.');
      }
      print('[WssHelper] Transcription received, closing Socket.');
    } catch (e) {
      print('[WssHelper] WebSocket error during audio streaming: $e');
      _channel.sink.close(status.goingAway);
    } finally {
      if (_streamingCompleter != null && !_streamingCompleter!.isCompleted) {
        _streamingCompleter?.complete();
      }
    }
    return true;
  }

  Future<void> waitForStreamToFinish() async {
    if (_streamingCompleter != null) {
      await _streamingCompleter!.future;
    }
  }

  void closeConnection() {
    try {
      print('[WssHelper] Closing WebSocket connection.');
      _channel.sink.close();
      print('[WssHelper] WebSocket connection closed successfully.');
    } catch (e) {
      print('[WssHelper] Error closing WebSocket connection: $e');
    }
  }
}
