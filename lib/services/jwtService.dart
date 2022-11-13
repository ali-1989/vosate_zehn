/*

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtService {
  JwtService._();

  static Map decodeToken(String token){
    return JwtDecoder.decode(token);
  }

  static bool isExpired(String token){
    return JwtDecoder.isExpired(token);
  }

  static Duration getTokenTime(String token){
    return JwtDecoder.getTokenTime(token);
  }

  static DateTime getExpirationDate(String token){
    return JwtDecoder.getExpirationDate(token);
  }

  static String sign(Map payload, JWTKey key /*SecretKey('secret passphrase')*/,{
    String? issuer,
    String? jwtId,
    JWTAlgorithm algorithm = JWTAlgorithm.RS256,
  }){

    final jwt = JWT(
      payload,
      jwtId: jwtId,
      issuer: issuer,
    );

    return jwt.sign(key, algorithm: algorithm);
  }

  static JWT? verify(String token, JWTKey key ,{
    bool checkHeader = false,
  }){

    try {
      return JWT.verify(token, key,
          checkHeaderType: checkHeader,
      );
    }
    catch (ex) {/**/}

    return null;
  }

  static bool refreshTokenIsOk(String? rToken){
    if(rToken == null){
      return false;
    }

    return !isExpired(rToken);
  }

  static bool accessTokenIsOk(String? accessToken){
    if(accessToken == null){
      return false;
    }

    return !isExpired(accessToken);
  }

  static Future<bool> requestNewToken(UserModel um) async {
    final js = <String, dynamic>{};
    js['accessToken'] = um.token?.token;
    js['refreshToken'] = um.token?.refreshToken;

    final r = HttpItem();
    r.fullUrl = '${PublicAccess.serverApi}/updateToken';
    r.method = 'PUT';
    r.body = js;
    r.headers['accept'] = 'application/json';
    r.headers['Content-Type'] = 'application/json';

    final a = AppHttpDio.send(r);
    await a.response;

    if(a.responseData?.statusCode == 200){
      final dataJs = a.getBodyAsJson()!;
      um.token?.token = dataJs['data'];

      return true;
    }

    else if(a.responseData?.statusCode == 422){
      final dataJs = a.getBodyAsJson()!;
      final message = dataJs['message'];

      AppToast.showToast(AppRoute.getBaseContext(), message);

      await Session.logoff(um.userId);
      AppBroadcast.reBuildMaterial();
      AppRoute.backToRoot(AppRoute.getLastContext());
    }

    else if(a.responseData?.statusCode == 307){
      final dataJs = a.getBodyAsJson()!;
      final message = dataJs['message'];

      AppToast.showToast(AppRoute.getBaseContext(), message);

      await Session.logoff(um.userId);
      AppBroadcast.reBuildMaterial();
      AppRoute.backToRoot(AppRoute.getLastContext());
    }

    return false;
  }
}
*/
