import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';

import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/system/keys.dart';

class BucketModel with DateFieldMixin {
  int? id;
  late String title;
  String? description;
  int? mediaId;
  int bucketType = 0; // focus, video, ...
  bool isHide = true;
  bool isVip = false;
  //--------------- local
  MediaModel? imageModel;
  //List<SubBucketModel> subList = [];

  BucketModel();

  BucketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];
    bucketType = map['bucket_type']?? 0;
    mediaId = map['media_id'];
    isHide = map['is_hide']?? true;
    isVip = map['is_vip']?? false;
    date = DateHelper.timestampToSystem(map[Keys.date]);

    /*if(map[Keys.dataList] is List){
      for(final i in map[Keys.dataList]) {
        final itm = Level2Model.fromMap(i);
        level2List.add(itm);
      }
    }*/
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map['bucket_type'] = bucketType;
    map['media_id'] = mediaId;
    map['is_hide'] = isHide;
    map['is_vip'] = isVip;

    if(date != null){
      map[Keys.date] = DateHelper.toTimestampNullable(date);
    }

    return map;
  }

  Map<String, dynamic> toMapServer(){
    return JsonHelper.removeNulls(toMap()) as Map<String, dynamic>;
  }
}
