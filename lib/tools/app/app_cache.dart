import 'package:flutter/material.dart';

import 'package:iris_tools/api/cache/memoryCache.dart';
import 'package:iris_tools/api/cache/timeoutCache.dart';

class AppCache {
  AppCache._();

  static ImageProvider? screenBack;
  static MemoryCache appCache = MemoryCache();
  static TimeoutCache timeoutCache = TimeoutCache();
  static TimeoutCache downloadingCache = TimeoutCache();

  //-------- Download --------------------------------------------------------------------------------
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

  static bool canCallMethodAgain(String key, {Duration dur = const Duration(seconds: 6)}){
    return AppCache.timeoutCache.addTimeout(key, dur);
  }
}
