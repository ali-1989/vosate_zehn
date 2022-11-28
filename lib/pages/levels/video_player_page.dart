import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/enums.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/homeComponents/appBarBuilder.dart';

class VideoPlayerPageInjectData {
  late VideoSourceType videoSourceType;
  late String srcAddress;
  String? heroTag;
  Color? backColor;
  OnFullTimePlay? onFullTimePlay;
  //String? info;
  //TextStyle? infoStyle;
}
///---------------------------------------------------------------------------------
typedef OnFullTimePlay = void Function();
///---------------------------------------------------------------------------------
class VideoPlayerPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/video_player',
    name: (VideoPlayerPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => VideoPlayerPage(injectData: state.extra as VideoPlayerPageInjectData),
  );

  final VideoPlayerPageInjectData injectData;

  VideoPlayerPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerPageState();
  }
}
///=========================================================================================
class VideoPlayerPageState extends StateBase<VideoPlayerPage> {
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;
  Timer? seeToEndTimer;
  Duration? totalTime;

  @override
  void initState() {
    super.initState();

    //infoStyle = widget.injectData.infoStyle?? const TextStyle(color: Colors.white);
    //videoInfo = widget.injectData.videoInformation?? VideoInformation();

    _initVideo();
    Wakelock.enable();
  }

  @override
  void dispose() {
    Wakelock.disable();

    if(seeToEndTimer != null && seeToEndTimer!.isActive) {
      seeToEndTimer!.cancel();
    }

    playerController?.removeListener(listener);
    chewieVideoController?.dispose();
    playerController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.injectData.backColor?? Colors.black,
      appBar: AppBarCustom(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Hero(
                tag: widget.injectData.heroTag?? '',
                child: isVideoInit?
                    Chewie(controller: chewieVideoController!)
                    : Center(child: CircularProgressIndicator())
            ),
          ),
        ]
      ),
    );
  }
  /*
  AspectRatio(
              aspectRatio: playerController?.value.aspectRatio?? 16/10,
   */

  void update(){
    if(mounted){
      setState(() {});
    }
  }

  void _initVideo(){
    switch(widget.injectData.videoSourceType){
      case VideoSourceType.file:
        playerController = VideoPlayerController.file(File(widget.injectData.srcAddress));
        break;
      case VideoSourceType.network:
        playerController = VideoPlayerController.network(widget.injectData.srcAddress);
        break;
      case VideoSourceType.bytes:
        break;
      case VideoSourceType.asset:
        playerController = VideoPlayerController.asset(widget.injectData.srcAddress);
        break;
    }

    playerController!.initialize().then((value) {
      isVideoInit = playerController!.value.isInitialized;
      _onVideoInit();
    });
  }

  void _onVideoInit(){
    chewieVideoController = ChewieController(
      videoPlayerController: playerController!,
      autoPlay: true,
      allowFullScreen: true,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: true,
      allowMuting: true,
      autoInitialize: true,
      fullScreenByDefault: false,
      looping: false,
      isLive: false,
      zoomAndPan: false,
      showControls: true,
      showControlsOnInitialize: true,
      showOptions: true,
      playbackSpeeds: [1, 1.5, 2],
      placeholder: Center(child: CircularProgressIndicator()),
      materialProgressColors: ChewieProgressColors(
          handleColor: AppThemes.instance.currentTheme.differentColor,
          playedColor: AppThemes.instance.currentTheme.differentColor,
          backgroundColor: Colors.green, bufferedColor: AppThemes.instance.currentTheme.primaryColor,
      ),
    );

    //int w = playerController!.value.size.width.toInt(); //?? 440
    //int h = playerController!.value.size.height.toInt(); //?? 260

    playerController!.addListener(listener);

    update();
  }

  void listener() async {
    if(playerController?.value.duration != null){
      totalTime = playerController!.value.duration;
    }

    if((chewieVideoController?.isPlaying?? false) && totalTime != null){
      startTimerForSeeFull();
    }
  }

  void startTimerForSeeFull(){
    if(seeToEndTimer == null || !seeToEndTimer!.isActive) {
      seeToEndTimer = Timer(totalTime! - Duration(seconds: 3), () {
        widget.injectData.onFullTimePlay?.call();
      });
    }
  }
}
