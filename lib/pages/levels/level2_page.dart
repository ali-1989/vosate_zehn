import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vosate_zehn/models/enums.dart';
import 'package:vosate_zehn/models/level1Model.dart';
import 'package:vosate_zehn/models/level2Model.dart';
import 'package:vosate_zehn/pages/levels/audio_player_page.dart';
import 'package:vosate_zehn/pages/levels/content_view_page.dart';
import 'package:vosate_zehn/pages/levels/video_player_page.dart';
import 'package:vosate_zehn/services/favoriteService.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appToast.dart';
import 'package:vosate_zehn/tools/publicAccess.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class Level2PageInjectData {
  Level1Model? level1model;
}
///---------------------------------------------------------------------------------
class Level2Page extends StatefulWidget {
  static final route = GoRoute(
    path: '/Level2',
    name: (Level2Page).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => Level2Page(injectData: state.extra as Level2PageInjectData),
  );

  final Level2PageInjectData injectData;

  Level2Page({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<Level2Page> createState() => _Level2PageState();
}
///==================================================================================
class _Level2PageState extends StateBase<Level2Page> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<Level2Model> listItems = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);
  bool isAscOrder = true;
  int fetchCount = 20;

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
              title: Text(widget.injectData.level1model?.title?? ''),
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
      return NotFetchData(tryClick: tryLoadClick,);
    }

    return RefreshConfiguration(
      headerBuilder: () => MaterialClassicHeader(),
      footerBuilder:  () => PublicAccess.classicFooter,
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

    return InkWell(
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
                    Image.network(itm.imageModel?.url?? '', height: 100, width: double.infinity, fit: BoxFit.fill),

                    Positioned(
                      top: 0,
                        left: 0,
                        child: Builder(
                            builder: (context) {
                              if(itm.type == Level2Types.video.type()){
                                return Chip(//todo: chip transparent
                                  backgroundColor: Colors.black.withAlpha(200),
                                  shadowColor: Colors.transparent,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                  label: Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                );
                              }

                              if(itm.type == Level2Types.audio.type()){
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

                Text('${itm.title}', maxLines: 1).bold().fsR(1),

                SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.duration != null && itm.duration! > 0){
                            final dur = Duration(milliseconds: itm.duration!);
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
    );
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateMain();

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void setFavorite(Level2Model itm) async {
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

  void onItemClick(Level2Model itm) {
    if(itm.type == Level2Types.video.type()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == Level2Types.audio.type()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = widget.injectData.level1model?.title;
      inject.subTitle = itm.title;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == Level2Types.list.type()){
      final inject = ContentViewPageInjectData();
      inject.level2model = itm;

      AppRoute.pushNamed(context, ContentViewPage.route.name!, extra: inject);
      return;
    }
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(listItems, isAscOrder);

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_level2_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = widget.injectData.level1model!.id?? 1;
    js[Keys.count] = fetchCount;

    if(ul.isNotEmpty) {
      js[Keys.lower] = DateHelper.toTimestamp(ul.elementAt(0));
    }

    if(ul.length > 1) {
      js[Keys.upper] = DateHelper.toTimestamp(ul.elementAt(1));
    }

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List list = data[Keys.dataList]?? [];
      isAscOrder = data[Keys.isAsc]?? true;

      if(list.length < fetchCount){
        refreshController.loadNoData();
      }
      else {
        if(refreshController.isLoading) {
          refreshController.loadComplete();
        }
      }

      for(final m in list){
        final itm = Level2Model.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);

        listItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
