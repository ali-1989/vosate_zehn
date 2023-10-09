import 'package:flutter/material.dart';

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

import 'package:app/managers/settings_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/dailyTextModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_overlay.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/tools/date_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/errorOccur.dart';
import 'package:app/views/states/waitToLoad.dart';

class SentencesPage extends StatefulWidget {

  const SentencesPage({Key? key}) : super(key: key);

  @override
  State<SentencesPage> createState() => _SentencesPageState();
}
///==================================================================================
class _SentencesPageState extends StateSuper<SentencesPage> {
  Requester requester = Requester();
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
          top: 80,
          left: 5,
          child: IconButton(
            icon: const Icon(AppIcons.settings, color: Colors.white),
            onPressed: showSettingDialog,
          ),
        ),

        Positioned(
          top: 100,
          bottom: 0,
          left: 0,
          right: 0,
          child: Builder(
            builder: (ctx){
              if(assistCtr.hasState(AssistController.state$error)){
                return ErrorOccur();
              }

              if(assistCtr.hasState(AssistController.state$loading)){
                return const WaitToLoad();
              }

              if(cards.isEmpty){
                return const EmptyData(textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),);
              }

              return AppinioSwiper(
                cardsCount: cards.length,
                cardsBuilder: (BuildContext context, int index) {
                  return cards[index];
                },
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                direction: AppinioSwiperDirection.right,
                swipeOptions: const AppinioSwipeOptions.all(),
                allowUnswipe: true,
                unlimitedUnswipe: false,
                loop: true,
              );
            },
          ),
        )
      ],
    );
  }

  void prepareCards() {
    AppTools.sortList(dailyList, false);

    final list = dailyList.map((t) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(DateTools.dateOnlyRelative(t.date), style: const TextStyle(color: Colors.grey),),
              const SizedBox(height: 12),
              Text(t.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            ],
          ),
        ),
      );
    }).toList();

    cards.clear();
    cards.addAll(list);
  }

  void showSettingDialog(){
    final view = Align(
      child: Assist(
        selfControl: true,
        builder: (ctx, ctr, data){
          return FractionallySizedBox(
            widthFactor: .8,
            child: Card(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: const Text('تنظیمات').bold()),

                        const SizedBox(
                          height: 8,
                        ),

                        SizedBox(
                          height: 1,
                          width: double.infinity,
                          child: ColoredBox(
                            color: Colors.grey[300]!,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        CheckBoxRow(
                            value: SettingsManager.localSettings.notificationDailyText,
                            description: const Text('نمایش جملات روز به صورت نوتیفیکیشن'),
                            onChanged: (v){
                              SettingsManager.localSettings.notificationDailyText = v;
                              ctr.updateSelf();
                              SettingsManager.saveLocalSettingsAndNotify();
                            }
                        )
                      ],
                    ),
                  ),

                  const Positioned(
                    top: 0,
                      left: 0,
                      child: CloseButton()
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    final overlay = OverlayScreenView(content: view, backgroundColor: Colors.black26);

    AppOverlay.showDialogScreen(context, overlay, canBack: true);
  }

  void requestData(DateTime dateTime) async {
    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.addStateWithClear(AssistController.state$error);
      assistCtr.updateHead();
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final List tList = data[Keys.dataList]?? [];

      for(final m in tList){
        final msg = DailyTextModel.fromMap(m);

        if(dailyList.firstWhereSafe((element) => element.date == msg.date) == null) {
          dailyList.add(msg);
        }
      }

      prepareCards();
      assistCtr.clearStates();
      assistCtr.updateHead();

      if(AppCache.timeoutCache.addTimeout(Keys.setting$textOfDayGetPreMonth, const Duration(minutes: 2))){
        var now = GregorianDate();
        now.changeTime(0, 0, 0, 0);
        final pre = now.addMonth(-1);

        requestData(pre.getFirstOfMonth().convertToSystemDate());
      }
    };

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_daily_text_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;
    js[Keys.date] = DateHelper.toTimestamp(dateTime);
    js['end_date'] = DateHelper.toTimestamp(DateTime.now());

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context, false);
  }
}
