import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';


class DownloadUpload {
  DownloadUpload._();

  static late DownloadManager downloadManager;
  static late UploadManager uploadManager;

  static void commonDownloadListener(DownloadItem di) async {

    if(di.isComplete()) {
      if(di.isInCategory(DownloadCategory.userProfile)){
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
