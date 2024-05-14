

import 'package:app/services/cafe_bazar_service.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/mediaModelWrapForContent.dart';
import 'package:app/structures/models/vip_plan_model.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_loading.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app_tools.dart';
import 'package:flutter/material.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/build_flavor.dart';
import 'package:app/tools/app/app_dialog.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/profile/buy_vip_plan_page.dart';
import 'package:app/views/pages/profile/cafe_bazar_page.dart';
import 'package:flutter_poolakey/purchase_info.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class VipService {
  VipService._();

  static bool checkVip(BuildContext context, SubBucketModel itm) {
    final user = SessionService.getLastLoginUser();

    if(itm.isVip && (user == null || user.userId == '0')){
      AppSnack.showError(context, 'برای دسترسی یه این محنوا باید ثبت نام کنید.');
      return false;
    }

    /// for voices page, check vip after 1 voice.
    if(itm.type == SubBucketTypes.list.id()){
      return true;
    }

    if(itm.isVip && !user!.vipOptions.isVip()){
      final decor = AppDialog.instance.dialogDecoration.copy();
      decor.descriptionStyle = AppThemes.boldTextStyle().copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800
      );

      AppDialog.instance.showDialog(
          context,
          decorationConfig: decor,
          desc: 'این محتوا فقط برای کاربران ویژه می باشد',
          actions: [
            ElevatedButton(
                onPressed: ()=> Navigator.of(context).pop(),
                child: const Text('متوجه شدم')
            ),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: popAndGotoBuyVipPage,
                child: const Text('خرید اشتراک')
            ),
          ]
      );
      return false;
    }

    return true;
  }

  static bool checkVipForMultiItemPage(BuildContext context, MediaModelWrapForContent itm) {
    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      AppSnack.showError(context, 'برای دسترسی یه این محنوا باید ثبت نام کنید.');
      return false;
    }

    if(!user.vipOptions.isVip()){
      final decor = AppDialog.instance.dialogDecoration.copy();
      decor.descriptionStyle = AppThemes.boldTextStyle().copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w800
      );

      AppDialog.instance.showDialog(
          context,
          decorationConfig: decor,
          desc: 'این محتوا فقط برای کاربران ویژه می باشد',
          actions: [
            ElevatedButton(
                onPressed: ()=> Navigator.of(context).pop(),
                child: const Text('متوجه شدم')
            ),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: popAndGotoBuyVipPage,
                child: const Text('خرید اشتراک')
            ),
          ]
      );
      return false;
    }

    return true;
  }

  static void popAndGotoBuyVipPage() async {
    final context = RouteTools.getBaseContext()!;
    Navigator.of(context).pop();
    RouteTools.pushPage(context, getPayPage());
  }

  static void gotoBuyVipPage(BuildContext? context) async {
    context ??= RouteTools.getBaseContext()!;
    RouteTools.pushPage(context, getPayPage());
  }

  static Widget getPayPage(){
    if(BuildFlavor.isForBazar()){
      return const CafeBazarPage();
    }

    return const BuyVipPlanPage();
  }

  static Future<void> sendCafeBazarPurchaseToServer(PurchaseInfo itm, VipPlanModel? model, bool service) async {
    final user = SessionService.getLastLoginUser();
    final ts = DateTime.fromMillisecondsSinceEpoch(itm.purchaseTime);

    final js = <String, dynamic>{};
    js[Keys.request] = 'register_cafe_bazar_purchase';
    js[Keys.requesterId] = user!.userId;
    js[Keys.userId] = user.userId;
    js['amount'] = model?.amount;
    js['plan_id'] = model?.id;
    js['days'] = model?.days;//todo. on server
    js['purchase_token'] = itm.purchaseToken;
    js['product_id'] = itm.productId;
    js['package_name'] = itm.packageName;
    js['purchase_state'] = itm.purchaseState.name;
    js['purchase_ts'] = DateHelper.toTimestampNullable(ts);
    js['data_signature'] = itm.dataSignature;
    js['order_id'] = itm.orderId;

    final context = RouteTools.getBaseContext()!;

    if(service){
      await CafeBazarService().sendDataToServer(js, isFirst: true);
      return;
    }

    void subFn(bool isFirst) async {
      AppLoading.instance.showLoading(context);
      final res = await CafeBazarService().sendDataToServer(js, isFirst: isFirst);
      await AppLoading.instance.hideLoading(context);

      if(res){
        RouteTools.popIfCan(context);
      }
      else {
        AppSheet.showSheetOneAction(context,
          'فرایند به درستی انجام نشد.لطفا دوباره تلاش کنید.',
          buttonText: 'تلاش مجدد',
          onButton: ()=> subFn(false),
        );
      }
    }

    subFn(true);
  }

  static void checkAutoBazarPurchase() async {
    if(!BuildFlavor.isForBazar()){
      return;
    }

    final user = SessionService.getLastLoginUser();

    if(user == null){
      return;
    }

    final list = await CafeBazarService().getAllSubscribedProducts();

    if(list.isEmpty){
      return;
    }

    var last = list.first;
    PurchaseInfo? reFund;

    for(final i in list){
      if(i.purchaseTime > last.purchaseTime && i.purchaseState == PurchaseState.PURCHASED){
        last = i;
      }

      if(i.productId == user.vipOptions.productId && i.purchaseState == PurchaseState.REFUNDED){
        reFund = i;
      }
    }

    /* || user.vipOptions.expireDate == null*/

    if(!user.vipOptions.isVip() && last.purchaseState == PurchaseState.PURCHASED){
      await sendCafeBazarPurchaseToServer(last, null, true);
      AppTools.requestProfileDataForVip();
    }


    if(reFund != null){
      await sendCafeBazarPurchaseToServer(reFund, null, true);
      AppTools.requestProfileDataForVip();
    }
    //final date = DateTime.fromMillisecondsSinceEpoch(last.purchaseTime);
  }
}
