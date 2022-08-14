import 'package:flutter/material.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vosate_zehn/models/level1Model.dart';
import 'package:vosate_zehn/pages/levels/level2_page.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/publicAccess.dart';
import 'package:vosate_zehn/views/notFetchData.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

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
  List<Level1Model> listItems = [];
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

    return ListView.builder(
        itemCount: 0,//listItems.length,
        itemBuilder: (ctx, idx){
          return buildListItem(idx);
        }
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

  void onItemClick(Level1Model itm) {
    AppRoute.pushNamed(context, Level2Page.route.name!, extra: Level2PageInjectData()..level1model = itm);
  }

  void requestData() async {
    final ul = PublicAccess.findUpperLower(listItems, isAscOrder);

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_level1_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
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
        final itm = Level1Model.fromMap(m);
        listItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.prepareUrl();
    requester.request(context);
  }

  /*void addTempData(){
    final v1 = Level1Model();
    final v2 = Level1Model();

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
