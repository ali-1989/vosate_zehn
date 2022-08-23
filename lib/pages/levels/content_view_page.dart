import 'package:app/managers/mediaManager.dart';
import 'package:app/models/contentModel.dart';
import 'package:app/models/enums.dart';
import 'package:app/models/mediaModelWrapForContent.dart';
import 'package:app/models/speakerModel.dart';
import 'package:app/models/subBuketModel.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/avatarChip.dart';

import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/waitToLoad.dart';

class ContentViewPageInjectData {
  late SubBucketModel subBucket;
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
  ContentModel? contentModel;
  List<MediaModelWrapForContent> mediaList = [];

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
              title: Text(widget.injectData.subBucket.title),
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
              child: Builder(
                builder: (ctx){
                  if(widget.injectData.subBucket.imageModel?.url != null){
                    return Image.network(widget.injectData.subBucket.imageModel!.url!, width: double.infinity, height: 160, fit: BoxFit.contain);
                  }

                  return Image.asset(AppImages.appIcon, width: double.infinity, height: 100, fit: BoxFit.contain);
                },
              ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Text(widget.injectData.subBucket.description?? '').bold().fsR(2),
        ),

        SizedBox(height: 50),

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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AvatarChip(
                            label: Text(contentModel!.speakerModel?.name?? ''),
                          avatar: contentModel!.speakerModel?.profileModel != null?
                          ClipOval(
                              child: Image.network(contentModel!.speakerModel!.profileModel!.url!,
                                width: 60, height: 60, fit: BoxFit.fill,)
                          )
                          : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Wrap(
                          textDirection: TextDirection.ltr,
                          spacing: 8,
                          runSpacing: 4,
                          children: buildWrapItems(),
                        ),
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

    for(var i = 1; i <= mediaList.length; i++){
      final itm = mediaList[i-1];

      final w = GestureDetector(
        onTap: (){
          onItemClick(itm);
        },
        child: ClipOval(
          child: ColoredBox(
            color: AppThemes.instance.currentTheme.successColor,
            child: SizedBox(width: 50, height: 50,
                child: Center(
                    child: Text('$i').color(Colors.white)
                )
            ),
          ),
        ),
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

  void onItemClick(MediaModelWrapForContent media) {
    SubBucketTypes? type;

    if(widget.injectData.subBucket.contentType > 0){
      if(widget.injectData.subBucket.contentType == SubBucketTypes.video.id()){
        type = SubBucketTypes.video;
      }

      else if(widget.injectData.subBucket.contentType == SubBucketTypes.audio.id()){
        type = SubBucketTypes.audio;
      }
    }
    else {
      if(media.extension?.contains('mp4')?? false){
        type = SubBucketTypes.video;
      }
      else if(media.extension?.contains('mp3')?? false){
        type = SubBucketTypes.audio;
      }
    }


    if(type == SubBucketTypes.video){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
    }
    else if(type == SubBucketTypes.audio){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = media.title;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
    }
  }

  void requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_content_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.subBucket.id;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final content = data['content'];
      final List mList = data['media_list']?? [];
      final speaker = data['speaker'];

      MediaManager.addItemsFromMap(mList);

      contentModel = ContentModel.fromMap(content);

      if(speaker != null){
        contentModel?.speakerModel = SpeakerModel.fromMap(speaker);
        contentModel?.speakerModel?.profileModel = MediaManager.getById(contentModel?.speakerModel?.mediaId);
      }

      for(final id in contentModel!.mediaIds){
        final m = MediaManager.getById(id);

        if(m!= null) {
          final mw = MediaModelWrapForContent.fromMap(m.toMap());
          mediaList.add(mw);
        }
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

}
