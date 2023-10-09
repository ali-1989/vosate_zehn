import 'package:iris_db/iris_db.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/user_type.dart';
import 'package:app/structures/models/user_model.dart';
import 'package:app/tools/app/app_db.dart';
import '/managers/settings_manager.dart';
import '/system/extensions.dart';
import '/system/keys.dart';

class SessionService {
	SessionService._();

	static UserModel? _lastLoginUser;
	static List<UserModel> currentLoginList = [];
	
	static Future<int> fetchLoginUsers() async {
		final list = AppDB.db.query(AppDB.tbUsers,
				Conditions().add(Condition(ConditionType.DefinedNotNull)..key = Keys.setting$lastLoginDate));

		if(list.isNotEmpty){
			for (final row in list) {
				final isCur = getExistLoginUserById(row[Keys.userId]);

				final n = (row as Map).map<String, dynamic>((k, v){
					return MapEntry<String, dynamic>(k.toString(), v);
				});

				if(isCur == null) {
					currentLoginList.add(createOrUpdateUserModel(n, null));
				}
				else {
					createOrUpdateUserModel(n, isCur);
				}
			}
		}

		/// last user
		final lastSaved = SettingsManager.localSettings.lastUserId;

		if (!Checker.isNullOrEmpty(lastSaved)) {
			_lastLoginUser = currentLoginList.firstWhereSafe((element) => element.userId == lastSaved);
		}

		if(_lastLoginUser == null && currentLoginList.isNotEmpty) {
			_lastLoginUser = currentLoginList.last;
		}

		return list.length;
	}

	static bool hasAnyLogin(){
		return currentLoginList.isNotEmpty;
	}

	static bool isGuestCurrent(){
		if(!hasAnyLogin()){
			return false;
		}

		return getLastLoginUser()!.userType == UserType.guest;
	}

	static bool isLogin(String userId){
		return currentLoginList.firstWhereSafe((element) => element.userId == userId) != null;
	}

	static UserModel? getLastLoginUser(){
		return _lastLoginUser;
	}

	static void _setLastLoginUser(UserModel? newUser){
		_lastLoginUser = newUser;
		SettingsManager.localSettings.lastUserId = newUser?.userId;

		SettingsManager.saveLocalSettingsAndNotify();
	}

	static Future<UserModel?> login$newProfileData(Map json) async {
		final userId = json[Keys.userId]?.toString();

		if(userId == null) {
		  return null;
		}

		final newUser = UserModel.fromMap(json);

		//newUser.token?.refreshToken = json['refreshToken'];

		newUser.loginDate = DateHelper.now().toUtc();

		final wasLoginUser = getExistLoginUserById(userId);
		var oldDbUser = wasLoginUser;

		oldDbUser ??= await fetchUserById(userId);

		if(oldDbUser != null) {
			/// copy current Token to new data if not exist
			if(Checker.isNullOrEmpty(newUser.token)) {
				newUser.token = oldDbUser.token;
			}
		}

		/// insert to db
		final updateDb = await AppDB.db.insertOrUpdate(AppDB.tbUsers, newUser.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = newUser.userId));

		if(updateDb > 0) {
			if(wasLoginUser != null) {
				//final old = wasLoginUser.toMap();

				wasLoginUser.matchBy(newUser);
				_setLastLoginUser(wasLoginUser);

				EventNotifierService.notify(AppEvents.userProfileChange, data: wasLoginUser);

				return wasLoginUser;
			}
			else {
				currentLoginList.add(newUser);
				_setLastLoginUser(newUser);

				EventNotifierService.notify(AppEvents.userLogin, data: newUser);

				return newUser;
			}
		}

