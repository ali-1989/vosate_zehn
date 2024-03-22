import 'package:flutter/material.dart';

import 'package:iris_tools/api/cache/memoryCache.dart';
import 'package:iris_tools/api/cache/timeoutCache.dart';

import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/route_tools.dart';

class AppCache {
  AppCache._();

  static late final ImageProvider? screenBack;
  static final MemoryCache appCache = MemoryCache();
  static final TimeoutCache timeoutCache = TimeoutCache();
  static final TimeoutCache downloadingCache = TimeoutCache();
  static final List<ImageProvider> backgroundList = [];

  //-------- Download ----------------------------------------------------------
  static void addStartToDownload(String tag){
    downloadingCache.addTimeout(tag, const Duration(seconds: 30));
  }

  static bool isDownloading(String tag){
    return downloadingCache.existTimeout(tag);
  }

  static void clearDownloading(){
    downloadingCache.clearAll();
  }

  static void removeDownloading(String tag){
    downloadingCache.deleteTimeout(tag);
  }

  static bool canCallMethodAgain(String key, {Duration dur = const Duration(seconds: 5)}){
    return AppCache.timeoutCache.addTimeout(key, dur);
  }

  static void preLoadImages() async {
    screenBack = const AssetImage(AppImages.background);
    await precacheImage(screenBack!, RouteTools.getBaseContext()!);

    const p1 = AssetImage(AppImages.back1);
    const p2 = AssetImage(AppImages.back2);
    const p3 = AssetImage(AppImages.back3);
    const p4 = AssetImage(AppImages.back4);
    const p5 = AssetImage(AppImages.back5);

    try {
      /*await*/ precacheImage(p1, RouteTools.getBaseContext()!);
      precacheImage(p2, RouteTools.getBaseContext()!);
      precacheImage(p3, RouteTools.getBaseContext()!);
      precacheImage(p4, RouteTools.getBaseContext()!);
      precacheImage(p5, RouteTools.getBaseContext()!);

      backgroundList.add(p1);
      backgroundList.add(p2);
      backgroundList.add(p3);
      backgroundList.add(p4);
      backgroundList.add(p4);
    }
    catch(e){/**/}
  }
}
