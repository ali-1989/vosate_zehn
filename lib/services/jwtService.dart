/*
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtService {
  static String? refreshToken;
  static String? accessToken;

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

  static String sign(Map payload, JWTKey key */
/*SecretKey('secret passphrase')*//*
,{
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
    catch (ex) {*/
/**//*
}

    return null;
  }

  static bool refreshTokenIsOk(){
    if(refreshToken == null){
      return false;
    }

    return !isExpired(refreshToken!);
  }

  static bool accessTokenIsOk(){
    if(accessToken == null){
      return false;
    }

    return !isExpired(accessToken!);
  }
}*/