		return null;
	}

	static Future<void> newProfileData(Map<String, dynamic> json) async {
		final userId = json[Keys.userId]?.toString();

		if(userId == null) {
		  return;
		}

		final newUser = UserModel.fromMap(json);

		final wasLoginUser = getExistLoginUserById(userId);
		var oldDbUser = wasLoginUser;

		oldDbUser ??= await fetchUserById(userId);

		if(oldDbUser != null) {
			newUser.loginDate = oldDbUser.loginDate;

			/// copy current Token to new data if not exist
			if(Checker.isNullOrEmpty(json[Keys.token])) {
				newUser.token = oldDbUser.token;
			}
		}

		/// insert to db
		final updateDb = await AppDB.db.insertOrUpdate(AppDB.tbUsers, newUser.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = newUser.userId));

		if(updateDb > 0) {
			if(wasLoginUser != null) {
				//final oldMap = wasLoginUser.toMap();
				wasLoginUser.matchBy(newUser);

				EventNotifierService.notify(AppEvents.userProfileChange, data: wasLoginUser);
			}
		}
	}

	static UserModel createOrUpdateUserModel(Map<String, dynamic> map, UserModel? user) {
		final res = UserModel.fromMap(map);

		if(user != null) {
			user.matchBy(res);
			return user;
		}

		return res;
	}

	static UserModel? getExistLoginUserById(String userId){
		return currentLoginList.firstWhereSafe((element) => element.userId == userId,);
	}

	static Future<UserModel?> fetchUserById(String userId) async {
		final cas = AppDB.db.query(AppDB.tbUsers,
				Conditions().add(Condition()..key = Keys.userId..value = userId));

		if(cas.isEmpty) {
		  return null;
		}

		final row = cas.first;
		return createOrUpdateUserModel(row, null);
	}

	static Future<UserModel?> pickUserById(String userId) async{
		final x = getExistLoginUserById(userId);

		if(x != null) {
		  return Future.value(x);
		}

		return fetchUserById(userId);
	}

	static Future<bool> sinkUserInfo(UserModel user) async {
		//final old = (await fetchUserById(user.userId))?.toMap();

		final res = await AppDB.db.update(AppDB.tbUsers, user.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = user.userId));

		if(res > 0) {
			EventNotifierService.notify(AppEvents.userProfileChange, data: user);
			return true;
		}

		return false;
	}

	static Future<bool> logoff(String userId) async{
		final user = getExistLoginUserById(userId);

		if(user == null) {
			return false;
		}

		final val = <String, dynamic>{};
		val[Keys.setting$lastLoginDate] = null;

		await AppDB.db.update(AppDB.tbUsers, val, Conditions().add(Condition()..key = Keys.userId..value = userId));

		currentLoginList.removeWhere((element) => element.userId == userId);

		if(currentLoginList.isNotEmpty) {
		  _setLastLoginUser(currentLoginList.last);
		}
		else {
		  _setLastLoginUser(null);
		}

		EventNotifierService.notify(AppEvents.userLogoff, data: user);

		return true;
	}

	static Future<bool> logoffLast() async{
		final user = getLastLoginUser();

		if(user == null) {
		  return false;
		}

		return logoff(user.userId);
	}

	static Future<bool> logoffAll() async{
		final val = <String, dynamic>{};
		val[Keys.setting$lastLoginDate] = null;

		final con = Conditions().add(Condition(ConditionType.DefinedNotNull)..key = Keys.userId);
		await AppDB.db.update(AppDB.tbUsers, val, con);

		for(var u in currentLoginList){
			EventNotifierService.notify(AppEvents.userLogoff, data: u);
		}

		currentLoginList.clear();
		_setLastLoginUser(null);

		return true;
	}

	static Future<bool> deleteUserInfo(String userId) async{
		final res = await AppDB.db.delete(AppDB.tbUsers,
				Conditions().add(Condition()..key = Keys.userId..value = userId));

		return res > 0;
	}

	static UserModel getGuestUser(){
		final g = UserModel();
		g.userId = '0';
		g.userName = 'مهمان';
		g.userType = UserType.guest;
		g.name = 'مهمان';
		g.family = '';

		return g;
	}
}
