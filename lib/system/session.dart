import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import 'package:app/structures/models/userModel.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appLocale.dart';
import '/managers/settingsManager.dart';
import '/system/extensions.dart';
import '/system/keys.dart';

class Session {
	Session._();

	static UserModel? _lastLoginUser;
	static List<UserModel> currentLoginList = [];
	static final List<Function(UserModel user)> _loginListeners = [];
	static final List<Function(UserModel user)> _logoffListeners = [];
	static final List<Function(UserModel user, Map? old)> _profileChangeListeners = [];

	static Future<int> fetchLoginUsers() async {
		final list = AppDB.db.query(AppDB.tbUserModel,
				Conditions().add(Condition(ConditionType.DefinedNotNull)..key = Keys.setting$lastLoginDate));

		if(list.isNotEmpty){
			for (final row in list) {
				final isCur = getExistLoginUserById(row[Keys.userId]);

				if(isCur == null) {
					final n = (row as Map).map<String, dynamic>((k, v){
						return MapEntry<String, dynamic>(k.toString(), v);
					});

					currentLoginList.add(createOrUpdateUserModel(n, null));
				}
			}
		}

		final lastSaved = SettingsManager.settingsModel.lastUserId;

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

	static bool isLogin(String userId){
		return currentLoginList.firstWhereSafe((element) => element.userId == userId) != null;
	}

	static UserModel? getLastLoginUser(){
		return _lastLoginUser;
	}

	static void _setLastLoginUser(UserModel? newUser){
		_lastLoginUser = newUser;
		SettingsManager.settingsModel.lastUserId = newUser?.userId;

		SettingsManager.saveSettings();
	}

	static Future<UserModel?> login$newProfileData(Map json) async {
		final userId = json[Keys.userId]?.toString();

		if(userId == null) {
		  return null;
		}

		final newUser = UserModel.fromMap(json);

		//newUser.token?.refreshToken = json['refreshToken'];

		newUser.loginDate = DateHelper.getNow().toUtc();

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
		final updateDb = await AppDB.db.insertOrUpdate(AppDB.tbUserModel, newUser.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = newUser.userId));

		if(updateDb > 0) {
			if(wasLoginUser != null) {
				final old = wasLoginUser.toMap();

				wasLoginUser.matchBy(newUser);
				_setLastLoginUser(wasLoginUser);

				notifyChangeProfileInfo(wasLoginUser, old);

				return wasLoginUser;
			}
			else {
				currentLoginList.add(newUser);
				_setLastLoginUser(newUser);

				notifyNewLogin(newUser, json);

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
		final updateDb = await AppDB.db.insertOrUpdate(AppDB.tbUserModel, newUser.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = newUser.userId));

		if(updateDb > 0) {
			if(wasLoginUser != null) {
				final oldMap = wasLoginUser.toMap();
				wasLoginUser.matchBy(newUser);

				notifyChangeProfileInfo(wasLoginUser, oldMap);
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
		final cas = AppDB.db.query(AppDB.tbUserModel,
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
		final old = (await fetchUserById(user.userId))?.toMap();

		final res = await AppDB.db.update(AppDB.tbUserModel, user.toMap(),
				Conditions().add(Condition()..key = Keys.userId..value = user.userId));

		if(res > 0) {
			notifyChangeProfileInfo(user, old);
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

		await AppDB.db.update(AppDB.tbUserModel, val,
				Conditions().add(Condition()..key = Keys.userId..value = userId));

		currentLoginList.removeWhere((element) => element.userId == userId);

		if(currentLoginList.isNotEmpty) {
		  _setLastLoginUser(currentLoginList.last);
		}
		else {
		  _setLastLoginUser(null);
		}

		notifyLogoff(user);

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
		await AppDB.db.update(AppDB.tbUserModel, val, con);

		for(var u in currentLoginList){
			notifyLogoff(u);
		}

		currentLoginList.clear();
		_setLastLoginUser(null);

		return true;
	}

	static Future<bool> deleteUserInfo(String userId) async{
		final res = await AppDB.db.delete(AppDB.tbUserModel,
				Conditions().add(Condition()..key = Keys.userId..value = userId));

		return res > 0;
	}

	static String getSexEquivalent(int? sex){
		if(sex == null) {
		  return AppLocale.appLocalize.translate('unknown')!;
		}

		switch(sex){
			case 0:
				return AppLocale.appLocalize.translate('unknown')!;
			case 1:
				return AppLocale.appLocalize.translate('man')!;
			case 2:
				return AppLocale.appLocalize.translate('woman')!;
			case 5:
				return AppLocale.appLocalize.translate('bisexual')!;
		}

		return AppLocale.appLocalize.translate('unknown')!;
	}

	static void addLoginListener(void Function(UserModel user) listener){
		if(!_loginListeners.contains(listener)) {
		  _loginListeners.add(listener);
		}
	}

	static void removeLoginListener(void Function(UserModel user) listener){
		_loginListeners.remove(listener);
	}

	static void addLogoffListener(void Function(UserModel user) listener){
		if(!_logoffListeners.contains(listener)) {
		  _logoffListeners.add(listener);
		}
	}

	static void removeLogoffListener(void Function(UserModel user) listener){
		_logoffListeners.remove(listener);
	}

	static void addProfileChangeListener(void Function(UserModel user, Map? old) listener){
		if(!_profileChangeListeners.contains(listener)) {
		  _profileChangeListeners.add(listener);
		}
	}

	static void removeProfileChangeListener(void Function(UserModel user, Map? old) listener){
		_profileChangeListeners.remove(listener);
	}

	static void clearLoginListeners(){
		_loginListeners.clear();
	}

	static void clearLogoffListeners(){
		_logoffListeners.clear();
	}

	static void clearProfileChangeListeners(){
		_profileChangeListeners.clear();
	}
}
///======================================================================================================
void notifyNewLogin(UserModel user, Map json) {
	void callListeners(){
		for(Function f in Session._loginListeners){
			try{
				f.call(user);
			}
			catch(e){/**/}
		}
	}

	callListeners();
	//must call immediate Future(callListeners);
}
//---------------------------------------------------------
void notifyLogoff(UserModel user) async {
	void callListeners() {
		for (Function f in Session._logoffListeners) {
			try {
				f.call(user);
			}
			catch (e) {/**/}
		}
	}

	// ignore: unawaited_futures
	Future(callListeners);
}
//---------------------------------------------------------
void notifyChangeProfileInfo(UserModel user, Map? old) {
	void callListeners() {
		for (Function f in Session._profileChangeListeners) {
			try {
				f.call(user, old);
			}
			catch (e) {/**/}
		}
	}

	callListeners();
	//Future(callListeners);
}
