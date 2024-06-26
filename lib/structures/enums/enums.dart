
///=============================================================================
enum VideoSourceType {
  file,
  network,
  bytes,
  asset
}
///=============================================================================
enum SavePathType {
  userProfile,
  anyOnInternal,
}
///=============================================================================
enum ImageType {
  file,
  bytes,
  asset,
  network,
}
///=============================================================================
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
///=============================================================================
enum BucketTypes {
  video(1),
  motion(2),
  focus(3),
  meditation(4);

  final int _id;

  const BucketTypes(this._id);

  factory BucketTypes.from(dynamic data){
    if (data == null) {
      return BucketTypes.video;
    }

    if (data is String) {
      return values.firstWhere((e) => e.name == data, orElse: () => BucketTypes.video);
    }

    if (data is int) {
      return values.firstWhere((e) => e._id == data, orElse: () => BucketTypes.video);
    }

    return BucketTypes.video;
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

    /*
    if(_id == video._id){
      return 'فیلم';
    }

    if(_id == motion._id){
      return 'حرکت';
    }

    if(_id == loan._id){
      return 'وام';
    }

    if(_id == installment._id){
      return 'قسط وام';
    }

    return '-';
    */
  }
}