import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class MicrophoneHelper {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;

  Future<void> toggleRecording() async {
    if(isRecording) {
      String? filePath = await audioRecorder.stop();
      if(filePath != null) {
        isRecording = false;
        recordingPath = filePath;
        print('Audio saved under: ${recordingPath}');
      }
    } else {
      if(await audioRecorder.hasPermission()) {
        isRecording = true;
        recordingPath = null;
        final Directory path = await getApplicationDocumentsDirectory();
        final String filePath = p.join(path.path, 'recording.wav');
        await audioRecorder.start(const RecordConfig(), path: filePath);
      }
    }
  }
}