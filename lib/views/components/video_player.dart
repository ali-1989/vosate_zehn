import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/tools/app/app_themes.dart';

/// has usage in below

class VideoPlayerView extends StatefulWidget {
  late final VideoSourceType videoSourceType;
  late final String srcAddress;
  final bool allowFullScreen;
  final bool looping;
  final bool showControls;
  final bool autoPlay;

  VideoPlayerView({
    Key? key,
    required this.videoSourceType,
    required this.srcAddress,
    this.allowFullScreen = false,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerViewState();
  }
}
///=========================================================================================
class VideoPlayerViewState extends StateSuper<VideoPlayerView> {
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;

  @override
  void initState() {
    super.initState();

    _initVideo();
  }

  @override
  void dispose() {
    chewieVideoController?.dispose();
    playerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: isVideoInit?
        Chewie(controller: chewieVideoController!)
            : const Center(child: CircularProgressIndicator())
    );
  }

  void update(){
    if(mounted){
      setState(() {});
    }
  }

  void _initVideo(){
    switch(widget.videoSourceType){
      case VideoSourceType.file:
        playerController = VideoPlayerController.file(File(widget.srcAddress));
        break;
      case VideoSourceType.network:
        playerController = VideoPlayerController.network(widget.srcAddress);
        break;
      case VideoSourceType.bytes:
        break;
      case VideoSourceType.asset:
        playerController = VideoPlayerController.asset(widget.srcAddress);
        break;
    }

    playerController!.initialize().then((value) {
      isVideoInit = playerController!.value.isInitialized;
      if(mounted){
        _onVideoInit();
      }
    });
  }

  void _onVideoInit(){
    chewieVideoController = ChewieController(
      videoPlayerController: playerController!,
      autoPlay: widget.autoPlay,
      allowFullScreen: widget.allowFullScreen,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: true,
      allowMuting: true,
      autoInitialize: true,
      fullScreenByDefault: false,
      looping: widget.looping,
      isLive: false,
      zoomAndPan: false,
      showControls: widget.showControls,
      showControlsOnInitialize: true,
      showOptions: true,
      playbackSpeeds: [1, 1.5, 2],
      placeholder: const Center(child: CircularProgressIndicator()),
      materialProgressColors: ChewieProgressColors(
          handleColor: AppThemes.instance.currentTheme.differentColor,
          playedColor: AppThemes.instance.currentTheme.differentColor,
          backgroundColor: Colors.green, bufferedColor: AppThemes.instance.currentTheme.primaryColor,
      ),
    );

    update();
  }
}

/* usage:

void showVideo(){
    showDialog(
        context: context,
        builder: (ctx){
          return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            backgroundColor: Colors.black,
            body: VideoPlayerView(
              videoSourceType: VideoSourceType.network,
              srcAddress: 'http://techslides.com/demos/sample-videos/small.mp4',
            ),
          );
        }
    );
  }
 */