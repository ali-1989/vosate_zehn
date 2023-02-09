
///=====================================================================================
enum VideoSourceType {
  file,
  network,
  bytes,
  asset
}
///=====================================================================================
enum SavePathType {
  userProfile,
  anyOnInternal,
}
///=====================================================================================
enum ImageType {
  file,
  bytes,
  asset,
  network,
}
///=====================================================================================
enum SubBucketTypes {
  video(1),
  audio(2),
  list(10);

  final int _type;

  const SubBucketTypes(this._type);

  int id(){
    return _type;
  }
}
///=====================================================================================
enum BucketTypes {
  video(1),
  motion(2),
  focus(3),
  meditation(4);

  final int _id;

  const BucketTypes(this._id);

  factory BucketTypes.fromId(int id) {
    return values.firstWhere((e) => e._id == id);
  }

  int id(){
    return _id;
  }

  String bucketName(){
    return name;
  }

  String translate(){
  switch(_id){
    case 1:
      return 'فیلم';
    case 2:
      return 'حرکت';
    case 3:
      return 'تمرکز';
    case 4:
      return 'مدیتیشن';
    default:
      return '';
  }
}
}