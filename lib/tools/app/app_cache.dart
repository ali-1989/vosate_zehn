import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/route_tools.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/cache/memoryCache.dart';
import 'package:iris_tools/api/cache/timeoutCache.dart';

class AppCache {
  AppCache._();

  static ImageProvider? screenBack;
  static MemoryCache appCache = MemoryCache();
  static TimeoutCache timeoutCache = TimeoutCache();
  static TimeoutCache downloadingCache = TimeoutCache();
  static List<ImageProvider> backgroundList = [];

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
    const p1 = AssetImage(AppImages.back1);
    const p2 = AssetImage(AppImages.back2);
    const p3 = AssetImage(AppImages.back3);
    const p4 = AssetImage(AppImages.back4);
    const p5 = AssetImage(AppImages.back5);

    try {
      await precacheImage(p1, RouteTools.getBaseContext()!);
      await precacheImage(p2, RouteTools.getBaseContext()!);
      await precacheImage(p3, RouteTools.getBaseContext()!);
      await precacheImage(p4, RouteTools.getBaseContext()!);
      await precacheImage(p5, RouteTools.getBaseContext()!);
    }
    catch(e){}

    backgroundList.add(p1);
    backgroundList.add(p2);
    backgroundList.add(p3);
    backgroundList.add(p4);
    backgroundList.add(p4);
  }
}
