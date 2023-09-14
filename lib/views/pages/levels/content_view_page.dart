import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/avatarChip.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:iris_tools/widgets/sizePosition/size_inInfinity.dart';

import 'package:app/managers/media_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/assist_groups.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/contentModel.dart';
import 'package:app/structures/models/mediaModelWrapForContent.dart';
import 'package:app/structures/models/speakerModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/levels/audio_player_page.dart';
import 'package:app/views/pages/levels/video_player_page.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class ContentViewPageInjectData {
  late SubBucketModel subBucket;
}
///---------------------------------------------------------------------------------
class ContentViewPage extends StatefulWidget{
  final ContentViewPageInjectData injectData;

  ContentViewPage({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<ContentViewPage> createState() => _LevelPageState();
}
///=================================================================================================
class _LevelPageState extends StateSuper<ContentViewPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  ContentModel? contentModel;
  List<MediaModelWrapForContent> mediaList = [];
  late ThemeData chipTheme;

  @override
  void initState(){
    super.initState();

    chipTheme = AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent);
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
        groupIds: [AppAssistKeys.updateAudioSeen],
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Builder(
                builder: (ctx){
                  if(widget.injectData.subBucket.imageModel?.url != null){
                    return IrisImageView(
                      width: double.infinity,
                      height: 160,
                      //beforeLoadWidget: SizedBox(height: 160),
                      fit: BoxFit.fill,
                      url: widget.injectData.subBucket.imageModel!.url!,
                      imagePath: AppDirectories.getSavePathMedia(widget.injectData.subBucket.imageModel, SavePathType.anyOnInternal, null),
                    );
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

          SizedBox(height: 40),

           Builder(
              builder: (ctx){
                if(isInFetchData) {
                  return SizeInInfinity(
                      builder: (BuildContext context, double? top, double? realHeight, double? height) {

                        if(height == null){
                          return SizedBox();
                        }

                        return SizedBox(
                            height: height,
                            child: WaitToLoad()
                        );
                    }
                  );
                }

                if(!assistCtr.hasState(state$fetchData)){
                  return SizeInInfinity(
                      builder: (BuildContext context, double? top, double? realHeight, double? height) {

                        if(height == null){
                          return SizedBox();
                        }

                        return SizedBox(
                            height: height,
                            child: ErrorOccur(onTryAgain: tryLoadClick)
                        );
                      }
                  );
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
                              child: IrisImageView(
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                url: contentModel!.speakerModel!.profileModel!.url!,
                                imagePath: AppDirectories.getSavePathMedia(contentModel!.speakerModel!.profileModel, SavePathType.anyOnInternal, null),
                              )
                          )
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          textDirection: TextDirection.rtl,
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          spacing: 8,
                          runSpacing: 4,
                          children: buildWrapItems(),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
        ],
      ),
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
        child: Theme(
          data: chipTheme,
          child: Chip(
            backgroundColor: itm.isSee?
            AppThemes.instance.currentTheme.successColor
                : AppThemes.instance.currentTheme.successColor.withAlpha(130),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            label: SizedBox(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: contentModel!.hasOrder || itm.title == null,
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 20),
                          child: Center(
                              child: Text('$i').color(Colors.white)
                          )
                      ),
                    ),

                    Builder(
                      builder: (ctx){
                        if(itm.title == null){
                          return SizedBox();
                        }

                        return Row(
                          children: [
                            //SizedBox(width: 8),

                            SizedBox(
                              width: 2, height: 16,
                              child: ColoredBox(
                                  color: Colors.white
                              ),
                            ),

                            SizedBox(width: 8),
                            Text('${itm.title}').color(Colors.white),
                          ],
                        );
                      },
                    ),
                  ],
                )
            ),
          ),
        ),
      );

      res.add(w);
    }

    return res;
  }

  List<Widget> buildWrapItemsOld(){
    final List<Widget> res = [];

    for(var i = 1; i <= mediaList.length; i++){
      final itm = mediaList[i-1];

      final w = GestureDetector(
        onTap: (){
          onItemClick(itm);
        },
        child: ClipOval(
          child: ColoredBox(
            color: itm.isSee?
            AppThemes.instance.currentTheme.successColor
                : AppThemes.instance.currentTheme.successColor.withAlpha(160),
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
    assistCtr.updateHead();

    requestData();
  }

  void onItemClick(MediaModelWrapForContent media) {
    if(!media.isSee && contentModel!.hasOrder){
      //final contentModel = widget.injectData.subBucket.contentModel;
      final curIdx = contentModel!.mediaIds.indexWhere((element) => element == media.id);

      if(curIdx > 0){
        final preModelId = contentModel!.mediaIds.elementAt(curIdx-1);
        final preModel = mediaList.firstWhere((itm) => itm.id == preModelId);

        if(!preModel.isSee){
          AppToast.showToast(context, AppMessages.pleaseKeepOrder);
          return;
        }
      }
    }

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
      inject.onFullTimePlay = (){onFullTimePlay(media);};

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject));
    }
    else if(type == SubBucketTypes.audio){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = media.title;
      inject.onFullTimePlay = (){onFullTimePlay(media);};

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject));
    }
  }

  void onFullTimePlay(MediaModelWrapForContent media) {
    if(!mounted){
      return;
    }

    requestRegisterSeenContent(media);
    //AppToast.showToast(context, 'جلسه بعدی باز شد');
  }

  MediaModelWrapForContent getNextMedia(MediaModelWrapForContent current){
    int idx = mediaList.indexWhere((element) => element.id == current.id);

    try{
      return mediaList[idx+1];
    }
    catch (e){
      return mediaList[0];
    }
  }

  void requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_content_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.subBucket.id;

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final content = data['content'];
      final List mList = data['media_list']?? [];
      final List seenList = data['seen_list']?? [];
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

          if(seenList.contains(mw.id)){
            mw.isSee = true;
          }

          mediaList.add(mw);
        }
      }

      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

  void requestRegisterSeenContent(MediaModelWrapForContent media) async {
    if(!AppCache.canCallMethodAgain('requestRegisterSeenContent')){
      return;
    }

    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      media.isSee = true;
      AssistController.updateGroupGlobal(AppAssistKeys.updateAudioSeen);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'set_content_seen';
    js[Keys.requesterId] = user.userId;
    js[Keys.id] = widget.injectData.subBucket.id;
    js['content_id'] = contentModel!.id;
    js['media_id'] = media.id;

    requester.httpRequestEvents.onFailState = (req, data) async {
      if(kIsWeb){
        media.isSee = true;
        AssistController.updateGroupGlobal(AppAssistKeys.updateAudioSeen);
      }

      AppToast.showToast(context, 'خطا در باز کردن جلسه');
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      media.isSee = true;
      AssistController.updateGroupGlobal(AppAssistKeys.updateAudioSeen);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context, false);
  }
}
