import 'dart:async';
import 'dart:io';

import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appOverlay.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/permissionTools.dart';
import 'package:app/views/changeNameFamilyView.dart';
import 'package:app/views/dateViews/selectDateCalendarView.dart';
import 'package:app/views/selectGenderView.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:glowstone/glowstone.dart';
import 'package:go_router/go_router.dart';
import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/modules/stateManagers/notifyRefresh.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/userModel.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/system/requester.dart';
import 'package:app/system/session.dart';
import 'package:app/tools/app/appBroadcast.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSizes.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:permission_handler/permission_handler.dart';

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
                                            onPressed: changeAvatarClick,
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
                                            onPressed: changeNameFamilyClick,
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
                                  onPressed: changeBirthdateClick,
                              ),
                            ],
                          ),

                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppMessages.gender}:').color(Colors.white),
                              ActionChip(
                                  backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                  label: Text(user.sex == 1? AppMessages.man: AppMessages.woman).color(Colors.white),
                                  onPressed: changeGenderClick,
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

  void changeBirthdateClick() async {
    final newDate = await AppSheet.showSheetCustom(
        context,
        SelectDateCalendarView(
          minYearAsGregorian: 1922,
          maxYearAsGregorian: 2020,
          title: 'تاریخ تولد',
          currentDate: user.birthDate,
        ),
        routeName: 'changeBirthdate'
    );

    print('hhhhhhhhhhhh $newDate');
  }

  void changeGenderClick() async {
    final sex = await AppSheet.showSheetCustom(
        context,
        SelectGenderView(
          title: 'جنسیت',
          genderType: user.sex == 1? GenderType.man: (user.sex == 2 ? GenderType.woman: GenderType.other),
        ),
        routeName: 'changeGender'
    );

    print('hhhhhhhhhhhh $sex');
  }

  void changeNameFamilyClick() async {
    final inject = ChangeNameFamilyViewInjection();
    inject.nameHint = 'نام';
    inject.familyHint = 'فامیلی';
    inject.onButton = (name, family){
      print('name: $name');
      AppNavigator.pop(context);
    };

    final body = ChangeNameFamilyView(
      injection: inject,
    );

    final view = OverlayScreenView(content: body);

    AppOverlay.showScreen(context, view);
  }

  void changeAvatarClick() async {
    List<Widget> widgets = [];
    widgets.add(
        GestureDetector(
          onTap: (){
            onSelectProfile(1);
          },
          child: Row(
            children: [
              Icon(AppIcons.camera),
              Text('دوربین'),
            ],
    ),
        ));

    widgets.add(
        GestureDetector(
          onTap: (){
            onSelectProfile(2);
          },
          child: Row(
            children: [
              Icon(AppIcons.picture),
              Text('گالری'),
            ],
          ),
        ));

    if(user.profileModel != null){
      widgets.add(
          GestureDetector(
            onTap: deleteProfile,
            child: Row(
              children: [
                Icon(AppIcons.delete),
                Text('حذف'),
              ],
            ),
          ));
    }

    AppSheet.showSheetMenu(
        context,
        widgets,
        'changeAvatar',
    );
  }

  void onSelectProfile(int state) async {
    XFile? image;

    if(state == 1){
      image = await selectImageFromCamera();
    }
    else {
      image = await selectImageFromGallery();
    }

    if(image == null){
      return;
    }

    String? path = await editImage(image.path);

    if(path != null){

    }
  }

  Future<XFile?> selectImageFromCamera() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.camera);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<XFile?> selectImageFromGallery() async {
    final hasPermission = await PermissionTools.requestStoragePermission();

    if(hasPermission != PermissionStatus.granted) {
      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<String?> editImage(String imgPath) async {
    final comp = Completer<String?>();

    final editOptions = EditOptions.byPath(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = AppDirectories.getSavePathByPath(SavePathType.userProfile, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      comp.complete(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(context, ov).then((value){
      if(!comp.isCompleted){
        comp.complete(null/*imgPath*/);
      }
    });

    return comp.future;
  }

  void afterUploadAvatar(String imgPath, Map map){
    final String? url = map[Keys.url];

    if(url == null){
      return;
    }

    final newName = PathHelper.getFileName(url);
    final newFileAddress = PathHelper.getParentDirPath(imgPath) + PathHelper.getSeparator() + newName;

    final f = FileHelper.renameSyncSafe(imgPath, newFileAddress);

    user.profileModel = MediaModel()..url = url..path = f.path;

    hideLoading();
    assistCtr.updateMain();
    Session.sinkUserInfo(user);

    //after load image, auto will call: OverlayCenter().hideLoading(context);
    AppSnack.showSnack$operationSuccess(context);
  }

  void uploadAvatar(String filePath) {
    final partName = 'ProfileAvatar';
    final fileName = PathHelper.getFileName(filePath);

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'UpdateProfileAvatar';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.fileName] = fileName;
    js[Keys.partName] = partName;
    PublicAccess.addAppInfo(js);

    requester.httpRequestEvents.onFailState = (req) async {
      await hideLoading();
      AppSnack.showSnack$errorCommunicatingServer(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      afterUploadAvatar(filePath, data);
    };

    requester.prepareUrl();
    requester.bodyJson = null;
    requester.httpItem.addBodyField(Keys.jsonPart, JsonHelper.mapToJson(js));
    requester.httpItem.addBodyFile(partName, fileName, File(filePath));

    showLoading(canBack: false);
    requester.request(context, false);
  }

  void deleteProfile(){
    //OverlayDialog().hideByName(context, 'MenuForProfileAvatar');

    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'DeleteProfileAvatar';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req) async {
      AppSnack.showSnack$OperationFailed(context);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.profileModel = null;

      assistCtr.updateMain();
    };

    showLoading(canBack: false);
    requester.bodyJson = js;
    requester.prepareUrl();

    requester.request(context, false);
  }
  
  void requestProfileData() async {
    final js = <String, dynamic>{};
    js[Keys.requestZone] = 'get_profile_data';
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.forUserId] = js[Keys.requesterId];


    requester.httpRequestEvents.onFailState = (req) async {
      AppToast.showToast(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      await Session.newProfileData(data as Map<String, dynamic>);

      assistCtr.updateMain();
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request(context);
  }
}
