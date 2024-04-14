import 'dart:async';
import 'dart:io';

import 'package:app/tools/app/app_decoration.dart';
import 'package:app/views/pages/profile/buy_vip_plan_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:glowstone/glowstone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_pic_editor/picEditor/models/edit_options.dart';
import 'package:iris_pic_editor/picEditor/picEditor.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_overlay.dart';
import 'package:app/tools/app/app_sheet.dart';
import 'package:app/tools/app/app_sizes.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/device_info_tools.dart';
import 'package:app/tools/permission_tools.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/components/changeNameFamilyView.dart';
import 'package:app/views/components/dateComponents/selectDateCalendarView.dart';
import 'package:app/views/components/selectGenderView.dart';

class ProfilePage extends StatefulWidget{

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
///=============================================================================
class _ProfilePageState extends StateSuper<ProfilePage> {
  Requester requester = Requester();
  UserModel user = SessionService.getLastLoginUser()!;

  @override
  void initState(){
    super.initState();

    requestProfileData();
    //addPostOrCall(fn: checkPermission);
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
        /// background
        SizedBox.expand(
            child: Image.asset(AppImages.background,
              fit: BoxFit.fill,
            )
        ),

        /// background
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
                    height: kIsWeb? 150: 120,
                    child: Card(
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Transform.translate(
                            offset: const Offset(40, 0),
                            child: StreamBuilder(
                                stream: EventNotifierService.getStream(AppEvents.userPersonalInfoChange),
                                builder: (ctx, data) {
                                  if(user.profileModel?.url == null){
                                    return ColoredBox(color: AppThemes.instance.currentTheme.accentColor);
                                  }

                                  if(kIsWeb){
                                    return CircleAvatar(
                                      backgroundImage: NetworkImage(user.profileModel!.url!),
                                      radius: 75,
                                    );
                                  }
                                  else {
                                    final path = AppDirectories.getSavePathUri(user.profileModel!.url?? '', SavePathType.userProfile, user.avatarFileName);
                                    final img = FileHelper.getFile(path);

                                    if(img.existsSync()) {
                                      if (user.profileModel!.volume == null || img.lengthSync() == user.profileModel!.volume) {
                                        return ClipPath(
                                          clipper: OctagonalClipper(),
                                          child: SizedBox(
                                            height: 120,
                                            width: 120,
                                            child: Image.file(img, width:  120, height: 120, fit: BoxFit.fill),
                                          ),
                                        );
                                      }
                                    }
                                  }

                                  return ColoredBox(color: AppThemes.instance.currentTheme.accentColor);
                              }
                            ),
                          ),

                          Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8,),
                                      Text(user.nameFamily, maxLines: 1,).bold().fsR(5),
                                      const SizedBox(height: 10,),
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
                                            backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                            shape: const CircleBorder(),
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                            onPressed: changeAvatarClick,
                                            child: const Icon(AppIcons.picture, size: 15)
                                        ),

                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                              shape: const CircleBorder(),
                                              padding: EdgeInsets.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            onPressed: changeNameFamilyClick,
                                            child: const Icon(AppIcons.edit, size: 15)
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

                const SizedBox(height: 80,),

                FlipInX(
                  delay: const Duration(milliseconds: 500),
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
                                Text('${AppMessages.email}:  ').color(Colors.white),
                                Flexible(child: Text(user.email??'', maxLines: 1,).color(Colors.white).bold()),
                              ],
                            ),

                          const SizedBox(height: 8),
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

