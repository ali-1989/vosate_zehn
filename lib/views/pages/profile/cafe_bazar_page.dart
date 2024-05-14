import 'package:app/services/vip_service.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/custom_card.dart';

import 'package:app/services/cafe_bazar_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/vip_plan_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/currency_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

class CafeBazarPage extends StatefulWidget{

  const CafeBazarPage({super.key});

  @override
  State<CafeBazarPage> createState() => _CafeBazarPageState();
}
///=============================================================================
class _CafeBazarPageState extends StateSuper<CafeBazarPage> {
  Requester requester = Requester();
  List<VipPlanModel> listItems = [];
  bool callBankGetWay = false;

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);

    //requestData();
    connectToBazar();
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
      body: buildScaffoldBody(),
    );
  }

  Widget buildScaffoldBody(){
    if(assistCtr.hasState(AssistController.state$loading)) {
      return const WaitToLoad();
    }

    if(assistCtr.hasState(AssistController.state$error)) {
      return ErrorOccur(onTryAgain: onTryToConnect);
    }

    return buildAlterBody1();
  }

  Widget buildAlterBody1(){
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
            child: buildAlterBody2()
        ),
      ],
    );
  }

  Widget buildAlterBody2(){
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
                          .color(AppDecoration.differentColor).bold(),

                      const Text(' تومان').color(Colors.white),

                    ],
                  ),

                  Visibility(
                    visible: itm.days > 0,
                    child: CustomCard(
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
                    onPressed: ()=> subscribe(itm),
                    child: const Text('خرید')
                ),
              )
            ],
          )
      ),
    );
  }

 void connectToBazar() async {
   final res = await CafeBazarService().connect();

   if(res){
     assistCtr.clearStates();
     getVipList();
   }
   else {
     assistCtr.addStateWithClear(AssistController.state$error);
   }

   callState();
 }

 void subscribe(VipPlanModel model) async {
   final res = await CafeBazarService().doSubscribe('c${model.id}', payload: '${model.id}');

   if(res != null && res.payload == '${model.id}'){
     VipService.sendCafeBazarPurchaseToServer(res, model, false);
   }
   else {
     AppToast.showToast(context, 'خرید انجام نشد.');
   }
 }

  void onTryToConnect() {
    assistCtr.addStateWithClear(AssistController.state$loading);
    callState();
    connectToBazar();
  }

  void getVipList() async {
    final nList = <String>[];
    for(var i=10; i< 400; i=i+5){
      nList.add('c$i');
    }

    final res = await CafeBazarService().getSubscriptionSkuDetails(nList);

    for(final i in res){
      final vip = VipPlanModel();
      vip.title = i.title;
      vip.id = MathHelper.clearToInt(i.sku);
      vip.amount = MathHelper.clearToInt(i.price);
      vip.description = i.description;
      vip.days = vip.id;

      if(vip.amount == 250){
        continue;
      }

      listItems.add(vip);
    }

    callState();
  }
}
