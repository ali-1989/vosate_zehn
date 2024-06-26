import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/avatarChip.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:iris_tools/widgets/sizePosition/size_inInfinity.dart';

import 'package:app/managers/media_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/services/vip_service.dart';
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
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/levels/audio_player_page.dart';
import 'package:app/views/pages/levels/video_player_page.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

// old name: ContentViewPage
class MultiItemPage extends StatefulWidget{
  final SubBucketModel subBucket;

  const MultiItemPage({
    required this.subBucket,
    super.key,
  });

  @override
  State<MultiItemPage> createState() => _LevelPageState();
}
///=============================================================================
class _LevelPageState extends StateSuper<MultiItemPage> {
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
        groupIds: const [AssistGroup.updateAudioSeen],
        builder: (context, ctr, data) {
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(widget.subBucket.title),
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
          const SizedBox(height: 20),

          /// image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Builder(
                builder: (ctx){
                  if(widget.subBucket.imageModel?.url != null){
                    return IrisImageView(
                      width: double.infinity,
                      height: 160,
                      //beforeLoadWidget: SizedBox(height: 160),
                      fit: BoxFit.fill,
                      url: widget.subBucket.imageModel!.url!,
                      imagePath: AppDirectories.getSavePathMedia(widget.subBucket.imageModel, SavePathType.anyOnInternal, null),
                    );
                  }

                  return Image.asset(AppImages.appIcon, width: double.infinity, height: 100, fit: BoxFit.contain);
                },
              ),
            ),
          ),

          /// description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(widget.subBucket.description?? '',
              textAlign: TextAlign.justify,
            ).bold().fsR(2),
          ),

          /// content (speaker and voices)
          const SizedBox(height: 40),
           Builder(
              builder: (ctx){
                if(isInFetchData) {
                  return SizeInInfinity(
                      builder: (BuildContext context, double? top, double? realHeight, double? height) {

                        if(height == null){
                          return const SizedBox();
                        }

                        return SizedBox(
                            height: height,
                            child: const WaitToLoad()
                        );
                    }
                  );
                }

                if(!assistCtr.hasState(state$fetchData)){
                  return SizeInInfinity(
                      builder: (BuildContext context, double? top, double? realHeight, double? height) {
                        if(height == null){
                          return const SizedBox();
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
                    /// speaker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            if(contentModel!.speakerModel != null){
                              return Align(
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
                              );
                            }

                            return const SizedBox(height: 20);
                          }
                        ),

                        Builder(
                            builder: (_){
                              if(widget.subBucket.isVip){
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                  child: ElevatedButton.icon(
                                      onPressed: onBuyClick,
                                      label: Text('خرید'),
                                      icon: const Icon(AppIcons.buyBasket, size: 20)
                                  ),
                                );
                              }

                              return const SizedBox();
                            }
                        )
                      ],
                    ),


                    /// voices
                    const SizedBox(height: 16),
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
                        constraints: const BoxConstraints.tightFor(width: 20),
                          child: Center(
                              child: Text('$i').color(Colors.white)
                          )
                      ),
                    ),

                    Builder(
                      builder: (ctx){
                        if(itm.title == null){
                          return const SizedBox();
                        }

                        return Row(
                          children: [
                            //SizedBox(width: 8),

                            const SizedBox(
                              width: 2, height: 16,
                              child: ColoredBox(
                                  color: Colors.white
                              ),
                            ),

                            const SizedBox(width: 8),
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
    final curIdx = contentModel!.mediaIds.indexWhere((element) => element == media.id);

    if(!media.isSee && contentModel!.hasOrder){
      //final contentModel = widget.injectData.subBucket.contentModel;
      if(curIdx > 0){
        final preModelId = contentModel!.mediaIds.elementAt(curIdx-1);
        final preModel = mediaList.firstWhere((itm) => itm.id == preModelId);

        if(!preModel.isSee){
          AppToast.showToast(context, AppMessages.pleaseKeepOrder);
          return;
        }
      }
    }

    if(curIdx > 0 && widget.subBucket.isVip){
      final canContinue = VipService.checkVipForMultiItemPage(context, media);

      if(!canContinue){
        return;
      }
    }

    SubBucketTypes? type;

    if(widget.subBucket.contentType > 0){
      if(widget.subBucket.contentType == SubBucketTypes.video.id()){
        type = SubBucketTypes.video;
      }

      else if(widget.subBucket.contentType == SubBucketTypes.audio.id()){
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

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject), name: 'VideoPlayer-Page'.toLowerCase());
    }
    else if(type == SubBucketTypes.audio){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = media.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = media.title;
      inject.onFullTimePlay = (){onFullTimePlay(media);};

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject), name: 'AudioPlayer-Page'.toLowerCase());
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
    js[Keys.request] = 'get_bucket_content_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.id] = widget.subBucket.id;

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
    requester.request();
  }

  void requestRegisterSeenContent(MediaModelWrapForContent media) async {
    if(!AppCache.canCallMethodAgain('requestRegisterSeenContent')){
      return;
    }

    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      media.isSee = true;
      AssistController.updateGroupGlobal(AssistGroup.updateAudioSeen);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'set_content_seen';
    js[Keys.requesterId] = user.userId;
    js[Keys.id] = widget.subBucket.id;
    js['content_id'] = contentModel!.id;
    js['media_id'] = media.id;

    requester.httpRequestEvents.onFailState = (req, data) async {
      if(kIsWeb){
        media.isSee = true;
        AssistController.updateGroupGlobal(AssistGroup.updateAudioSeen);
      }

      AppToast.showToast(context, 'خطا در باز کردن جلسه');
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      media.isSee = true;
      AssistController.updateGroupGlobal(AssistGroup.updateAudioSeen);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();
  }

  void onBuyClick() {
    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      AppSnack.showError(context, 'ابتدا باید ثبت نام کنید.');
      return;
    }

    if(user.vipOptions.isVip()){
      AppToast.showToast(context, 'شما در حال حاضر کاربر ویژه هستید و دسترسی کامل به محتوا دارید.');
      return;
    }

    VipService.gotoBuyVipPage(context);
  }
}
