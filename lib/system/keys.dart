// ignore_for_file: non_constant_identifier_names

class Keys {
  Keys._();

  static const request = 'request';
  static const status = 'status';
  static const command = 'command';
  static const section = 'section';
  static const ok = 'ok';
  static const error = 'error';
  static const cause = 'cause';
  static const causeCode = 'cause_code';
  static const deviceId = 'device_id';
  static const userId = 'user_id';
  static const forUserId = 'for_user_id';
  static const userName = 'user_name';
  static const userType = 'user_type';
  static const fileName = 'file_name';
  static const partName = 'part_name';
  static const token = 'token';
  static const expire = 'expire';
  static const appVersion = 'app_version';
  static const appName = 'app_name';
  static const value = 'value';
  static const name = 'name';
  static const key = 'key';
  static const iso = 'iso';
  static const family = 'family';
  static const sex = 'sex';
  static const birthdate = 'birthdate';
  static const title = 'title';
  static const type = 'type';
  static const domain = 'domain';
  static const requesterId = 'requester_id';
  static const count = 'count';
  static const data = 'data';
  static const date = 'date';
  static const registerDate = 'register_date';
  static const state = 'state';
  static const options = 'options';
  static const filtering = 'filtering';
  static const jsonHttpPart = 'json';
  static const mobileNumber = 'mobile_number';
  static const phoneCode = 'phone_code';
  static const languageIso = 'language_iso';
  static const countryIso = 'country_iso';
  static const profileImageUrl = 'profile_image_url';
  static const profileImagePath = 'profile_image_path';
  static const imageUri = 'image_uri';
  static const imagePath = 'image_path';
  static const path = 'path';
  static const fileUri = 'file_uri';
  static const uri = 'uri';
  static const id = 'id';
  static const description = 'description';
  static const orderNum = 'order_num';
  static const nodeName = 'node_name';
  static const extraJs = 'extra_js';
  static const toast = 'toast';
  //----- settings key -----------------------------------------------------------------
  static const setting$lastLoginDate = 'last_login_date';
  static const setting$lastRouteName = 'Last_route_name';
  static const setting$appSettings = 'app_settings';
  static const setting$fontThemeData = 'font_theme_data';
  static const setting$colorThemeName = 'color_theme_name';
  static const setting$patternKey = 'lock_pattern';
  static const setting$ColorThemeName = 'colorT_theme_name';
  static const setting$lastForegroundTs = 'last_foreground_ts';
  static const setting$confirmOnExit = 'confirm_on_exit';

  static String genDownloadKey_userAvatar(int userId) {
    return 'downloadUserAvatar_$userId';
  }
}
