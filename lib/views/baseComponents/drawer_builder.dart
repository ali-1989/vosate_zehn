import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/updater_state.dart';
import 'package:share_extend/share_extend.dart';

import 'package:app/managers/version_manager.dart';
import 'package:app/services/aid_service.dart';
import 'package:app/services/download_upload_service.dart';
import 'package:app/services/login_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/system/constants.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/pages/about_us_page.dart';
import 'package:app/views/pages/contact_us_page.dart';
import 'package:app/views/pages/favorites_page.dart';
import 'package:app/views/pages/last_seen_page.dart';
import 'package:app/views/pages/profile/profile_page.dart';
import 'package:app/views/pages/sentences_page.dart';

class DrawerMenuBuilder {
  DrawerMenuBuilder._();

  //static Widget? _drawer;

  static void openDrawer(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.openDrawer();
  }

  static void closeDrawer(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
  }

  static void toggleDrawer(){
    if(drawerIsOpen()){
      closeDrawer();
    }
    else {
      openDrawer();
    }
  }

  static bool drawerIsOpen(){
    return AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.isDrawerOpen?? false;
  }

  static Widget getDrawer(){
    return UpdaterBuilder(
      id: AppBroadcast.drawerMenuRefresherId,
      builder: (ctx, ctr, data){
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
                    textTheme: const TextTheme(bodyLarge: TextStyle(fontSize: 10, color: Colors.black))
                ),
                child: ListView(
                  children: [
                    const SizedBox(height: 32),

                    _buildProfileSection(),

                    const SizedBox(height: 10),

                    if(SessionService.hasAnyLogin())
                      ListTile(
                        title: Text(SessionService.isGuestCurrent()? AppMessages.registerTitle :AppMessages.account).color(Colors.green),
                        leading: const Icon(AppIcons.personLogin, size: 18, color: Colors.green),
                        onTap: SessionService.isGuestCurrent()? onLogoffCall : gotoProfilePage,
                        dense: true,
                      ),

                    ListTile(
                      title: Text(AppMessages.favorites),
                      leading: const Icon(AppIcons.heart),
                      onTap: gotoFavoritesPage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.lastSeenItem),
                      leading: const Icon(AppIcons.history),
                      onTap: gotoLastSeenPage,
                      dense: true,
                    ),

                    Visibility(
                      visible: !kIsWeb,
                      child: ListTile(
                        title: Text(AppMessages.shareApp),
                        leading: const Icon(AppIcons.share),
                        onTap: shareAppCall,
                        dense: true,
                      ),
                    ),

                    ListTile(
                      title: Text(AppMessages.sentencesTitle),
                      leading: const Icon(AppIcons.report2),
                      onTap: gotoSentencePage,
                      dense: true,
                    ),

                    /*ListTile(
                      title: Text(AppMessages.aidUs),
                      leading: const Icon(AppIcons.cashMultiple),
                      onTap: gotoAidPage,
                      dense: true,
                    ),*/

                    ListTile(
                      title: Text(AppMessages.contactUs),
                      leading: const Icon(AppIcons.message),
                      onTap: gotoContactUsPage,
                      dense: true,
                    ),

                    ListTile(
                      title: Text(AppMessages.aboutUs),
                      leading: const Icon(AppIcons.alertCircle),
                      onTap: gotoAboutUsPage,
                      dense: true,
                    ),

                    if(SessionService.hasAnyLogin())
                      ListTile(
                        title: Text(AppMessages.logout).color(Colors.redAccent),
                        leading: const Icon(AppIcons.logout, size: 18, color: Colors.redAccent),
                        onTap: onLogoffCall,
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
                                  leading: const Icon(AppIcons.downloadFile),
                                  onTap: downloadNewVersion,
                                  dense: true,
                                ),
                              ),

                              const SizedBox(height: 50),
                            ],
                          );
                        }

                        return const SizedBox();
                      },

                    ),
                  ],
                ),
              ),
            ),

            ColoredBox(
              color: AppDecoration.mainColor,
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
              stream: EventNotifierService.getStream(AppEvents.userPersonalInfoChange),
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

            const SizedBox(height: 8,),
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
    RouteTools.pushPage(RouteTools.getTopContext()!, const FavoritesPage());
  }

  static void gotoLastSeenPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const LastSeenPage());
  }

  static void gotoAidPage(){
    AidService.gotoAidPage();
  }

  static void gotoContactUsPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const ContactUsPage());
  }

  static void gotoSentencePage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const SentencesPage());
  }

  static void gotoAboutUsPage(){
    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const AboutUsPage());
  }

  static void downloadNewVersion(){
    VersionManager.showUpdateDialog(RouteTools.getBaseContext()!, VersionManager.newVersionModel!);
  }

  static void gotoProfilePage(){
    if(SessionService.isGuestCurrent()){
      return;
    }

    AppBroadcast.layoutPageKey.currentState?.scaffoldState.currentState?.closeDrawer();
    RouteTools.pushPage(RouteTools.getTopContext()!, const ProfilePage());
  }

  static void onLogoffCall(){
    if(SessionService.isGuestCurrent()){
      LoginService.forceLogoff(userId: SessionService.getLastLoginUser()!.userId);
      return;
    }

    void yesFn(_){
      //RouteTools.popTopView();
      LoginService.forceLogoff(userId: SessionService.getLastLoginUser()!.userId);
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
//AssistController.forId(AppBroadcast.drawerMenuRefresherId)?.update();
