import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/vip_plan_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/currency_tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/structures/abstract/state_super.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/wait_to_load.dart';

class BuyVipPlanPage extends StatefulWidget{

  const BuyVipPlanPage({super.key});

  @override
  State<BuyVipPlanPage> createState() => _BuyVipPlanPageState();
}
///=============================================================================
class _BuyVipPlanPageState extends StateSuper<BuyVipPlanPage> {
  Requester requester = Requester();
  List<VipPlanModel> listItems = [];

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    requestData();
  }

  @override
  void dispose(){
    requester.dispose();

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

    return SizedBox(
      //height: 130,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: CustomCard(
          color: AppDecoration.mainColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(itm.title).color(Colors.white).bold().fsR(1)
                  ],
                ),

                Visibility(
                  visible: itm.description != null,
                  child: Row(
                    children: [
                      Text(itm.description?? '').alpha(alpha: 150)
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('قیمت: ').color(Colors.white),
                        Text(CurrencyTools.formatCurrency(itm.amount))
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

  void onBuyClick(VipPlanModel itm) {}
}
