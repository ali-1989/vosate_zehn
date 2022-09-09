import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/bucketModel.dart';
import 'package:app/pages/levels/sub_bucket_page.dart';
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
  List<BucketModel> newItems = [];
  List<BucketModel> meditationItems = [];
  List<BucketModel> videoItems = [];
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
    return EmptyData();

    if(isInFetchData) {
      return ProgressView();
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
    final itm = newItems[idx];

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

  void onNewAdv(){
    print('@@@@@@@@@@ onNewAdv');
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

  void onItemClick(BucketModel itm) {
    AppRoute.pushNamed(context, SubBucketPage.route.name!, extra: SubBucketPageInjectData()..bucketModel = itm);
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
print(data);
      final List list = data['new_list']?? [];
      final List mList = data['new_meditation_list']?? [];
      final List vList = data['new_video_list']?? [];

      for(final m in list){
        final itm = BucketModel.fromMap(m);
        newItems.add(itm);
      }

      for(final m in mList){
        final itm = BucketModel.fromMap(m);
        meditationItems.add(itm);
      }

      for(final m in vList){
        final itm = BucketModel.fromMap(m);
        videoItems.add(itm);
      }

      assistCtr.addStateAndUpdate(state$fetchData);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }
}
