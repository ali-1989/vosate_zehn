import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/media_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/bucketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/request_options.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/levels/sub_bucket_page.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

class BucketPageInjectData {
  late BucketTypes bucketTypes;
}
///-----------------------------------------------------------------------------
class BucketPage extends StatefulWidget{
  final BucketPageInjectData injectData;

  // ignore: prefer_const_constructors_in_immutables
  BucketPage({
    required this.injectData,
    super.key,
  });

  @override
  State<BucketPage> createState() => _BucketPageState();
}
///=============================================================================
class _BucketPageState extends StateSuper<BucketPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<BucketModel> listItems = [];
  RefreshController refreshController = RefreshController(initialRefresh: false);
  RequestOptions searchFilter = RequestOptions();


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
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return const WaitToLoad();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return ErrorOccur(onTryAgain: tryLoadClick);
    }

    if(listItems.isEmpty){
      return const EmptyData();
    }

    return RefreshConfiguration(
      headerBuilder: () => const MaterialClassicHeader(),
      footerBuilder: () => AppDecoration.classicFooter,
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
        child: ListView.builder(
          itemCount: listItems.length,
            itemBuilder: (ctx, idx){
              return buildListItem(idx);
            }
        ),
      ),
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [

              /// image
              Builder(
                builder: (ctx){
                  if(itm.imageModel?.url != null){
                    //return Image.network(itm.imageModel!.url!, width: 100, height: 100, fit: BoxFit.contain);
                    return IrisImageView(
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      url: itm.imageModel!.url!,
                      imagePath: AppDirectories.getSavePathMedia(itm.imageModel, SavePathType.anyOnInternal, null),
                    );
                  }

                  return Image.asset(AppImages.appIcon, width: 100, height: 100, fit: BoxFit.contain);
                },
              ),

              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itm.title, maxLines: 1,).bold().fsR(1),

                        const SizedBox(height: 8,),
                        Text('${itm.description}').alpha().thinFont(),
                      ],
                    ),

                    /// vip icon
                    Positioned(
                        bottom: 3,
                        left: 3,
                        child: Builder(
                            builder: (context) {
                              if(itm.isVip){
                                return Image.asset(AppImages.vip1, width: 30, height: 30);
                              }

                              return const SizedBox();
                            }
                        )
                    ),
                  ],
                ),
              ),
            ],
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

  void onItemClick(BucketModel itm) {
    RouteTools.pushPage(context, SubBucketPage(injectData: SubBucketPageInjectData()..bucketModel = itm), name: 'SubBucket-Page'.toLowerCase());
  }

  void requestData() async {
    final ul = AppTools.findUpperLower(listItems, searchFilter.ascOrder);
    searchFilter.upper = ul.upperAsTS;
    searchFilter.lower = ul.lowerAsTS;


    final js = <String, dynamic>{};
    js[Keys.request] = 'get_bucket_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData.bucketTypes.id();
    js[Keys.searchFilter] = searchFilter.toMap();

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
      return false;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List bList = data['bucket_list']?? [];
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
        final itm = BucketModel.fromMap(m);
        itm.imageModel = MediaManager.getById(itm.mediaId);

        listItems.add(itm);
      }

      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.prepareUrl();
    requester.request();
  }
}
