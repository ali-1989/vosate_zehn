import 'package:flutter/material.dart';

import 'package:iris_tools/api/cache/memoryCache.dart';
import 'package:iris_tools/api/manageCallAction.dart';

class AppCache {
  AppCache._();

  static ImageProvider? screenBack;
  static MemoryCache appCache = MemoryCache();
  static TimeoutCache timeoutCache = TimeoutCache();
  static TimeoutCache downloadingItems = TimeoutCache();

  //-------- Download --------------------------------------------------------------------------------
  static void addStartToDownload(String tag){
    downloadingItems.addTimeout(tag, const Duration(seconds: 30));
  }

  static bool isDownloading(String tag){
    return downloadingItems.existTimeout(tag);
  }

  static void clearDownloading(){
    downloadingItems.clearAll();
  }

  static void removeDownloading(String tag){
    downloadingItems.deleteTimeout(tag);
  }
  //---------- | Download ------------------------------------------------------------------------------
}
