import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';

class VideoPlayerPageInjectData {
  late VideoSourceType videoSourceType;
  late String srcAddress;
  String? heroTag;
  Color? backColor;
  OnFullTimePlay? onFullTimePlay;
}
///-----------------------------------------------------------------------------
typedef OnFullTimePlay = void Function();
///-----------------------------------------------------------------------------
class VideoPlayerPage extends StatefulWidget {
  final VideoPlayerPageInjectData injectData;

  const VideoPlayerPage({
    super.key,
    required this.injectData,
  });

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerPageState();
  }
}
///=============================================================================
class VideoPlayerPageState extends StateSuper<VideoPlayerPage> {
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

    playerController?.removeListener(videoTimeListener);
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
                child: Builder(
                  builder: (_){
                    /*if(kIsWeb){
                      return VideoJsWidget(
                        videoJsController: videoJsController,
                        height: sh,
                        width: sw,
                      );
                    }*/

                    if(isVideoInit){
                      return Directionality(
                        textDirection: TextDirection.ltr,
                          child: Chewie(controller: chewieVideoController!)
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
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
    /*if(kIsWeb){
      final op = VideoJsOptions(
          language: 'en',
          controls: true,
          loop: false,
          muted: false,
          fluid: false,
          liveui: false,
          preferFullWindow: false,
          responsive: false,
        suppressNotSupportedError: false,
        //poster: 'https://file-examples-com.github.io/uploads/2017/10/file_example_JPG_100kB.jpg',
        //aspectRatio: '16:9',
        notSupportedMessage: 'متاسفانه قابل پخش نیست',
          playbackRates: [1, 2],
          sources: [Source(widget.injectData.srcAddress, 'video/mp4')],

      );

      videoJsController = VideoJsController(
          'videoId',
          videoJsOptions: op,
      );

      return;
    } */

    //widget.injectData.srcAddress = widget.injectData.srcAddress.replaceFirst('vosatezehn.com', '162.223.90.121');
    final headers = <String, String>{};

    headers['user'] = '${SessionService.getLastLoginUser()?.userId}';
    headers['token'] = '${SessionService.getLastLoginUser()?.token?.token}';

    switch (widget.injectData.videoSourceType) {
      case VideoSourceType.file:
        playerController = VideoPlayerController.file(File(widget.injectData.srcAddress));
        break;
      case VideoSourceType.network:
        playerController = VideoPlayerController.networkUrl(
            Uri.parse(widget.injectData.srcAddress),
            httpHeaders: headers
          );
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
      placeholder: const Center(child: CircularProgressIndicator()),
      materialProgressColors: ChewieProgressColors(
          handleColor: AppThemes.instance.currentTheme.differentColor,
          playedColor: AppThemes.instance.currentTheme.differentColor,
          backgroundColor: Colors.green, bufferedColor: AppThemes.instance.currentTheme.primaryColor,
      ),
    );

    //int w = playerController!.value.size.width.toInt(); //?? 440
    //int h = playerController!.value.size.height.toInt(); //?? 260

    playerController!.addListener(videoTimeListener);

    update();
  }

  void videoTimeListener() async {
    if(playerController?.value.duration != null){
      totalTime = playerController!.value.duration;
    }

    if((chewieVideoController?.isPlaying?? false) && totalTime != null){
      startTimerForSeeFull();
    }
  }

  void startTimerForSeeFull(){
    if(seeToEndTimer == null || !seeToEndTimer!.isActive) {
      int tSec = totalTime!.inSeconds;
      int nSec = MathHelper.percentInt(tSec, 10);

      widget.injectData.onFullTimePlay?.call();//hack

      seeToEndTimer = Timer(Duration(seconds: nSec), () {
        widget.injectData.onFullTimePlay?.call();
      });
    }
  }
}
