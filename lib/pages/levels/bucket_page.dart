import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/managers/mediaManager.dart';
import 'package:app/pages/levels/sub_bucket_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/bucketModel.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/structures/middleWare/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class BucketPageInjectData {
  late BucketTypes bucketTypes;
}
///---------------------------------------------------------------------------------
class BucketPage extends StatefulWidget {
  final BucketPageInjectData injectData;

  BucketPage({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<BucketPage> createState() => _BucketPageState();
}
///==================================================================================
class _BucketPageState extends StateBase<BucketPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<BucketModel> listItems = [];
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
      return ErrorOccur(onRefresh: tryLoadClick);
    }

    if(listItems.isEmpty){
      return EmptyData();
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
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
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

              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itm.title, maxLines: 1,).bold().fsR(1),

                    SizedBox(height: 8,),
                    Text('${itm.description}').alpha().subFont(),
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
    assistCtr.updateMain();

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void onItemClick(BucketModel itm) {
    AppRoute.pushNamed(context, SubBucketPage.route.name!, extra: SubBucketPageInjectData()..bucketModel = itm);
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(listItems, searchFilter.ascOrder);
    searchFilter.upper = ul.upperAsTS;
    searchFilter.lower = ul.lowerAsTS;


    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_bucket_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData.bucketTypes.id();
    js[Keys.searchFilter] = searchFilter.toMap();


    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
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

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
