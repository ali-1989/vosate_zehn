import 'package:flutter/material.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/mediaModel.dart';

import 'package:app/models/contentModel.dart';
import 'package:app/models/dateFieldMixin.dart';
import 'package:app/models/enums.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appIcons.dart';

class SubBucketModel with DateFieldMixin {
  int? id;
  int? parentId;
  late String title;
  String? description;
  int? coverId;
  int? mediaId;
  int? contentId;
  int duration = 0;
  int type = 0; // 1:video, 2:audio, 10:content list
  int contentType = 0;

  //-------- local
  bool isFavorite = false;
  MediaModel? imageModel;
  MediaModel? mediaModel;
  ContentModel? contentModel;

  SubBucketModel();

  SubBucketModel.fromMap(Map? map){
    if(map == null) {
      return;
    }

    id = map[Keys.id];
    parentId = map['parent_id'];
    title = map[Keys.title]?? '';
    description = map[Keys.description];
    type = map[Keys.type];
    date = DateHelper.tsToSystemDate(map[Keys.date]);
    mediaId = map['media_id'];
    coverId = map['cover_id'];
    contentId = map['content_id'];
    contentType = map['content_type']?? 0;
    duration = map['duration']?? 0;

    isFavorite = map['is_favorite']?? false;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.title] = title;
    map[Keys.description] = description;
    map[Keys.type] = type;
    map['parent_id'] = parentId;
    map['cover_id'] = coverId;
    map['media_id'] = mediaId;
    map['content_type'] = contentType;

    if(id != null){
      map[Keys.id] = id;
    }

    if(date != null){
      map[Keys.date] = DateHelper.toTimestampNullable(date);
    }

    if(duration > 0){ //if duration is not exist, server calc this
      map['duration'] = duration;
    }

    map['is_favorite'] = isFavorite;

    return map;
  }

  IconData? getTypeIcon(){
    if(type == SubBucketTypes.video.id()){
      return AppIcons.videoCamera;
    }

    if(type == SubBucketTypes.audio.id()){
      return AppIcons.headset;
    }

    if(type == SubBucketTypes.list.id()){
      return AppIcons.list;
    }

    return null;
  }
}
