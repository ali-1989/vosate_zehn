
enum Level2Types {
  video(1),
  audio(2),
  list(10);

  final int _type;

  const Level2Types(this._type);

  int type(){
    return _type;
  }
}
///=====================================================================================
enum SavePathType {
  userProfile,
}
///=====================================================================================
enum ImageType {
  file,
  bytes,
  asset
}