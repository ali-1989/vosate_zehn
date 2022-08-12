import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:glowstone/glowstone.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:vosate_zehn/models/userModel.dart';
import 'package:vosate_zehn/system/enums.dart';
import 'package:vosate_zehn/system/keys.dart';
import 'package:vosate_zehn/system/requester.dart';
import 'package:vosate_zehn/system/session.dart';

import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/tools/app/appBroadcast.dart';
import 'package:vosate_zehn/tools/app/appDirectories.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appImages.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appSizes.dart';
import 'package:vosate_zehn/tools/app/appThemes.dart';
import 'package:vosate_zehn/tools/app/appToast.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';

class ProfilePage extends StatefulWidget {
  static final route = GoRoute(
    path: '/profile',
    name: (ProfilePage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => ProfilePage(),
  );

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
///==================================================================================
class _ProfilePageState extends StateBase<ProfilePage> {
  Requester requester = Requester();
  UserModel user = Session.getLastLoginUser()!;

  @override
  void initState(){
    super.initState();

    requestProfileData();
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
            //extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBarCustom(
              title: Text(AppMessages.profileTitle),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    return Stack(
      children: [
        SizedBox.expand(
            child: Image.asset(AppImages.background,
              fit: BoxFit.fill,
            )
        ),

        Positioned(
          top: MathHelper.percent(AppSizes.instance.appHeight, 25),
            left: MathHelper.percent(AppSizes.instance.appWidth, 10),
            right: MathHelper.percent(AppSizes.instance.appWidth, 16),
            child: Column(
              children: [
                Glowstone(
                  radius: 20,
                  velocity: 3,
                  //color: ColorHelper.textToColor(user.nameFamily),
                  color: AppThemes.instance.currentTheme.accentColor,
                  child: SizedBox(
                    height: 120,
                    child: Card(
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: Offset(40, 0),
                            child: ClipPath(
                              clipper: OctagonalClipper(),
                              child: SizedBox(
                                height: 120,
                                width: 120,
                                child: NotifyRefresh(
                                  notifier: AppBroadcast.avatarNotifier,
                                  builder: (ctx, data) {
                                    return Builder(
                                      builder: (ctx){
                                        if(user.profileModel != null){
                                          final path = AppDirectories.getSavePathUri(user.profileModel!.url?? '', SavePathType.userProfile, user.avatarFileName);
                                          final img = FileHelper.getFile(path);

                                          if(img.existsSync() && img.lengthSync() == user.profileModel!.volume!){
                                            return Image.file(img);
                                          }
                                        }

                                        //checkAvatar(user);
                                        //return ColoredBox(color: ColorHelper.textToColor(user.nameFamily,));
                                        return ColoredBox(color: AppThemes.instance.currentTheme.accentColor);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 8,),
                                      Text(user.nameFamily, maxLines: 1,).bold().fsR(5),
                                      SizedBox(height: 10,),
                                      Text('${user.userId}_${user.userName}', maxLines: 1,).fsR(-2).alpha(),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: AppThemes.instance.currentTheme.differentColor,
                                            shape: CircleBorder(),
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                            onPressed: (){},
                                            child: Icon(AppIcons.picture, size: 15)
                                        ),

                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: AppThemes.instance.currentTheme.differentColor,
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            onPressed: (){},
                                            child: Icon(AppIcons.edit, size: 15,)
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 80,),

                FlipInX(
                  delay: Duration(milliseconds: 500),
                  child: Card(
                    //color: ColorHelper.textToColor(user.nameFamily,),
                    color: AppThemes.instance.currentTheme.accentColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
                      child: Column(
                        textDirection: TextDirection.ltr,
                        children: [
                          if(user.mobile != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${AppMessages.mobile}:').color(Colors.white),
                                Text(user.mobile??'').color(Colors.white).bold(),
                              ],
                            ),

                          if(user.email != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${AppMessages.email}:').color(Colors.white),
                                Text(user.email??'').color(Colors.white).bold(),
                              ],
                            ),

                          SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppMessages.age}:').color(Colors.white),
                              ActionChip(
                                backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                  label: Text('${DateHelper.calculateAge(user.birthDate)} سال').color(Colors.white),
                                  onPressed: (){}
                              ),
                            ],
                          ),

                          SizedBox(height: 15,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppMessages.gender}:').color(Colors.white),
                              ActionChip(
                                  backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                  label: Text(user.sex == 1? AppMessages.man: AppMessages.woman).color(Colors.white),
                                  onPressed: (){}
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  void requestProfileData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_profile_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.forUserId] = js[Keys.requesterId];

    requester.bodyJson = js;

    requester.httpRequestEvents.onFailState = (req) async {
      AppToast.showToast(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      await Session.newProfileData(data as Map<String, dynamic>);

      assistCtr.updateMain();
    };

    requester.prepareUrl();
    requester.request(context);
  }
}
