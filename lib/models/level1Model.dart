
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';
import 'package:vosate_zehn/models/dateFieldMixin.dart';
import 'package:vosate_zehn/system/keys.dart';

class Level1Model with DateFieldMixin {
  int? id;
  String? title;
  String? description;
  MediaModel? imageModel;

  Level1Model();

  Level1Model.fromMap(Map? map){
    if(map != null) {
      id = map[Keys.id];
      title = map[Keys.title];
      description = map[Keys.description];
      date = DateHelper.tsToSystemDate(map[Keys.date]);

      if(map[Keys.media] is Map){
        imageModel = MediaModel.fromMap(map[Keys.media]);
      }
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();
    map[Keys.date] = DateHelper.toTimestampNullable(date);

    return map;
  }
}