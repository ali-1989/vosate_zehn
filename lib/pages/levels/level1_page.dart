import 'package:app/models/bucketModel.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/pages/levels/level2_page.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/system/stateBase.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/publicAccess.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/waitToLoad.dart';

class Level1PageInjectData {
  String? requestKey;
}
///---------------------------------------------------------------------------------
class Level1Page extends StatefulWidget {
  final Level1PageInjectData injectData;

  Level1Page({
    required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<Level1Page> createState() => _Level1PageState();
}
///==================================================================================
class _Level1PageState extends StateBase<Level1Page> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<BucketModel> listItems = [];
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
              Image.network(itm.imageModel?.url?? '', width: 100, height: 100, fit: BoxFit.cover),

              SizedBox(width: 8,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${itm.title}', maxLines: 1,).bold().fsR(1),

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
    AppRoute.pushNamed(context, Level2Page.route.name!, extra: SubBucketPageInjectData()..bucketModel = itm);
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(listItems, isAscOrder);

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_level1_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.key] = widget.injectData.requestKey;
    js[Keys.count] = fetchCount;


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
        final itm = BucketModel.fromMap(m);
        listItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

  /*void addTempData(){
    final v1 = BucketModel();
    final v2 = BucketModel();

    v1.title = 'انیمیشن';
    v2.title = 'علمی';

    v1.description = 'کلیپ های کوتاه و کاربردی یرای درک';
    v2.description = 'درک رسیدن به آرامش با تماشای کلیپ های علمی و کاربردی یرای درک';

    v1.imageModel = MediaModel.fromMap({})..url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/800px-Image_created_with_a_mobile_phone.png';
    v2.imageModel = MediaModel.fromMap({})..url = 'https://overlay.imageonline.co/overlay-image.jpg';

    listItems.add(v1);
    listItems.add(v2);
  }*/
}
