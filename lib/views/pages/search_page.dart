import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:iris_tools/widgets/iris_search_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/media_manager.dart';
import 'package:app/services/favorite_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/tools/search_filter_tool.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/pages/levels/audio_player_page.dart';
import 'package:app/views/pages/levels/content_view_page.dart';
import 'package:app/views/pages/levels/video_player_page.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}
///====================================================================================================
class _SearchPageState extends StateSuper<SearchPage> {
  List<SubBucketModel> foundList = [];
  late ThemeData chipTheme;
  Requester requester = Requester();
  SearchFilterTool searchFilter = SearchFilterTool();
  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState(){
    super.initState();

    searchFilter.limit = 20;
    searchFilter.ascOrder = true;
    chipTheme = AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent);
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
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: IrisSearchBar(
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
              searchFilter.searchText = '';
              foundList.clear();
              assistCtr.clearStates();
              assistCtr.updateHead();
            },
          ),
        ),

        const SizedBox(height: 30),
        Expanded(
            child: Builder(
              builder: (context) {
                if(assistCtr.hasState(AssistController.state$error)) {
                  return ErrorOccur(onTryAgain: tryLoadClick);
                }

                if(assistCtr.hasState(AssistController.state$loading)) {
                  return const WaitToLoad();
                }

                if(foundList.isEmpty){
                  return const EmptyData();
                }

                return RefreshConfiguration(
                  headerBuilder: () => const MaterialClassicHeader(),
                  footerBuilder:  () => AppDecoration.classicFooter,
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
                      itemCount: foundList.length,
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
    final itm = foundList[idx];

    return SizedBox(
      height: 120,
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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

                                  return const SizedBox();
                                }
                            )
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

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
                                      return Text('${DurationFormatter.duration(dur, showSuffix: false)} ثانیه').alpha().thinFont();
                                    }

                                    return const SizedBox();
                                  },
                                ),


                                IconButton(
                                    constraints: const BoxConstraints.tightFor(),
                                    padding: const EdgeInsets.all(4),
                                    splashRadius: 20,
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 20,
                                    onPressed: () async {
                                      final res = await FavoriteService.addFavorite(itm);

                                      if(res){
                                        itm.isFavorite = true;
                                        assistCtr.updateHead();
                                      }
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
      ),
    );
  }

  void tryLoadClick() async {
    assistCtr.clearStates();
    assistCtr.addState(AssistController.state$loading);
    assistCtr.updateHead();

    requestData();
  }

  void onItemClick(SubBucketModel itm) {
    FocusHelper.hideKeyboardByUnFocus(context);

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
      inject.title = '';//widget.injectData.level1model?.title;
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

  void onLoadingMoreCall(){
    requestData();
  }

  void resetSearch(){
    foundList.clear();
    refreshController.resetNoData();

    assistCtr.clearStates();
    assistCtr.addState(AssistController.state$loading);
    assistCtr.updateHead();

    requestData();
  }

  void requestData() async {
    final ul = AppTools.findUpperLower(foundList, searchFilter.ascOrder);
    searchFilter.upper = ul.upperAsTS;
    searchFilter.lower = ul.lowerAsTS;


    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'search_on_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.searchFilter] = searchFilter.toMap();


    requester.httpRequestEvents.onAnyState = (req) async {
      assistCtr.clearStates();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.addStateWithClear(AssistController.state$error);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
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

        foundList.add(itm);
      }

      assistCtr.updateHead();
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }

}
