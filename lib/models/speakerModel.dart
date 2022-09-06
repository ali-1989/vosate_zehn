import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:app/models/mixin/dateFieldMixin.dart';
import 'package:app/system/keys.dart';

class SpeakerModel with DateFieldMixin {
  int? id;
  late String name;
  String? description;
  int? mediaId;
  //----------- local
  MediaModel? profileModel;

  SpeakerModel();

  SpeakerModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    name = map[Keys.name]?? '-';
    description = map[Keys.description];
    mediaId = map['media_id'];

  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.name] = name;
    map[Keys.description] = description;
    map['media_id'] = mediaId;

    return map;
  }
}
