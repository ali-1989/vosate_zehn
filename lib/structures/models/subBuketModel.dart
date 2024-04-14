import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/dataModels/media_model.dart';

import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/mixins/date_field_mixin.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_icons.dart';

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

  bool isVip = false;

  //-------- local
  bool isFavorite = false;
  MediaModel? imageModel;
  MediaModel? mediaModel;

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
    date = DateHelper.timestampToSystem(map[Keys.date]);
    mediaId = map['media_id'];
    coverId = map['cover_id'];
    contentId = map['content_id'];
    contentType = map['content_type']?? 0;
    duration = map['duration']?? 0;
    isVip = map['is_vip']?? false;

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

    map['is_vip'] = isVip;

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
