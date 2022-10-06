import 'package:iris_tools/api/converter.dart';

import 'package:app/models/mixin/dateFieldMixin.dart';
import 'package:app/models/speakerModel.dart';
import 'package:app/system/keys.dart';

class ContentModel with DateFieldMixin {
  int? id;
  bool hasOrder = true;
  int? speakerId;
  List<int> mediaIds = [];
  //------------- local
  SpeakerModel? speakerModel;

  ContentModel();

  ContentModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    speakerId = map['speaker_id'];
    hasOrder = map['has_order']?? true;
    mediaIds = Converter.correctList<int>(map['media_ids'])?? <int>[];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['speaker_id'] = speakerId;
    map['media_ids'] = mediaIds;
    map['has_order'] = hasOrder;

    return map;
  }
}
