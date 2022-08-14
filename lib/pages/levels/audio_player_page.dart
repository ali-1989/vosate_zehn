
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vosate_zehn/pages/levels/playback_disposition.dart';
import 'package:vosate_zehn/pages/levels/slider.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';

/// foi iOS: must visit page and add code to Info.plist

//todo: add assist for time display, and list of subscriptions

enum AudioSourceType {
  file,
  network,
  bytes,
  asset
}

class AudioPlayerPageInjectData {
  late AudioSourceType audioSourceType;
  late String srcAddress;
  String? pageTitle;
  String? title;
  String? subTitle;
  Color? backColor;
}
///---------------------------------------------------------------------------------
class AudioPlayerPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/audio_player',
    name: (AudioPlayerPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => AudioPlayerPage(injectData: state.extra as AudioPlayerPageInjectData),
  );

  final AudioPlayerPageInjectData injectData;

  AudioPlayerPage({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioPlayerPageState();
  }
}
///=========================================================================================
class AudioPlayerPageState extends StateBase<AudioPlayerPage> {
  bool isAudioInit = false;
  String background = '';
  AudioPlayer audioPlayer = AudioPlayer();
  List<String> backgrounds = [];
  Duration totalTime = Duration();
  Duration currentTime = Duration();
  late StreamController<PlaybackDisposition> durationStreamCtr;

  @override
  void initState() {
    super.initState();

    backgrounds.add(AppImages.back1);
    backgrounds.add(AppImages.back2);
    backgrounds.add(AppImages.back3);
    backgrounds.add(AppImages.back4);
    backgrounds.add(AppImages.back5);

    background = Generator.getRandomFrom(backgrounds);
    durationStreamCtr = StreamController<PlaybackDisposition>.broadcast();
    _initAudio();
  }

  @override
  void dispose() {
    audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data) {
        return Scaffold(
          backgroundColor: widget.injectData.backColor?? Colors.black,
          appBar: AppBarCustom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(background, fit: BoxFit.fill),

              Positioned(
                  top: MathHelper.percent(AppSizes.instance.appHeight, 25),
                  left: MathHelper.percent(AppSizes.instance.appWidth, 10),
                  right: MathHelper.percent(AppSizes.instance.appWidth, 10),
                  child: Column(
                    children: [
                      Text(widget.injectData.title?? '').bold().fsR(5).color(Colors.white),

                      SizedBox(height: 5,),
                      Text(widget.injectData.subTitle?? '').bold().fsR(4).color(Colors.white).subFont(),

                      SizedBox(height: 20,),
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

                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DurationFormatter.duration(totalTime, showSuffix: false)).color(Colors.white),
                          Text(DurationFormatter.duration(currentTime, showSuffix: false)).color(Colors.white),
                        ],
                      ),

                      SizedBox(height: 40,),

                      GestureDetector(
                        onTap: playPauseButton,
                        child: Material(
                          color: Colors.white.withAlpha(50),
                            type: MaterialType.circle,
                            child: Icon(
                              audioPlayer.playing?
                              AppIcons.pause : AppIcons.playArrow,
                              color: Colors.white,
                              size: 40,
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

  void update(){
    if(mounted){
      setState(() {});
    }
  }

  void playPauseButton(){
    if(isAudioInit){
      if(audioPlayer.playing){
        audioPlayer.pause();
      }
      else {
        audioPlayer.play();
      }
    }
  }

  void _initAudio(){
    Future? fu;

    audioPlayer.playbackEventStream.listen(eventListener, onError: errorListener);
    audioPlayer.playerStateStream.listen(stateListener, onError: errorListener);
    audioPlayer.positionStream.listen(positionListener, onError: errorListener);

    switch(widget.injectData.audioSourceType){
      case AudioSourceType.file:
        fu = audioPlayer.setFilePath(widget.injectData.srcAddress);
        break;
      case AudioSourceType.network:
        fu = audioPlayer.setUrl(widget.injectData.srcAddress);
        break;
      case AudioSourceType.bytes:
        break;
      case AudioSourceType.asset:
        fu = audioPlayer.setAsset(widget.injectData.srcAddress);
        break;
    }

    fu!.then((duration) {
      isAudioInit = true;

      audioPlayer.play();
    });
  }

  void eventListener(PlaybackEvent event){
    if(event.duration != null){
      totalTime = event.duration!;
    }

    assistCtr.updateMain();
  }

  void stateListener(PlayerState state){
    //if(state.playing){
  }

  void positionListener(Duration dur) {
    currentTime = dur;
    assistCtr.updateMain();

    if(audioPlayer.processingState == ProcessingState.ready){
      durationStreamCtr.add(
          PlaybackDisposition(
            PlaybackDispositionState.playing,
            position: dur,
            duration: audioPlayer.duration?? dur,
          )
      );
    }
  }

  void errorListener(Object e, StackTrace st){
    //rint('error: ${e.toString()}');
  }
}