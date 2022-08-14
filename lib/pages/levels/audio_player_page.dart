import 'dart:io';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';


enum AudioSourceType {
  file,
  network,
  bytes,
  asset
}

class AudioPlayerPageInjectData {
  late AudioSourceType audioSourceType;
  late String srcAddress;
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
  bool isVideoInit = false;

  @override
  void initState() {
    super.initState();

    _initVideo();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
      controller: assistCtr,
      builder: (ctx, ctr, data) {
        return Scaffold(
          backgroundColor: widget.injectData.backColor?? Colors.black,
          appBar: AppBarCustom(),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(AppImages.background, fit: BoxFit.fill),

              Positioned(
                  top: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text('lrnlhj'),
                      Text('lrnlhj'),

                      SizedBox(height: 20,),

                      Slider(value: 10, onChanged: (v){}),

                      SizedBox(height: 20,),

                      Icon(AppIcons.playArrow),
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

  void _initVideo(){
    /*switch(widget.injectData.audioSourceType){
      case AudioSourceType.file:
        playerController = VideoPlayerController.file(File(widget.injectData.srcAddress));
        break;
      case AudioSourceType.network:
        playerController = VideoPlayerController.network(widget.injectData.srcAddress);
        break;
      case AudioSourceType.bytes:
        break;
      case AudioSourceType.asset:
        playerController = VideoPlayerController.asset(widget.injectData.srcAddress);
        break;
    }

    playerController!.initialize().then((value) {
      isVideoInit = playerController!.value.isInitialized;
      _onVideoInit();
    });*/
  }

}
