import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/services/favoriteService.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/homeComponents/appBarBuilder.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SearchPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/search',
    name: (SearchPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => SearchPage(),
  );

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}
///====================================================================================================
class _SearchPageState extends StateBase<SearchPage> {
  List<SubBucketModel> searchList = [];
  late ThemeData chipTheme;
  Requester requester = Requester();
  bool isInFetchData = false;
  String state$noRequestYet = 'state_noRequestYet';
  String state$fetchData = 'state_fetchData';
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 20;
    searchFilter.ascOrder = true;
    chipTheme = AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent);
    assistCtr.addState(state$noRequestYet);
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
        builder: (ctx, ctr, data){
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(AppMessages.search),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: SearchBar(
            onChangeEvent: (txt){
              if(txt.length > 2 && searchFilter.searchText != txt){
                searchFilter.searchText = txt;
                resetSearch();
              }
            },
            searchEvent: (txt){
              if(txt.length > 2 && searchFilter.searchText != txt){
                searchFilter.searchText = txt;
                resetSearch();
              }
            },
            onClearEvent: (){
              searchList.clear();
              assistCtr.updateMain();
            },
          ),
        ),

        SizedBox(height: 30),
        Expanded(
            child: Builder(
              builder: (context) {
                if(isInFetchData) {
                  return WaitToLoad();
                }

                if(!assistCtr.hasState(state$fetchData) && !assistCtr.hasState(state$noRequestYet)){
                  return ErrorOccur(onRefresh: tryLoadClick);
                }

                if(searchList.isEmpty){
                  return EmptyData();
                }

                return RefreshConfiguration(
                  headerBuilder: () => MaterialClassicHeader(),
                  footerBuilder:  () => PublicAccess.classicFooter,
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
                    child: ListView.builder(
                      itemCount: searchList.length,
                        itemBuilder: (ctx, idx){
                          return buildListItem(idx);
                        }
                    ),
                  ),
                );
              }
            )
        ),
      ],
    );
  }

  Widget buildListItem(int idx){
    final itm = searchList[idx];

    return SizedBox(
      height: 120,
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.imageModel?.url != null){
                            return IrisImageView(
                              width: 120,
                              height: 120,
                              fit: BoxFit.fill,
                              url: itm.imageModel!.url!,
                              imagePath: AppDirectories.getSavePathMedia(itm.imageModel, SavePathType.anyOnInternal, null),
                            );
                          }

                          return Image.asset(AppImages.appIcon, width: 120, height: 120, fit: BoxFit.contain);
                        },
                      ),

                      Positioned(
                          top: 0,
                          right: 0,
                          child: Builder(
                              builder: (context) {
                                IconData? icon;

                                if(itm.type == SubBucketTypes.video.id()){
                                  icon = AppIcons.videoCamera;
                                }

                                if(itm.type == SubBucketTypes.audio.id()){
                                  icon = AppIcons.headset;
                                }

                                if(icon != null){
                                  return Theme(
                                    data: chipTheme,
                                    child: Chip(
                                      backgroundColor: Colors.grey.withAlpha(160),
                                      shadowColor: Colors.transparent,
                                      visualDensity: VisualDensity.compact,
                                      elevation: 0,
                                      label: Icon(icon, size: 15, color: Colors.white),
                                    ),
                                  );
                                }

                                return SizedBox();
                              }
                          )
                      ),
                    ],
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical:8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(itm.title, maxLines: 2).bold().fsR(1),

                          Row(
                            mainAxisSize: MainAxisSize.max,
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
                                    //setFavorite(itm);
                                  },
                                  icon: Icon(itm.isFavorite ? AppIcons.heartSolid: AppIcons.heart,
                                    size: 20,
                                    color: itm.isFavorite ? Colors.red: Colors.black,
                                  )
                              )
                            ],
                          )
                        ],
                      ),
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
    //isInFetchData = true;
    //assistCtr.updateMain();

    requestData();
  }

  void onItemClick(SubBucketModel itm) {
    FocusHelper.hideKeyboardByUnFocus(context);

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
      inject.title = '';//widget.injectData.level1model?.title;
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

  void onLoadingMoreCall(){
    requestData();
  }

  void resetSearch(){
    searchList.clear();
    refreshController.resetNoData();

    requestData();
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(searchList, searchFilter.ascOrder);
    searchFilter.upper = ul.upperAsTS;
    searchFilter.lower = ul.lowerAsTS;


    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'search_on_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.searchFilter] = searchFilter.toMap();


    requester.httpRequestEvents.onAnyState = (req) async {
      assistCtr.removeState(state$noRequestYet);
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List bList = data['sub_bucket_list']?? [];
      final List mList = data['media_list']?? [];
      //final List count = data['all_count'];
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
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);

        searchList.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    isInFetchData = true;
    assistCtr.updateMain();

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }

}
