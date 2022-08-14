import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn/models/dateFieldMixin.dart';
import 'package:vosate_zehn/system/keys.dart';

class Level2Model  with DateFieldMixin {
  int? id;
  String? title;
  String? description;
  String? url;
  MediaModel? imageModel;
  int? duration;
  int? type;
  int? contentType;
  bool isFavorite = false;

  Level2Model();

  Level2Model.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    title = map[Keys.title];
    description = map[Keys.description];
    isFavorite = map['is_favorite']?? false;
    duration = map['duration'];
    type = map[Keys.type];
    url = map[Keys.url];
    contentType = map['content_type'];
    date = DateHelper.tsToSystemDate(map[Keys.date]);

    if(map[Keys.media] is Map){
      imageModel = MediaModel.fromMap(map[Keys.media]);
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();
    map[Keys.type] = type;
    map[Keys.url] = url;
    map['duration'] = duration;
    map[Keys.date] = DateHelper.toTimestampNullable(date);
    map['content_type'] = contentType;
    map['is_favorite'] = isFavorite;

    return map;
  }
}
