import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';

class DrawerMenuBuilder {
  DrawerMenuBuilder._();

  static Widget? _drawer;

  static Widget getDrawer(){
    if(_drawer == null){
      _gen();
    }

    return _drawer!;
  }

  static void _gen(){
    _drawer = SizedBox(
      width: MathHelper.minDouble(400, MathHelper.percent(AppSizes.instance.appWidth!, 60)),
      child: Drawer(
        child: Column(
          children: [
            SizedBox(height: 20,),

            SizedBox(
              height: 170,
              child: Center(
                child: Image.asset(AppImages.appIcon, height: 100,),
              ),
            ),

            SizedBox(height: 20,),

            ListTile(
              title: Text(AppMessages.favorites),
              leading: Icon(AppIcons.heart),
            ),

            ListTile(
              title: Text(AppMessages.lastSeenItem),
              leading: Icon(AppIcons.history),
            ),

            ListTile(
              title: Text(AppMessages.shareApp),
              leading: Icon(AppIcons.share),
              onTap: shareAppCall,
            ),

            ListTile(
              title: Text(AppMessages.hematatUs),
              leading: Icon(AppIcons.cashMultiple),
            ),

            ListTile(
              title: Text(AppMessages.contactUs),
              leading: Icon(AppIcons.message),
            ),

            ListTile(
              title: Text(AppMessages.aboutUs),
              leading: Icon(AppIcons.infoCircle),
            ),
          ],
        ),
      ),
    );
  }

  static void shareAppCall() {
    ShareExtend.share('https://cafebazaar.ir/app/ir.vosatezehn.com', 'text');
  }
}