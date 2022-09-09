import 'package:app/models/dailyTextModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/dateTools.dart';
import 'package:app/views/emptyData.dart';
import 'package:app/views/notFetchData.dart';
import 'package:app/views/progressView.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/views/AppBarCustom.dart';

class SentencesPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/Sentences',
    name: (SentencesPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => SentencesPage(),
  );

  const SentencesPage({Key? key}) : super(key: key);

  @override
  State<SentencesPage> createState() => _SentencesPageState();
}
///==================================================================================
class _SentencesPageState extends StateBase<SentencesPage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  List<String> backgrounds = [];
  String background = '';
  List<DailyTextModel> dailyList = [];
  List<Widget> cards = [];

  @override
  void initState(){
    super.initState();

    backgrounds.add(AppImages.back1);
    backgrounds.add(AppImages.back2);
    backgrounds.add(AppImages.back3);
    backgrounds.add(AppImages.back4);
    backgrounds.add(AppImages.back5);

    background = Generator.getRandomFrom(backgrounds);

    var now = GregorianDate();
    now.changeTime(0, 0, 0, 0);

    requestData(now.getFirstOfMonth().convertToSystemDate());
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
            extendBodyBehindAppBar: true,
            appBar: AppBarCustom(
              title: Text(AppMessages.sentencesTitle),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(background, fit: BoxFit.fill),

        Positioned(
          top: 100,
          bottom: 0,
          left: 0,
          right: 0,
          child: Builder(
            builder: (ctx){
              if(isInFetchData){
                return ProgressView();
              }

              if(!assistCtr.hasState(state$fetchData)){
                return NotFetchData();
              }

              if(cards.isEmpty){
                return EmptyData(textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),);
              }

              return AppinioSwiper(
                cards: cards,
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                allowUnswipe: false,
              );
            },
          ),
        )
      ],
    );
  }

  void prepareCards() {
    PublicAccess.sortList(dailyList, false);

    final list = dailyList.map((t) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateTools.dateOnlyRelative(t.date), style: TextStyle(color: Colors.grey),),
              SizedBox(height: 12,),
              Text(t.text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            ],
          ),
        ),
      );
    }).toList();

    cards.addAll(list);
  }

  void requestData(DateTime dateTime) async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_daily_text_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.date] = DateHelper.toTimestamp(dateTime);

    requester.httpRequestEvents.onFailState = (req) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdate(state$fetchData);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List tList = data[Keys.dataList]?? [];

      for(final m in tList){
        dailyList.add(DailyTextModel.fromMap(m));
      }

      prepareCards();
      assistCtr.addStateAndUpdate(state$fetchData);

      if(AppDB.fetchKv(Keys.setting$textOfDayGetPreMonth) == null){
        var now = GregorianDate();
        now.changeTime(0, 0, 0, 0);
        final pre = now.addMonth(1);

        AppDB.setReplaceKv(Keys.setting$textOfDayGetPreMonth, true);
        requestData(pre.getFirstOfMonth().convertToSystemDate());
      }
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context, false);
  }
}
