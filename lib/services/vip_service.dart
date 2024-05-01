

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

class VipService {
  VipService._();

  static bool checkVip(BuildContext context, SubBucketModel itm){
    final user = SessionService.getLastLoginUser();

    if(itm.isVip && (user == null || user.userId == '0')){
      AppSnack.showError(context, 'برای دسترسی یه این محنوا باید ثبت نام کنید.');
      return false;
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
                onPressed: gotoBuyVipPage,
                child: const Text('خرید اشتراک')
            ),
          ]
      );
      return false;
    }

    return true;
  }

  static void gotoBuyVipPage() async {
    final context = RouteTools.getBaseContext()!;
    Navigator.of(context).pop();
    RouteTools.pushPage(context, getPayPage());
  }

  static Widget getPayPage(){
    if(BuildFlavor.isForBazar()){
      return const CafeBazarPage();
    }

    return const BuyVipPlanPage();
  }

}
