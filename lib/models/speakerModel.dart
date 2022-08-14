import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:vosate_zehn/system/keys.dart';

class SpeakerModel {
  int? id;
  String? name;
  String? description;
  MediaModel? imageModel;

  SpeakerModel();

  SpeakerModel.fromMap(Map? map){
    if(map != null) {
      id = map[Keys.id];
      name = map[Keys.name];
      description = map[Keys.description];

      if(map[Keys.media] is Map){
        imageModel = MediaModel.fromMap(map[Keys.media]);
      }
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.name] = name;
    map[Keys.description] = description;
    map[Keys.media] = imageModel?.toMap();

    return map;
  }
}
