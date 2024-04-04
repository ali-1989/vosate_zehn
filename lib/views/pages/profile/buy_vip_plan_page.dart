import 'dart:async';

import 'package:app/managers/api_manager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/vip_plan_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/currency_tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/wait_to_load.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BuyVipPlanPage extends StatefulWidget{

  const BuyVipPlanPage({super.key});

  @override
  State<BuyVipPlanPage> createState() => _BuyVipPlanPageState();
}
///=============================================================================
class _BuyVipPlanPageState extends StateSuper<BuyVipPlanPage> {
  Requester requester = Requester();
  late AppLifecycleListener lifecycleListener;
  List<VipPlanModel> listItems = [];

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    lifecycleListener = AppLifecycleListener(
      onResume: ()=> print('====== resume'),
      onPause: ()=> print('====== pause'),
    );

    requestData();
  }

  @override
  void dispose(){
    requester.dispose();
    lifecycleListener.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: Text(AppMessages.vipPlanPage),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$loading)) {
      return const WaitToLoad();
    }

    return buildSubBody1();
  }

  Widget buildSubBody1(){
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: CustomCard(
            color: AppDecoration.differentColor,
            padding: const EdgeInsets.all(15),
              child: Text(AppMessages.vipPlanDescription)
                  .color(Colors.white)
              .bold().fsR(2)
          ),
        ),

        const SizedBox(height: 30),

        Expanded(
            child: buildSubBody2()
        ),
      ],
    );
  }

  Widget buildSubBody2(){
    if(listItems.isEmpty) {
      return const EmptyData();
    }

    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (ctx, idx){
        return buildListItem(idx);
      },
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: CustomCard(
        color: AppDecoration.mainColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(AppIcons.zoomIn, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(itm.title).color(Colors.white).bold().fsR(1)
                  )
                ],
              ),

              Visibility(
                visible: itm.description != null,
                child: Row(
                  children: [
                    Expanded(
                        child: Text(itm.description?? '').alpha(alpha: 150)
                    )
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('قیمت: ').color(Colors.white),
                      Text(CurrencyTools.formatCurrency(itm.amount/10))
                          .color(Colors.green).bold(),

                      const Text(' تومان').color(Colors.white),

                    ],
                  ),

                  CustomCard(
                    color: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: Row(
                      children: [
                        Text('${itm.days}')
                            .color(Colors.white),

                        const Text(' روز').color(Colors.white),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(100, 50),
                  ),
                    onPressed: ()=> onBuyClick(itm),
                    child: const Text('خرید')
                ),
              )
            ],
          )
      ),
    );
  }

  void requestData() async {
    requester.httpRequestEvents.onFailState = (req, r) async {
      assistCtr.clearStates();
      assistCtr.addStateAndUpdateHead(AssistController.state$error);
      callState();
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      assistCtr.clearStates();
      listItems.clear();

      final list = data['data'];

      if(list is List){
        for(final k in list){
          listItems.add(VipPlanModel.fromMap(k));
        }
      }

      callState();
    };

    final user = SessionService.getLastLoginUser();

    final js = <String, dynamic>{};
    js[Keys.request] = 'get_vip_plans';
    js[Keys.requesterId] = user!.userId;

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();
  }

  void onBuyClick(VipPlanModel itm) {
    requester.httpRequestEvents.manageResponse = (req, r) async {
      final data = r['data'];

      if(data is Map){
        final code = data['code'];

        if(code == 100){
          final authority = data['authority'];
          final res = await requestPreTransaction(itm, authority, itm.amount);
          await hideLoading();

          if(res){
            gotoPayWebPage(itm, authority);
          }
          else{
            AppSnack.showError(context, 'متاسفانه سرور پاسخ نمی دهد.');
          }
        }
        else {
          await hideLoading();
          AppSnack.showError(context, 'متاسفانه درگاه پرداخت خطا دارد.');
        }
      }
      else {
        await hideLoading();
        AppSnack.showError(context, 'متاسفانه درگاه پرداخت جواب نداد.');
      }
    };


    final user = SessionService.getLastLoginUser();

    final js = <String, dynamic>{};
    js['merchant_id'] = '27b220df-c1b3-489f-af52-7faadddcf4b3';
    js['currency'] = 'IRT';
    js['callback_url'] = 'https://vosatezehn.com:7437/callback_gate';
    js['amount'] = itm.amount/10;
    js['description'] = itm.title;
    js['metadata'] = {
      'mobile': user!.mobile,
      'email': user.email,
      'id': user.userId,
    };

    showLoading();
    requester.bodyJson = js;
    requester.httpItem.headers['accept'] = 'application/json';
    requester.httpItem.headers['content-type'] = 'application/json';
    requester.prepareUrl(fullUrl: 'https://api.zarinpal.com/pg/v4/payment/request.json');
    requester.request();
  }

  Future<bool> requestPreTransaction(VipPlanModel itm, String authority, int amount) {
    final retCompleted = Completer<bool>();

    requester.httpRequestEvents.manageResponse = (req, r) async {
      await hideLoading();
      final data = r['status'];

      if(data == 'ok'){
        retCompleted.complete(true);
      }
      else {
        retCompleted.complete(false);
      }
    };


    final user = SessionService.getLastLoginUser();

    final js = <String, dynamic>{};
    js[Keys.request] = 'register_pre_transaction';
    js[Keys.requesterId] = user!.userId;
    js['authority'] = authority;
    js['merchant_id'] = '27b220df-c1b3-489f-af52-7faadddcf4b3';
    js['amount'] = amount;
    js['days'] = itm.days;

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();

    return retCompleted.future;
  }

  void gotoPayWebPage(VipPlanModel itm, String authority) {
    final url = 'https://www.zarinpal.com/pg/StartPay/$authority';
    //UrlHelper.launchWeb(url);
    UrlHelper.launchLink(url, mode: LaunchMode.externalApplication);
  }
}
