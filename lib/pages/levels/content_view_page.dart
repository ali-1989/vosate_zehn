import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vosate_zehn/models/level1Model.dart';
import 'package:vosate_zehn/models/level2Model.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/publicAccess.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class ContentViewPageInjectData {
  Level1Model? level1model;
}
///---------------------------------------------------------------------------------
class ContentViewPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/content_view',
    name: (ContentViewPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ContentViewPage(),
  );

  //final Level2PageInjectData injectData;

  ContentViewPage({
    //required this.injectData,
    Key? key,
  }) : super(key: key);

  @override
  State<ContentViewPage> createState() => _LevelPageState();
}
///=================================================================================================
class _LevelPageState extends StateBase<ContentViewPage> {
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
              title: Text('hh'),
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

  void onItemClick(Level2Model itm) {
    //AppRoute.pushNamed(context, LevelPage.route.name!, );
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(listItems, isAscOrder);

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_level2_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    //js[Keys.id] = widget.injectData.level1model!.id;

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
        listItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

}
