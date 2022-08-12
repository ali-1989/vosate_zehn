import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:iris_tools/widgets/avatarChip.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vosate_zehn/models/userModel.dart';
import 'package:vosate_zehn/pages/about_us_page.dart';
import 'package:vosate_zehn/pages/contact_us_page.dart';
import 'package:vosate_zehn/pages/favorites_page.dart';
import 'package:vosate_zehn/pages/last_seen_page.dart';
import 'package:vosate_zehn/services/aidService.dart';
import 'package:vosate_zehn/system/enums.dart';
import 'package:vosate_zehn/system/session.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appDialogIris.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';

import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';
import 'package:vosate_zehn/tools/app/downloadUpload.dart';
import 'package:vosate_zehn/tools/userLoginTools.dart';

class DrawerMenuBuilder {
  DrawerMenuBuilder._();

  //static Widget? _drawer;

  static Widget getDrawer(){
    return Refresh(
      controller: AppBroadcast.drawerMenuRefresher,
      builder: (ctx, ctr){
        return _buildDrawer();
      },
    );
  }

  static Widget _buildDrawer(){
    return SizedBox(
      width: MathHelper.minDouble(400, MathHelper.percent(AppSizes.instance.appWidth, 60)),
      child: Drawer(
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),

            _buildProfileSection(),

            SizedBox(height: 10),

            if(Session.hasAnyLogin())
              ListTile(
                title: Text(AppMessages.logout).color(Colors.redAccent),
                leading: Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                onTap: onLogoffCall,
              ),

            ListTile(
              title: Text(AppMessages.favorites),
              leading: Icon(AppIcons.heart),
              onTap: gotoFavoritesPage,
            ),

            ListTile(
              title: Text(AppMessages.lastSeenItem),
              leading: Icon(AppIcons.history),
              onTap: gotoLastSeenPage,
            ),

            ListTile(
              title: Text(AppMessages.shareApp),
              leading: Icon(AppIcons.share),
              onTap: shareAppCall,
            ),

            ListTile(
              title: Text(AppMessages.aidUs),
              leading: Icon(AppIcons.cashMultiple),
              onTap: gotoAidPage,
            ),

            ListTile(
              title: Text(AppMessages.contactUs),
              leading: Icon(AppIcons.message),
              onTap: gotoContactUsPage,
            ),

            ListTile(
              title: Text(AppMessages.aboutUs),
              leading: Icon(AppIcons.infoCircle),
              onTap: gotoAboutUsPage,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProfileSection(){
    if(Session.hasAnyLogin()){
      final user = Session.getLastLoginUser()!;

      return GestureDetector(
        onTap: gotoProfilePage,
        child: Column(
          children: [
            NotifyRefresh(
              notifier: AppBroadcast.avatarNotifier,
              builder: (ctx, data) {
                return AvatarChip(
                  label: Text(''),
                backgroundColor: ColorHelper.textToColor(user.nameFamily,),
                  avatar: Builder(
                    builder: (ctx){
                      final path = AppDirectories.getSavePathUri(user.profileModel!.url!, SavePathType.userProfile, user.avatarFileName);
                      final img = FileHelper.getFile(path);

                      if(img.existsSync() && img.lengthSync() == user.profileModel!.volume!){
                        return Image.file(img, height: 50, width: 50,);
                      }

                      checkAvatar(user);
                      return Image.asset(AppImages.appIcon, height: 50, width: 50,);
                    },
                  ),
                );
              },
            ),

            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                      Flexible(
                          child: Text(user.nameFamily,
                          maxLines: 1, overflow: TextOverflow.clip,
                          ).bold()
                      ),

                    /*IconButton(
                        onPressed: gotoProfilePage,
                        icon: Icon(AppIcons.report2, size: 18,).alpha()
                    ),*/
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: Center(
        child: Image.asset(AppImages.appIcon, height: 90,),
      ),
    );
  }

  static void shareAppCall() {
    ShareExtend.share('https://cafebazaar.ir/app/ir.vosatezehn.com', 'text');
  }

  static void gotoFavoritesPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), FavoritesPage.route.name!);
  }

  static void gotoLastSeenPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), LastSeenPage.route.name!);
  }

  static void gotoAidPage(){
    AidService.gotoAidPage();
  }

  static void gotoContactUsPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), ContactUsPage.route.name!);
  }

  static void gotoAboutUsPage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), AboutUsPage.route.name!);
  }

  static void gotoProfilePage(){
    AppBroadcast.homeScreenKey.currentState?.scaffoldState.currentState?.closeDrawer();
    AppRoute.pushNamed(AppRoute.getContext(), AboutUsPage.route.name!);
  }

  static void onLogoffCall(){
    void yesFn(){
      UserLoginTools.forceLogoff(Session.getLastLoginUser()!.userId);
    }

    AppDialogIris.instance.showYesNoDialog(
      AppRoute.getContext(),
      desc: AppMessages.doYouWantLogoutYourAccount,
      dismissOnButtons: true,
      yesText: AppMessages.yes,
      noText: AppMessages.no,
      yesFn: yesFn,
      decoration: AppDialogIris.instance.dialogDecoration.copy()..positiveButtonBackColor = Colors.green,
    );
  }

  static void checkAvatar(UserModel user) async {
    if(user.profileModel?.url == null){
      return;
    }

    final path = AppDirectories.getSavePathUri(user.profileModel!.url!, SavePathType.userProfile, user.avatarFileName);
    final img = FileHelper.getFile(path);

    if(img.existsSync() && img.lengthSync() == user.profileModel!.volume!){
      return;
    }

    final dItm = DownloadUpload.downloadManager.createDownloadItem(user.profileModel!.url!, tag: user.profileModel!.id!);
    dItm.savePath = path;
    dItm.category = DownloadCategory.userProfile;

    DownloadUpload.downloadManager.enqueue(dItm);
  }
}