                          const SizedBox(height: 8),
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
                          ),

                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${AppMessages.vipType}:').color(Colors.white),

                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: onBuyVipPlan,
                                    child: const Icon(AppIcons.buyBasket, color: AppDecoration.differentColor),
                                  ),

                                  const SizedBox(width: 6),
                                  ActionChip(
                                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                                    label: Text(user.vipOptions.isVip()? AppMessages.vipUser: AppMessages.normalUser).color(Colors.white),
                                    onPressed: onBuyVipPlan,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Visibility(
                            visible: user.vipOptions.isVip(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${AppMessages.savedVtiTime}:').color(Colors.white),
                                  Text(user.vipOptions.getHumanVipTime()).color(Colors.white),
                                ],
                              )
                          ),

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
    await AppSheet.showSheetCustom(
        context,
        builder: (_){
          return SelectDateCalendarView(
            minYearAsGregorian: 1922,
            maxYearAsGregorian: 2020,
            title: 'تاریخ تولد',
            currentDate: user.birthDate,
            onSelect: (dt){
              RouteTools.popTopView(context: context);
              uploadBirthdate(dt);
            },
          );
        },
        routeName: 'changeBirthdate'
    );
  }

  void changeGenderClick() async {
    await AppSheet.showSheetCustom(
        context,
        builder: (_){
          return SelectGenderView(
            title: 'جنسیت',
            genderType: user.sex == 1? GenderType.man: (user.sex == 2 ? GenderType.woman: GenderType.other),
            onSelect: (gender){
              RouteTools.popTopView(context: context);
              uploadGender(gender == GenderType.man? 1: 2);
            },
          );
        },
        routeName: 'changeGender',
    );
  }

  void changeNameFamilyClick() async {
    final inject = ChangeNameFamilyViewInjection();
    inject.nameHint = 'نام';
    inject.familyHint = 'فامیلی';
    inject.name = user.name;
    inject.family = user.family;
    inject.pageTitle = 'تغییر نام';

    inject.onButton = (name, family){
      if(name.isEmpty){
        AppSnack.showInfo(context, AppMessages.enterName);
        return;
      }

      if(family.isEmpty){
        AppSnack.showInfo(context, AppMessages.enterFamily);
        return;
      }

      FocusHelper.hideKeyboardByUnFocusRoot();
      uploadName(name, family);
    };

    final body = ChangeNameFamilyView(
      injection: inject,
    );

    final view = OverlayScreenView(content: body);

    AppOverlay.showDialogScreen(context, view, canBack: true);
  }

  void changeAvatarClick() async {
    List<Widget> widgets = [];

    if(!kIsWeb) {
      final v = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onSelectProfile(1);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(AppIcons.camera, size: 20),
              const SizedBox(width: 12),
              const Text('دوربین').bold(),
            ],
          ),
        ),
      );

      widgets.add(v);
    }

    widgets.add(
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            onSelectProfile(2);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(AppIcons.picture, size:20),
                const SizedBox(width: 12),
                const Text('گالری').bold(),
              ],
            ),
          ),
        ));

    if(user.profileModel != null){
      widgets.add(
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: deleteProfile,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(AppIcons.delete, size: 20),
                  const SizedBox(width: 12),
                  const Text('حذف').bold(),
                ],
              ),
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
    AppSheet.closeSheet(context);

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
      uploadAvatar(path);
    }
  }

  Future<XFile?> selectImageFromCamera() async {
    final hasPermission = await PermissionTools.requestCameraPermission();

    if(hasPermission != PermissionStatus.granted) {
      AppToast.showToast(context, 'لطفا مجوز استفاده از دوربین را فعال کنید');
      PermissionTools.requestCameraPermission().then((value) {
        if(value == PermissionStatus.granted){
          return selectImageFromCamera();
        }
      });

      return null;
    }

    final pick = await ImagePicker().pickImage(source: ImageSource.camera);

    if(pick == null) {
      return null;
    }

    return pick;
  }

  Future<XFile?> selectImageFromGallery() async {
    final hasPermission = await PermissionTools.requestStoragePermissionWithOsVersion();

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

    final editOptions = EditOptions.byFile(imgPath);
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

  void afterUploadAvatar(String imgPath, Map map) async {
    final String? url = map[Keys.url];

    if(url == null){
      return;
    }

    user.profileModel = MediaModel()..url = url.. id = Generator.generateIntId(5);

    if(kIsWeb){
      await SessionService.sinkUserInfo(user);
      EventNotifierService.notify(AppEvents.userPersonalInfoChange);
      return;
    }

    final path = AppDirectories.getSavePathUri(url, SavePathType.userProfile, user.avatarFileName);
    final f = FileHelper.renameSyncSafe(imgPath, path!);

    user.profileModel!.path = f.path;

    hideLoading();
    AppSnack.showSnack(context, Text(AppMessages.operationSuccess));

    await SessionService.sinkUserInfo(user);
    EventNotifierService.notify(AppEvents.userPersonalInfoChange);
  }

  void uploadAvatar(String filePath) {
    const partName = 'ProfileAvatar';
    final fileName = PathHelper.getFileName(filePath);

    final js = <String, dynamic>{};
    js[Keys.request] = 'Update_profile_avatar';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.fileName] = fileName;
    js[Keys.partName] = partName;
    DeviceInfoTools.attachDeviceAndTokenInfo(js);

    requester.httpRequestEvents.onFailState = (req, r) async {
      await hideLoading();
      AppSnack.showSnack(context, Text(AppMessages.errorCommunicatingServer));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      afterUploadAvatar(filePath, data);
    };

    requester.prepareUrl();
    requester.bodyJson = null;
    requester.httpItem.clearFormField();
    requester.httpItem.addFormField(Keys.jsonPart, JsonHelper.mapToJson(js));
    requester.httpItem.addFormFile(partName, fileName, File(filePath));

    showLoading(canBack: false);
    requester.request();
  }

  void deleteProfile(){
    AppSheet.closeSheet(context);

    final js = <String, dynamic>{};
    js[Keys.request] = 'delete_profile_avatar';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnack(context, Text(AppMessages.operationFailed));

    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.profileModel = null;

      EventNotifierService.notify(AppEvents.userPersonalInfoChange);
      SessionService.sinkUserInfo(user);
    };

    showLoading();
    requester.bodyJson = js;
    requester.prepareUrl();

    requester.request();
  }
  
  void uploadName(String name, String family){
    final js = <String, dynamic>{};
    js[Keys.request] = 'update_user_nameFamily';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.name] = name;
    js[Keys.family] = family;

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnack(context, Text(AppMessages.operationFailed));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.name = name;
      user.family = family;

      assistCtr.updateHead();
      await SessionService.sinkUserInfo(user);
      AppOverlay.hideDialog(context);
      EventNotifierService.notify(AppEvents.userPersonalInfoChange);
    };

    showLoading(canBack: false);
    requester.bodyJson = js;
    requester.prepareUrl();

    requester.request();
  }

  void uploadGender(int gender){
    final js = <String, dynamic>{};
    js[Keys.request] = 'update_user_gender';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.sex] = gender;

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnack(context, Text(AppMessages.operationFailed));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.sex = gender;

      assistCtr.updateHead();
      await SessionService.sinkUserInfo(user);
      EventNotifierService.notify(AppEvents.userPersonalInfoChange);
    };

    showLoading(canBack: false);
    requester.bodyJson = js;
    requester.prepareUrl();

    requester.request();
  }

  void uploadBirthdate(DateTime dt){
    final js = <String, dynamic>{};
    js[Keys.request] = 'update_user_birthdate';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.date] = DateHelper.toTimestamp(dt);

    requester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    requester.httpRequestEvents.onFailState = (req, r) async {
      AppSnack.showSnack(context, Text(AppMessages.operationFailed));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      user.birthDate = dt;

      assistCtr.updateHead();
      await SessionService.sinkUserInfo(user);
      EventNotifierService.notify(AppEvents.userPersonalInfoChange);
    };

    showLoading(canBack: false);
    requester.bodyJson = js;
    requester.prepareUrl();

    requester.request();
  }

  void requestProfileData() async {
    final user = SessionService.getLastLoginUser();

    if(user == null || user.userId == '0'){
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'get_profile_data';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = js[Keys.requesterId];


    requester.httpRequestEvents.onFailState = (req, r) async {
      AppToast.showToast(context, AppMessages.errorCommunicatingServer);
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      await SessionService.newProfileData(data as Map<String, dynamic>);

      assistCtr.updateHead();
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();
  }

  void checkPermission() async {
    if(user.profileModel != null && user.profileModel!.url != null){
      final hasPermission = await PermissionTools.isGrantedStoragePermission();

      if(!hasPermission) {
        final graPermission = await PermissionTools.requestStoragePermissionWithOsVersion();

        if(graPermission == PermissionStatus.granted){
          assistCtr.updateHead();
        }
      }
    }
  }

  void onBuyVipPlan() async {
    final res = await RouteTools.pushPage(context, const BuyVipPlanPage());

    if(res is bool && res){
      assistCtr.updateHead();
    }
  }
}
