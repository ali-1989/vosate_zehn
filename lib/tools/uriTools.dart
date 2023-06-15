import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:url_launcher/url_launcher.dart';

import '/managers/settings_manager.dart';

class UriTools {
  UriTools._();

  static bool isInternalLink(String? link){
    return link != null && (link.startsWith('/') || link.contains(SettingsManager.localSettings.httpAddress));
  }

  static String addHttpIfNeed(String? path){
    if(path == null) {
      return '';
    }

    if(path.contains('http')) {
      return path;
    }

    return 'http://$path';
  }

  static String correctIfIsInternalUrl(String? path){
    if(path == null) {
      return SettingsManager.localSettings.httpAddress;
    }

    if(path.startsWith(RegExp(SettingsManager.localSettings.httpAddress))) {
      return path;
    }

    if (!isInternalLink(path)) {
      return path;
    }

    if(path.startsWith('/')) {
      return SettingsManager.localSettings.httpAddress + path;
    }

    return '${SettingsManager.localSettings.httpAddress}/$path';
  }

  static String? correctAppUrl(String? url, {String? domain}) {
    if(url == null){
      return null;
    }

    domain ??= SettingsManager.localSettings.httpAddress;
    url = UrlHelper.decodePathFromDataBase(url)!;

    if(!url.startsWith('http')) {
      url = '$domain/$url';
    }
    else {
      if(!url.contains(domain)){
        url = url.replaceFirst(RegExp('http://\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(:\\d{1,5})?'), '');
        url = domain + url;
      }
    }

    return PathHelper.resolveUrl(url)!;
  }

  static Future<bool> openUrl(String link) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      return launchUrl(Uri.parse(link));
    }
    else {
      throw 'Could not launch $link';
    }
  }
}
