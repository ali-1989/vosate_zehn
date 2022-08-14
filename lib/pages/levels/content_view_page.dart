import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/avatarChip.dart';

import 'package:vosate_zehn/models/enums.dart';
import 'package:vosate_zehn/models/level2ContentModel.dart';
import 'package:vosate_zehn/models/level2Model.dart';
import 'package:vosate_zehn/pages/levels/audio_player_page.dart';
import 'package:vosate_zehn/pages/levels/video_player_page.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class ContentViewPageInjectData {
  late Level2Model level2model;
}
///---------------------------------------------------------------------------------
class ContentViewPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/content_view',
    name: (ContentViewPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ContentViewPage(injectData: state.extra as ContentViewPageInjectData),
  );

  final ContentViewPageInjectData injectData;

  ContentViewPage({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<ContentViewPage> createState() => _LevelPageState();
}
///=================================================================================================
class _LevelPageState extends StateBase<ContentViewPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  Level2ContentModel? contentModel;

  @override
  void initState(){
    super.initState();

    requestData();
  }

  @override
  void dispose(){
    requester.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(widget.injectData.level2model.title?? ''),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        SizedBox(height: 20,),

        Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
              child: Image.network(widget.injectData.level2model.imageModel?.url?? '', height: 160,)
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(widget.injectData.level2model.description?? '').bold().fsR(1),
        ),

        SizedBox(height: 20,),

        Expanded(
            child: Builder(
              builder: (ctx){
                if(isInFetchData) {
                  return WaitToLoad();
                }

                if(!assistCtr.hasState(state$fetchData)){
                  return NotFetchData(tryClick: tryLoadClick,);
                }

                return Column(
                  children: [
                    AvatarChip(
                        label: Text(contentModel!.speakerModel.name?? ''),

                      avatar: contentModel!.speakerModel.imageModel != null?
                      ClipOval(
                          child: Image.network(contentModel!.speakerModel.imageModel!.url!,
                            width: 60, height: 60, fit: BoxFit.fill,)
                      )
                      : null,
                    ),

                    SizedBox(height: 20,),

                    Expanded(
                      child: Wrap(
                        textDirection: TextDirection.ltr,
                        spacing: 8,
                        runSpacing: 4,
                        children: buildWrapItems(),
                      ),
                    ),
                  ],
                );
              },
            ),
        ),
      ],
    );
  }

  List<Widget> buildWrapItems(){
    final List<Widget> res = [];

    for(final i in contentModel!.mediaList){
      final w = ActionChip(
        label: Text(i.name?? '-'),
        onPressed: () {
          onItemClick(i);
        },
      );

      res.add(w);
    }

    return res;
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateMain();

    requestData();
  }

  void onItemClick(MediaModel media) {
    Level2Types? type;

    if(contentModel!.type != null){
      if(contentModel!.type == Level2Types.video.type()){
        type = Level2Types.video;
      }

      else if(contentModel!.type == Level2Types.audio.type()){
        type = Level2Types.audio;
      }
    }
    else {
      if(media.extension == 'mp4'){
        type = Level2Types.video;
      }
      else if(media.extension == 'mp3'){
        type = Level2Types.audio;
      }
    }


    if(type == Level2Types.video){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
    }
    else if(type == Level2Types.audio){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = media.name;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
    }
  }

  void requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_level2_content_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.level2model.id;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final content = data[Keys.data];
      contentModel = Level2ContentModel.fromMap(content);

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

}
