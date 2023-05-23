import 'dart:io';

import 'package:app/constants.dart';
import 'package:app/managers/versionManager.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:share_extend/share_extend.dart';

import 'package:app/pages/about_us_page.dart';
import 'package:app/pages/contact_us_page.dart';
import 'package:app/pages/favorites_page.dart';
import 'package:app/pages/last_seen_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/sentences_page.dart';
import 'package:app/services/aidService.dart';
import 'package:app/services/download_upload_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/services/session_service.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/routeTools.dart';

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
        child: Column(
          children: [
            Expanded(
              child: Theme(
                data: AppThemes.instance.themeData.copyWith(
                    textTheme: TextTheme(bodyLarge: TextStyle(fontSize: 10, color: Colors.black))
                ),
                child: ListView(
                  children: [
                    SizedBox(height: 32),

                    _buildProfileSection(),

                    SizedBox(height: 10),

                    if(SessionService.hasAnyLogin())
                      ListTile(
                        title: Text(SessionService.isGuestCurrent()? AppMessages.registerTitle :AppMessages.logout).color(Colors.redAccent),
                        leading: Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                        onTap: onLogoffCall,
                        dense: true,
                      ),

                    ListTile(
                      title: Text(AppMessages.favorites),
                      leading: Icon(AppIcons.heart),
                      onTap: gotoFavoritesPage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.lastSeenItem),
                      leading: Icon(AppIcons.history),
                      onTap: gotoLastSeenPage,
                      dense: true,
                    ),

                    Visibility(
                      visible: !kIsWeb,
                      child: ListTile(
                        title: Text(AppMessages.shareApp),
                        leading: Icon(AppIcons.share),
                        onTap: shareAppCall,
                        dense: true,
                      ),
                    ),

                    ListTile(
                      title: Text(AppMessages.sentencesTitle),
                      leading: Icon(AppIcons.report2),
                      onTap: gotoSentencePage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.aidUs),
                      leading: Icon(AppIcons.cashMultiple),
                      onTap: gotoAidPage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.contactUs),
                      leading: Icon(AppIcons.message),
                      onTap: gotoContactUsPage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.aboutUs),
                      leading: Icon(AppIcons.infoCircle),
                      onTap: gotoAboutUsPage,
                      dense: true,
                    ),

                    Builder(
                      builder: (context) {
                        if(VersionManager.existNewVersion){
                          return Column(
                            children: [
                              ColoredBox(
                                color: Colors.cyan.withAlpha(80),
                                child: ListTile(
                                  title: Text(AppMessages.downloadNewVersion),
                                  leading: Icon(AppIcons.downloadFile),
                                  onTap: downloadNewVersion,
                                  dense: true,
                                ),
                              ),

                              SizedBox(height: 50),
                            ],
                          );
                        }

                        return SizedBox();
                      },

                    ),
                  ],
                ),
              ),
            ),

            ColoredBox(
              color: Colors.amberAccent.shade200,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
                    child: Text('نسخه ی ${Constants.appVersionName}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProfileSection(){
    if(SessionService.hasAnyLogin()){
      final user = SessionService.getLastLoginUser()!;

      return GestureDetector(
        onTap: gotoProfilePage,
        child: Column(
          children: [
            StreamBuilder(
              stream: EventNotifierService.getStream(AppEvents.userProfileChange),
              builder: (ctx, data) {
                return Builder(
                  builder: (ctx){
                    if(user.profileModel?.url != null){
                      if(kIsWeb){
                        return CircleAvatar(
                          backgroundImage: NetworkImage(user.profileModel!.url!),
                          radius: 30,
                        );
                      }
                      else {
                        final path = AppDirectories.getSavePathUri(user.profileModel!.url ?? '', SavePathType.userProfile, user.avatarFileName);
                        final img = FileHelper.getFile(path);

                        if (img.existsSync()) {
                          if (user.profileModel!.volume == null || img.lengthSync() == user.profileModel!.volume) {
                            return CircleAvatar(
                              backgroundImage: FileImage(File(img.path)),
                              radius: 30,
                            );
                          }
                        }
                      }
                    }

                    checkAvatar(user);
                    return CircleAvatar(
                      backgroundColor: ColorHelper.textToColor(user.nameFamily),
                      radius: 30,
                      child: Image.asset(AppImages.appIcon),
                    );
                  },
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
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    ShareExtend.share('https://cafebazaar.ir/app/ir.vosatezehn.com', 'text');
  }

  static void gotoFavoritesPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, FavoritesPage());
  }

  static void gotoLastSeenPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, LastSeenPage());
  }

  static void gotoAidPage(){
    AidService.gotoAidPage();
  }

  static void gotoContactUsPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, ContactUsPage());
  }

  static void gotoSentencePage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, SentencesPage());
  }

  static void gotoAboutUsPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, AboutUsPage());
  }

  static void downloadNewVersion(){
    VersionManager.showUpdateDialog(RouteTools.getBaseContext()!, VersionManager.newVersionModel!);
  }

  static void gotoProfilePage(){
    if(SessionService.isGuestCurrent()){
      return;
    }

    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, ProfilePage());
  }

  static void onLogoffCall(){
    if(SessionService.isGuestCurrent()){
      LoginService.forceLogoff(SessionService.getLastLoginUser()!.userId);
      return;
    }

    void yesFn(){
      //RouteTools.popTopView();
      LoginService.forceLogoff(SessionService.getLastLoginUser()!.userId);
    }

    AppDialogIris.instance.showYesNoDialog(
      RouteTools.getTopContext()!,
      desc: AppMessages.doYouWantLogoutYourAccount,
      dismissOnButtons: true,
      yesText: AppMessages.yes,
      noText: AppMessages.no,
      yesFn: yesFn,
      decoration: AppDialogIris.instance.dialogDecoration.copy()..positiveButtonBackColor = Colors.green,
    );
  }

  static void checkAvatar(UserModel user) async {
    if(user.profileModel?.url == null || kIsWeb){
      return;
    }

    final path = AppDirectories.getSavePathUri(user.profileModel!.url!, SavePathType.userProfile, user.avatarFileName);
    final img = FileHelper.getFile(path);

    if(img.existsSync()) {
      if (user.profileModel!.volume == null || img.existsSync() && img.lengthSync() == user.profileModel!.volume) {
        return;
      }
    }

    final dItm = DownloadUploadService.downloadManager.createDownloadItem(user.profileModel!.url!, tag: '${user.profileModel!.id!}');
    dItm.savePath = path;
    dItm.category = DownloadCategory.userProfile;

    DownloadUploadService.downloadManager.enqueue(dItm);
  }
}
