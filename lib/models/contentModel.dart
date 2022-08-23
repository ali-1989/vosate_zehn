import 'package:iris_tools/api/converter.dart';
import 'package:app/tools/searchFilterTool.dart';
import 'package:app/models/speakerModel.dart';
import 'package:app/system/keys.dart';

class ContentModel with DateFieldMixin {
  int? id;
  //int? type;
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
    mediaIds = Converter.correctList<int>(map['media_ids'])?? <int>[];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['speaker_id'] = speakerId;
    map['media_ids'] = mediaIds;

    return map;
  }
}
