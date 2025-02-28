import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration? _duration;

  Duration get duration => _duration ?? Duration.zero;
  double get durationInMilliseconds => _duration?.inMilliseconds.toDouble() ?? 0.0;

  Timer? _timer;
  var position = 0.0.obs;
  var positionInDuration = Duration.zero.obs;

  final Dio _dio = Dio();

  var downloadStatus = DownloadStatus.initial.obs;
  var downloadProgress = 0.0.obs;

  var isPlaying = false.obs;
  var isFinished = false.obs;
  String? filePath;

  var message = ''.obs;

  Future<void> downloadAudio() async {
    try {
      downloadStatus.value = DownloadStatus.downloading;
      message.value = 'دانلود صوت شروع شد';

      Directory tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/audio.mp3';
      message.value = 'فایل در مسیر $filePath ذخیره می شود';

      await _dio.download(
        'https://app.didar.me/api/file/download',
        filePath!,
        queryParameters: {
          "id": "04df8965-bddb-456d-9eb6-34e9524e7a0f",
          "losid": "857fbb18-b50a-4828-940d-327f0dd3e9fb",
        },
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Downloading audio file... | ${received / total * 100}');
            message.value = 'در حال دانلود صوت | ${(received / total * 100).toStringAsFixed(2)}';
            downloadProgress.value = (received / total);
          }
        },
      );

      downloadStatus.value = DownloadStatus.downloaded;
      print("✅ Download complete: $filePath");
      message.value = 'صوت دانلود شد';
      startPlayAudio();
    } catch (e) {
      downloadStatus.value = DownloadStatus.initial;
      print("❌ Error downloading: $e");
    }
  }

  Future<void> startPlayAudio() async {
    if (filePath == null) {
      print("There is no file to play!");
      return;
    }

    try {
      message.value = 'در حال آماده سازی پلیر ...';
      await _audioPlayer.setFilePath(filePath!).then((duration) {
        _duration = _audioPlayer.duration;
        _audioPlayer.play();
        _timer = Timer.periodic(
          Duration(milliseconds: 50),
          (timer) {
            position.value =
                _audioPlayer.position.inMilliseconds.clamp(0.0, _duration?.inMilliseconds ?? 0.0).toDouble();
            positionInDuration.value = _audioPlayer.position;
          },
        );
      });

      message.value = '';
      isPlaying.value = true;

      _audioPlayer.playerStateStream.listen((state) async{
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          isFinished.value = true;
        }
      });
    } on PlayerException catch (e) {
      print("Error playing: $e");
    } catch (e) {
      print("Error playing: $e");
    }
  }

  void seekAudio(double milliseconds) async {
    await _audioPlayer.seek(Duration(milliseconds: milliseconds.toInt()));
  }

  void playAudio() {
    _audioPlayer.play();
    isPlaying.value = true;
  }

  void repeatPlay() async {
    await _audioPlayer.seek(Duration.zero);
    isPlaying.value = true;
    isFinished.value = false;
  }

  void pauseAudio() {
    _audioPlayer.pause();
    isPlaying.value = false;
  }

  void seekForward() {
    if (durationInMilliseconds > 0) {
      Duration seekOffset = Duration(milliseconds: (durationInMilliseconds * 0.1).toInt());
      Duration newPosition = positionInDuration.value + seekOffset;

      if (newPosition > duration) {
        newPosition = duration;
      }

      _audioPlayer.seek(newPosition);
    }
  }

  void seekBackward() {
    if (durationInMilliseconds > 0) {
      Duration seekOffset = Duration(milliseconds: (durationInMilliseconds * 0.1).toInt());
      Duration newPosition = positionInDuration.value - seekOffset;

      if (newPosition < Duration.zero) {
        newPosition = Duration.zero;
      }

      _audioPlayer.seek(newPosition);
    }
  }

  void stopAudio() {
    _audioPlayer.stop();
    isPlaying.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    downloadAudio();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // iOS
  Future<void> launchUniversalLinkIOS() async {
    Uri url = Uri.parse('https://app.didar.me/api/file/download?id=04df8965-bddb-456d-9eb6-34e9524e7a0f&losid=857fbb18-b50a-4828-940d-327f0dd3e9fb');

    final bool nativeAppLaunchSucceeded = await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );
    if (!nativeAppLaunchSucceeded) {
      await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
      );
    }
  }
}

enum DownloadStatus {
  initial,
  downloading,
  downloaded;

  bool get isInitial => this == DownloadStatus.initial;

  bool get isDownloading => this == DownloadStatus.downloading;

  bool get isDownloaded => this == DownloadStatus.downloaded;
}
