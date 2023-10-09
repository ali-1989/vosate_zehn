import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:app/structures/enums/enums.dart';
import 'package:app/tools/permission_tools.dart';

class AppDirectories {
  AppDirectories._();

  static String _externalStorage = '/';
  static String _internalStorage = '/';
  static String _documentDir = '/';
  static String _appName = 'app';

  static String? getPathForType(SavePathType type){
    if(type == SavePathType.userProfile){
      return getAvatarDir$ex();
    }

    if(type == SavePathType.anyOnInternal){
      return '${getAppFolderInInternalStorage()}${PathHelper.getSeparator()}myFiles';
    }

    return null;
  }

  static String? getSavePathUri(String? uri, SavePathType type, String? newName){
    if(uri == null){
      return null;
    }

    final pat = getPathForType(type);

    if(pat == null) {
      return null;
    }

    final fName = newName?? PathHelper.getFileName(uri);
    return PathHelper.resolvePath(pat + PathHelper.getSeparator() + fName);
  }

  static String? getSavePathMedia(MediaModel? media, SavePathType type, String? newName){
    if(media == null){
      return null;
    }

    final pat = getPathForType(type);

    if(pat == null) {
      return null;
    }

    var fName = newName;

    if(fName == null) {
      if (media.id != null) {
        fName = '${media.id}';
      }
      else {
        fName = PathHelper.getFileName(media.url!);
      }
    }

    return PathHelper.resolvePath(pat + PathHelper.getSeparator() + fName);
  }

  static String? getSavePathByPath(SavePathType type, String? filepath){
    final pat = getPathForType(type);

    if(pat == null) {
      return null;
    }

    var fName = Generator.generateDateMillWithKey(14);
    final ext = FileHelper.getDotExtension(filepath?? '');
    fName += ext;

    return pat + PathHelper.getSeparator() + fName;
  }

  ///-----------------------------------------------------------------------------------------
  static Future<String> prepareStoragePaths(String appName) async {
    _appName = appName;

    if (kIsWeb) {
      _externalStorage = StorageHelper.getWebExternalStorage();
      _internalStorage = _externalStorage;
      _documentDir = PathHelper.resolvePath('$_externalStorage/Documents/$_appName')!;

    } else {
      _externalStorage = '/';

      if (Platform.isAndroid) {
        _externalStorage = (await StorageHelper.getAndroidExternalStorage())!;
        _internalStorage = (await StorageHelper.getAndroidFilesDir$internal()).path;
      }
      else if (Platform.isIOS) {
        _externalStorage = (await StorageHelper.getIosApplicationSupportDir()).path;
        _internalStorage = _externalStorage;
      }

      final p = await StorageHelper.getDocumentsDirectory$external();
      _documentDir = p + PathHelper.getSeparator() + _appName;
  }


    return _externalStorage;
  }

  static String getExternalStorage() {
    return _externalStorage;
  }

  static String getInternalAppStorage() {
    return _internalStorage;
  }

  // android: /storage/emulated/0/Documents/appName
  // iOS:
  static String getDocumentsDirectory() {
    return _documentDir;
  }

  static String getExternalAppFolder() {
    if(System.isWeb()) {
      return '/$_appName';
    }

    return _externalStorage + PathHelper.getSeparator() + _appName;
  }

  static String getAppFolderInInternalStorage() {
    if(System.isWeb()) {
      return '/$_appName';
    }

    return _internalStorage;
  }

  static Future<String> getDatabasesDir() async {
    if(System.isWeb()) {
      return PathHelper.resolvePath('${StorageHelper.getWebExternalStorage()}${PathHelper.getSeparator()}database')!;
    }

    if(System.isAndroid()) {
      return '${(await StorageHelper.getAppDirectory$internal()).path}${PathHelper.getSeparator()}database';
    }

    if(System.isIOS()) {
      return '${(await StorageHelper.getAppDirectory$internal()).path}${PathHelper.getSeparator()}database';
    }

    return '${StorageHelper.getWebExternalStorage()}${PathHelper.getSeparator()}database';
  }

  static String getTempFile({String? name, String? extension}){
    name ??= Generator.generateDateMillWithKey(4);

    if(extension != null) {
      return '${getExternalTempDir()}${PathHelper.getSeparator()}$name.$extension';
    } else {
      return getExternalTempDir()+ PathHelper.getSeparator() + name;
    }
  }

  static String getScreenshotFile({String? name, String? extension}){
    name ??= Generator.generateDateMillWithKey(4);

    if(extension != null) {
      return '${getVideoDir$ex()}${PathHelper.getSeparator()}$name.$extension';
    } else {
      return getVideoDir$ex()+ PathHelper.getSeparator() + name;
    }
  }
  ///================================================================================================
  // /storage/emulated/0/appName/tmp
  static String getExternalTempDir(){
    return '${getExternalAppFolder()}${PathHelper.getSeparator()}tmp';
  }

  static String getAvatarDir$ex() {
    return '${getAppFolderInInternalStorage()}${PathHelper.getSeparator()}avatar';
  }

  static String getAdvertisingDir$ex(){
    return '${getAppFolderInInternalStorage()}${PathHelper.getSeparator()}advertising';
  }

  static String getMediaDir$ex() {
    return '${getExternalAppFolder()}${PathHelper.getSeparator()}media';
  }

  static String getAudioDir$ex() {
    return '${getMediaDir$ex()}${PathHelper.getSeparator()}audio';
  }

  static String getVideoDir$ex() {
    return '${getMediaDir$ex()}${PathHelper.getSeparator()}video';
  }

  static String getImageDir$ex() {
    return '${getMediaDir$ex()}${PathHelper.getSeparator()}image';
  }

  static String getDocDir$ex() {
    return '${getMediaDir$ex()}${PathHelper.getSeparator()}document';
  }

  static Future<bool> generateNoMediaFile() async {
    if(System.isWeb()) {
      return true;
    }

    final res = await PermissionTools.requestStoragePermissionWithOsVersion();

    if(res != PermissionStatus.granted) {
      return false;
    }

    final tmpDir = getExternalTempDir();
    var f = FileHelper.getFile('$tmpDir${PathHelper.getSeparator()}.nomedia');
    await f.create(recursive: true);

    final avatarDir = getAvatarDir$ex();
    f = FileHelper.getFile('$avatarDir${PathHelper.getSeparator()}.nomedia');
    await f.create(recursive: true);

    final advertisingDir = getAdvertisingDir$ex();
    f = FileHelper.getFile('$advertisingDir${PathHelper.getSeparator()}.nomedia');
    await f.create(recursive: true);

    final contentDir = getMediaDir$ex();
    f = FileHelper.getFile('$contentDir${PathHelper.getSeparator()}.nomedia');
    await f.create(recursive: true);

    return true;
  }
}
