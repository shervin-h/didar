import 'dart:io';
import 'package:didar/src/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_controller.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AudioController audioController = Get.put(AudioController());
    double width = context.mediaQuerySize.width;
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text(
          'تسک استخدامی شروین حسن زاده',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              shervinSection(audioController),
              const SizedBox(width: 8),
              didarLogo(0.5 * width),
              Expanded(child: const SizedBox()),
              message(audioController),
              const SizedBox(height: 32),
              audioTitle(),
              const SizedBox(height: 16),
              audioSlider(audioController),
              const SizedBox(height: 4),
              durationTracker(audioController),
              const SizedBox(height: 24),
              playerButtons(audioController),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

Widget shervinSection(AudioController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/shervin.jpg'),
        ),
        const SizedBox(width: 8),
        Text(
          'shervin.hz07@gmail.com',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(child: const SizedBox(width: 4)),
        IconButton(
          onPressed: () {
            if (Platform.isIOS) {
              controller.launchUniversalLinkIOS();
            }
          },
          icon: Icon(
            CupertinoIcons.cloud_download,
            color: Colors.white,
          ),
        )
      ],
    ),
  );
}

Widget didarLogo(double size) {
  return Center(
    child: Image.asset('assets/logo.png', width: size, height: size),
  );
}

Widget audioTitle() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'صوت آزمایشی سی آر ام دیدار',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'سجاد رحمانی پور',
          style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
        ),
      ],
    ),
  );
}

Widget audioSlider(AudioController controller) {
  return Obx(
    () {
      if (controller.downloadStatus.value.isInitial || controller.downloadStatus.value.isDownloading) {
        return IgnorePointer(
          child: Slider(
            min: 0.0,
            max: 1.0,
            value: controller.downloadProgress.value,
            onChanged: (value) {},
            thumbColor: Colors.transparent,
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.grey.shade400,
          ),
        );
      }
      return Slider(
        min: 0.0,
        max: controller.durationInMilliseconds,
        value: controller.position.value,
        onChanged: (value) {
          controller.seekAudio(value);
        },
        onChangeStart: (value) {
          controller.pauseAudio();
        },
        onChangeEnd: (value) {
          controller.playAudio();
        },
        activeColor: Colors.cyan,
        inactiveColor: Colors.grey.shade600,
        thumbColor: Colors.cyan,
      );
    },
  );
}

Widget durationTracker(AudioController controller) {
  return Obx(
    () => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.downloadStatus.value != DownloadStatus.downloaded
                ? '00.00'
                : controller.positionInDuration.value.toMMSS(),
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            controller.downloadStatus.value != DownloadStatus.downloaded ? '00.00' : controller.duration.toMMSS(),
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

Widget playerButtons(AudioController controller) {
  return Obx(
    () {
      bool isDownloaded = controller.downloadStatus.value != DownloadStatus.downloaded;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: isDownloaded ? null : () {controller.seekBackward();},
            icon: Icon(
              CupertinoIcons.backward_fill,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: isDownloaded
                ? null
                : () {
                    if (controller.isFinished.value) {
                      controller.repeatPlay();
                    } else {
                      controller.isPlaying.value ? controller.pauseAudio() : controller.playAudio();
                    }
                  },
            icon: Icon(
              controller.isPlaying.value ? CupertinoIcons.pause : CupertinoIcons.play,
              size: 48,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: isDownloaded ? null : () {controller.seekForward();},
            icon: Icon(CupertinoIcons.forward_fill, color: Colors.white),
          ),
        ],
      );
    },
  );
}

Widget message(AudioController controller) {
  return Obx(() {
    return controller.message.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.greenAccent),
                    color: Colors.greenAccent.withAlpha(20),
                  ),
                  child: Text(
                    controller.message.value,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          )
        : const SizedBox();
  });
}
