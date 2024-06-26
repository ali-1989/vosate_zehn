import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/circle_container.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/levels/playback_disposition.dart';
import 'package:app/views/pages/levels/slider.dart';

/// note: for iOS: must visit page and add code to Info.plist

enum AudioSourceType {
  file,
  network,
  bytes,
  asset
}

class AudioPlayerPageInjectData {
  late AudioSourceType audioSourceType;
  late String srcAddress;
  Uint8List? bytes;
  String? pageTitle;
  String? title;
  String? subTitle;
  Color? backColor;
  OnFullTimePlay? onFullTimePlay;
}
///-----------------------------------------------------------------------------
typedef OnFullTimePlay = void Function();
///-----------------------------------------------------------------------------
class AudioPlayerPage extends StatefulWidget{

  final AudioPlayerPageInjectData injectData;

  // ignore: prefer_const_constructors_in_immutables
  AudioPlayerPage({
    super.key,
    required this.injectData,
  });

  @override
  State<StatefulWidget> createState() {
    return AudioPlayerPageState();
  }
}
///=============================================================================
class AudioPlayerPageState extends StateSuper<AudioPlayerPage> {
  bool isAudioInit = false;
  late ImageProvider background;
  AudioPlayer audioPlayer = AudioPlayer();
  Duration totalTime = const Duration();
  Duration currentTime = const Duration();
  late StreamController<PlaybackDisposition> durationStreamCtr;
  Timer? seeToEndTimer;

  @override
  void initState() {
    super.initState();

    background = Generator.getRandomFrom(AppCache.backgroundList);
    durationStreamCtr = StreamController<PlaybackDisposition>.broadcast();
    _initAudio();
  }

  @override
  void dispose() {
    if(seeToEndTimer != null && seeToEndTimer!.isActive) {
      seeToEndTimer!.cancel();
    }

    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data) {
        return Scaffold(
          backgroundColor: widget.injectData.backColor?? Colors.white,
          appBar: AppBarCustom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image(image: background, fit: BoxFit.fill),

              Positioned(
                  top: MathHelper.percent(AppSizes.instance.appHeight, 25),
                  left: MathHelper.percent(AppSizes.instance.appWidth, 10),
                  right: MathHelper.percent(AppSizes.instance.appWidth, 10),
                  child: Column(
                    children: [
                      Text(widget.injectData.title?? '').bold().fsR(5).color(Colors.white),

                      const SizedBox(height: 5),
                      Text(widget.injectData.subTitle?? '').bold().fsR(4).color(Colors.white).thinFont(),

                      const SizedBox(height: 20),
                      Directionality(
                        textDirection: TextDirection.ltr,
                          child: PlayBarSlider(durationStreamCtr.stream, (pos){
                            currentTime = pos;

                            durationStreamCtr.add(
                                PlaybackDisposition(PlaybackDispositionState.loaded, duration: totalTime, position: pos)
                            );

                            audioPlayer.seek(pos);
                          })
                      ),

                      const SizedBox(height: 10),
                      Row(
                        textDirection: TextDirection.ltr,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LocaleHelper.overrideLtr(DurationFormatter.duration(currentTime, showSuffix: false))).color(Colors.white),
                          Text(DurationFormatter.duration(totalTime, showSuffix: false)).color(Colors.white),
                        ],
                      ),

                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: playPauseButton,
                        child: CircleContainer(
                          backColor: Colors.white.withAlpha(50),
                            size: 50* hRel,
                            border: Border.all(style: BorderStyle.none, width: 0),
                            child: Icon(isPlaying() ? AppIcons.pause : AppIcons.playArrow,
                              color: Colors.white,
                              size: 40 * hRel,
                            ),
                        ),
                      ),
                    ],
                  )
              ),
            ]
          ),
        );
      }
    );
  }

  void playPauseButton(){
    if(isAudioInit){
      if(isPlaying()){
        audioPlayer.pause();
      }
      else {
        audioPlayer.resume();
      }
    }
  }

  void _initAudio(){
    Future? fu;

    audioPlayer.onDurationChanged.listen(durationListener);
    audioPlayer.onPositionChanged.listen(positionListener);
    audioPlayer.onPlayerStateChanged.listen(stateListener);
    audioPlayer.eventStream.listen(eventListener);

    switch(widget.injectData.audioSourceType){
      case AudioSourceType.file:
        fu = audioPlayer.setSourceDeviceFile(widget.injectData.srcAddress);
        break;
      case AudioSourceType.network:
        fu = audioPlayer.setSourceUrl(widget.injectData.srcAddress);
        break;
      case AudioSourceType.bytes:
        fu = audioPlayer.setSourceBytes(widget.injectData.bytes!);
        break;
      case AudioSourceType.asset:
        fu = audioPlayer.setSourceAsset(widget.injectData.srcAddress);
        break;
    }

    fu.then((s) {
      isAudioInit = true;

      audioPlayer.resume();
    });

    /*
    final headers = <String, String>{};

    headers['user'] = '${SessionService.getLastLoginUser()?.userId}';
    headers['token'] = '${SessionService.getLastLoginUser()?.token?.token}';
     */
  }

  void eventListener(AudioEvent event){
    if(event.eventType == AudioEventType.duration){
      totalTime = event.duration!;

      startTimerForSeeFull();
    }

    assistCtr.updateHead();
  }

  void stateListener(PlayerState event){
    /*if(event == PlayerState.playing){
      startTimerForSeeFull();
    }*/

    assistCtr.updateHead();
  }

  bool isPlaying(){
    return audioPlayer.state == PlayerState.playing;
  }

  void durationListener(Duration total) {
    totalTime = total;
    assistCtr.updateHead();
  }

  void positionListener(Duration dur) {
    currentTime = dur;
    assistCtr.updateHead();

    durationStreamCtr.add(
        PlaybackDisposition(
          PlaybackDispositionState.playing,
          position: dur,
          duration: totalTime,
        )
    );
  }

  void startTimerForSeeFull(){
    if((seeToEndTimer == null || !seeToEndTimer!.isActive) && totalTime.inMilliseconds > 10) {
      var per = 20 * totalTime.inMilliseconds / 100;
      widget.injectData.onFullTimePlay?.call(); //hack

      seeToEndTimer = Timer(Duration(milliseconds: per.toInt()), () { //totalTime - Duration(seconds: 4)
        widget.injectData.onFullTimePlay?.call();
      });
    }
  }
}
