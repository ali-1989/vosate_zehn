import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/services/favoriteService.dart';
import 'package:app/services/lastSeenService.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/bucketModel.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/baseComponents/appBarBuilder.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SubBucketPageInjectData {
  BucketModel? bucketModel;
}
///---------------------------------------------------------------------------------
class SubBucketPage extends StatefulWidget{

  final SubBucketPageInjectData injectData;

  SubBucketPage({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<SubBucketPage> createState() => _SubBucketPageState();
}
///==================================================================================
class _SubBucketPageState extends StateBase<SubBucketPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<SubBucketModel> listItems = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);
  SearchFilterTool searchFilter = SearchFilterTool();


  @override
  void initState(){
    super.initState();

    searchFilter.limit = 20;
    searchFilter.ascOrder = true;
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
              title: Text(widget.injectData.bucketModel?.title?? ''),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return WaitToLoad();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return ErrorOccur(onTryAgain: tryLoadClick,);
    }

    if(listItems.isEmpty){
      return EmptyData();
    }

    return RefreshConfiguration(
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder:  () => AppTools.classicFooter,
      //headerTriggerDistance: 80.0,
      //maxOverScrollExtent :100,
      //maxUnderScrollExtent:0,
      //springDescription: SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed : true,
      hideFooterWhenNotFull: true,
      enableBallisticLoad: true,
      enableLoadingWhenNoData: false,
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: true,
        controller: refreshController,
        onRefresh: (){},
        onLoading: onLoadingMoreCall,
        child: GridView.builder(
            itemCount: listItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
            itemBuilder: (ctx, idx){
              return buildListItem(idx);
            },
        ),
      ),
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(10),
          ),

          child: Padding(
            padding: const EdgeInsets.all(1.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
                              fit: BoxFit.fill,
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
                                  return Theme(
                                    data: AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent),
                                    child: Chip(
                                      backgroundColor: Colors.grey.withAlpha(160),
                                      shadowColor: Colors.transparent,
                                      visualDensity: VisualDensity.compact,
                                      elevation: 0,
                                      label: Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                    ),
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

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateHead();

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

    assistCtr.updateHead();
  }

  void onItemClick(SubBucketModel itm) {
    LastSeenService.addItem(itm);

    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = widget.injectData.bucketModel?.title;
      inject.subTitle = itm.title;

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      final inject = ContentViewPageInjectData();
      inject.subBucket = itm;

      RouteTools.pushPage(context, ContentViewPage(injectData: inject));
      return;
    }
  }

  void requestData() async {
    final ul = AppTools.findUpperLower(listItems, searchFilter.ascOrder);
    searchFilter.upper = ul.upperAsTS;
    searchFilter.lower = ul.lowerAsTS;

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_sub_bucket_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.bucketModel!.id?? 1;
    js[Keys.searchFilter] = searchFilter.toMap();

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List bList = data['sub_bucket_list']?? [];
      final List mList = data['media_list']?? [];

      searchFilter.ascOrder = data[Keys.isAsc]?? true;

      if(bList.length < searchFilter.limit){
        refreshController.loadNoData();
      }
      else {
        if(refreshController.isLoading) {
          refreshController.loadComplete();
        }
      }

      MediaManager.addItemsFromMap(mList);
      MediaManager.sinkItems(MediaManager.mediaList);

      for(final m in bList){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);

        listItems.add(itm);
      }

      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context, false);
  }
}
