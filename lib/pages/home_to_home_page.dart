import 'package:app/managers/advertisingManager.dart';
import 'package:app/managers/mediaManager.dart';
import 'package:app/models/subBuketModel.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/services/favoriteService.dart';
import 'package:app/services/lastSeenService.dart';
import 'package:app/system/enums.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/progressView.dart';

class HomeToHomePage extends StatefulWidget {

  HomeToHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeToHomePage> createState() => _HomeToHomePageState();
}
///==================================================================================
class _HomeToHomePageState extends StateBase<HomeToHomePage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<SubBucketModel> newItems = [];
  List<SubBucketModel> meditationItems = [];
  List<SubBucketModel> videoItems = [];
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 20;
    searchFilter.ascOrder = true;
    AppBroadcast.newAdvNotifier.addListener(onNewAdv);
    requestData();
  }

  @override
  void dispose(){
    requester.dispose();
    AppBroadcast.newAdvNotifier.removeListener(onNewAdv);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return ProgressView();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return NotFetchData(tryClick: tryLoadClick,);
    }

    if(newItems.isEmpty || meditationItems.isEmpty){
      return EmptyData();
    }

    return ListView(
     children: [
        buildAdv1(),
        buildNews(),
        buildAdv2(),
       buildMeditation(),
       buildVideo(),
        buildAdv3(),
     ],
    );
  }

  Widget buildAdv1(){
    return Builder(
      builder: (ctx){
        final adv = AdvertisingManager.getAdv1();

        if(adv == null || adv.mediaModel == null){
          return SizedBox();
        }

        return IrisImageView(
          height: 170,
          url: adv.mediaModel!.url,
          imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
        );
      },
    );
  }

  Widget buildAdv2(){
    return Builder(
      builder: (ctx){
        final adv = AdvertisingManager.getAdv2();

        if(adv == null || adv.mediaModel == null){
          return SizedBox();
        }
        return IrisImageView(
          height: 170,
          url: adv.mediaModel!.url,
          imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
        );
      },
    );
  }

  Widget buildAdv3(){
    return Builder(
      builder: (ctx){
        final adv = AdvertisingManager.getAdv3();

        if(adv == null || adv.mediaModel == null){
          return SizedBox();
        }
        return IrisImageView(
          height: 170,
          url: adv.mediaModel!.url,
          imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
        );
      },
    );
  }

  Widget buildNews(){
    return Builder(
      builder: (ctx){
        if(newItems.isEmpty){
          return SizedBox();
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Text('جدیدترین ها').bold(),
                ),
              ],
            ),

            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                  itemCount: newItems.length,
                  itemBuilder: (ctx, idx){
                    final itm = newItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildMeditation(){
    return Builder(
      builder: (ctx){
        if(meditationItems.isEmpty){
          return SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Text('مدیتیشن').bold(),
                ),
                TextButton(
                  onPressed: (){},
                  child: Text('بیشتر'),
                ),
              ],
            ),

            SizedBox(
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: meditationItems.length,
                  itemBuilder: (ctx, idx){
                    final itm = meditationItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildVideo(){
    return Builder(
      builder: (ctx){
        if(videoItems.isEmpty){
          return SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Text('ویدئو').bold(),
                ),
                TextButton(
                  onPressed: (){},
                  child: Text('بیشتر'),
                ),
              ],
            ),

            SizedBox(
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videoItems.length,
                  itemBuilder: (ctx, idx){
                    final itm = videoItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildListItem(SubBucketModel itm){
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                children: [
                  Stack(
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.imageModel?.url != null){
                            return IrisImageView(
                              width: double.infinity,
                              height: 100,
                              fit: BoxFit.contain,
                              url: itm.imageModel!.url!,
                              imagePath: AppDirectories.getSavePathMedia(itm.imageModel, SavePathType.anyOnInternal, null),
                            );
                          }

                          return Image.asset(AppImages.appIcon, width: double.infinity, height: 100, fit: BoxFit.contain);
                        },
                      ),

                      Positioned(
                          top: 0,
                          left: 0,
                          child: Builder(
                              builder: (context) {
                                if(itm.type == SubBucketTypes.video.id()){
                                  return Chip(//todo: chip transparent
                                    backgroundColor: Colors.black.withAlpha(200),
                                    shadowColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                    elevation: 0,
                                    label: Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                  );
                                }

                                if(itm.type == SubBucketTypes.audio.id()){
                                  return Chip(
                                    backgroundColor: Colors.black.withAlpha(200),
                                    shadowColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                    elevation: 0,
                                    label: Icon(AppIcons.headset, size: 15, color: Colors.white),
                                  );
                                }

                                return SizedBox();
                              }
                          )
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  Text(itm.title, maxLines: 1).bold().fsR(1),

                  SizedBox(height: 12,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (ctx){
                            if(itm.duration > 0){
                              final dur = Duration(milliseconds: itm.duration);
                              return Text('${DurationFormatter.duration(dur, showSuffix: false)} ثانیه').alpha().subFont();
                            }

                            return SizedBox();
                          },
                        ),

                        IconButton(
                            constraints: BoxConstraints.tightFor(),
                            padding: EdgeInsets.all(4),
                            splashRadius: 20,
                            visualDensity: VisualDensity.compact,
                            iconSize: 20,
                            onPressed: (){
                              setFavorite(itm);
                            },
                            icon: Icon(itm.isFavorite ? AppIcons.heartSolid: AppIcons.heart,
                              size: 20,
                              color: itm.isFavorite ? Colors.red: Colors.black,
                            )
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onNewAdv(){
    assistCtr.updateMain();
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateMain();

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void setFavorite(SubBucketModel itm) async {
    itm.isFavorite = !itm.isFavorite;
    bool res;

    if(itm.isFavorite){
      res = await FavoriteService.addFavorite(itm);
    }
    else {
      res = await FavoriteService.removeFavorite(itm.id!);
    }

    if(res){
      if(itm.isFavorite){
        AppToast.showToast(context, AppMessages.isAddToFavorite);
      }
    }
    else {
      AppToast.showToast(context, AppMessages.operationFailed);
    }

    assistCtr.updateMain();
  }

  void onItemClick(SubBucketModel itm) {
    LastSeenService.addItem(itm);

    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';
      inject.subTitle = itm.title;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      final inject = ContentViewPageInjectData();
      inject.subBucket = itm;

      AppRoute.pushNamed(context, ContentViewPage.route.name!, extra: inject);
      return;
    }
  }

  void requestData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_home_page_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List mediaList = data['media_list']?? [];
      final List list = data['new_list']?? [];
      final List mList = data['new_meditation_list']?? [];
      final List vList = data['new_video_list']?? [];

      MediaManager.addItemsFromMap(mediaList);
      for(final m in list){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);
        newItems.add(itm);
      }

      for(final m in mList){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);

        meditationItems.add(itm);
      }

      for(final m in vList){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);
        videoItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }
}
