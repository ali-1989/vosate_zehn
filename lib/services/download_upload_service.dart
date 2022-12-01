import 'package:app/constants.dart';
import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import 'package:app/tools/app/appBroadcast.dart';

class DownloadUploadService {
  DownloadUploadService._();

  static late DownloadManager downloadManager;
  static late UploadManager uploadManager;

  static init(){
    downloadManager = DownloadManager('${Constants.appName}DownloadManager');
    uploadManager = UploadManager('${Constants.appName}UploadManager');

    downloadManager.addListener(DownloadUploadService.commonDownloadListener);
    uploadManager.addListener(DownloadUploadService.commonUploadListener);
  }

  static void commonDownloadListener(DownloadItem di) async {
    if(di.isComplete()) {
      if(di.isInCategory(DownloadCategory.userProfile)){
        AppBroadcast.avatarNotifier.notifyAll(null);
      }
    }
  }

  static void commonUploadListener(UploadItem ui) async {
    if(ui.isComplete()) {
      if (ui.isInCategory(DownloadCategory.userProfile)) {
        if(ui.response == null){
          return;
        }

        final json = JsonHelper.jsonToMap<String, dynamic>(ui.response!.data)!;
      }
    }
  }
}
///==========================================================================
class DownloadCategory {
  static const userProfile = 'user_profile';
}
