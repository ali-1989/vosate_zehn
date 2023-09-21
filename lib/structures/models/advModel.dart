import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';

import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/system/keys.dart';

class AdvModel with DateFieldMixin {
  late int id;
  String? title;
  String? tag;
  String? type;
  int? mediaId;
  String? clickUrl;
  //----------- local
  MediaModel? mediaModel;

  AdvModel();

  AdvModel.fromMap(Map map) {
    id = map[Keys.id];
    mediaId = map['media_id'];
    title = map['title'];
    tag = map['tag'];
    type = map['type'];
    clickUrl = map['url'];
    date = DateHelper.tsToSystemDate(Keys.date);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['media_id'] = mediaId;
    map['title'] = title;
    map['type'] = type;
    map['tag'] = tag;
    map['url'] = clickUrl;
    map[Keys.date] = DateHelper.toTimestampNullable(date);

    return map;
  }

  void matchBy(AdvModel other){
    mediaId = other.mediaId;
    title = other.title;
    type = other.type;
    tag = other.tag;
    clickUrl = other.clickUrl;
    date = other.date;

    mediaModel = other.mediaModel;
  }
}
