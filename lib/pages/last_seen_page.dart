import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/services/favoriteService.dart';
import 'package:app/services/lastSeenService.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/baseComponents/appBarBuilder.dart';
import 'package:app/views/states/emptyData.dart';
import 'package:app/views/states/waitToLoad.dart';

class LastSeenPage extends StatefulWidget{

  const LastSeenPage({Key? key}) : super(key: key);

  @override
  State<LastSeenPage> createState() => _LastSeenPageState();
}
///==================================================================================
class _LastSeenPageState extends StateBase<LastSeenPage> {
  List<SubBucketModel> listItems = [];

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    fetchData();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            appBar: AppBarCustom(
              title: Text(AppMessages.lastSeenItem),
            ),
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(assistCtr.hasState(AssistController.state$loading)) {
      return const WaitToLoad();
    }

    if(listItems.isEmpty) {
      return const EmptyData();
    }

    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (ctx, idx){
        return buildListItem(idx);
      },
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return SizedBox(
      height: 130,
      child: InkWell(
        onTap: (){
          onItemClick(itm);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Flexible(
                      child: Stack(
                        children: [
                          Builder(
                            builder: (ctx){
                              if(itm.imageModel?.url != null){
                                return IrisImageView(
                                  width: double.infinity,
                                  height: 130,
                                  fit: BoxFit.fill,
                                  url: itm.imageModel!.url!,
                                  imagePath: AppDirectories.getSavePathMedia(itm.imageModel, SavePathType.anyOnInternal, null),
                                );
                              }

                              return Image.asset(AppImages.appIcon, width: double.infinity, height: 100, fit: BoxFit.contain);
                            },
                          ),

                          Positioned(
                              top: 0,
                              right: 0,
                              child: Builder(
                                  builder: (context) {
                                    IconData? icon;

                                    if(itm.type == SubBucketTypes.video.id()){
                                      icon = AppIcons.videoCamera;
                                    }

                                    if(itm.type == SubBucketTypes.audio.id()){
                                      icon = AppIcons.headset;
                                    }

                                    if(icon != null){
                                      return Theme(
                                        data: AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent),
                                        child: Chip(
                                          backgroundColor: Colors.grey.withAlpha(160),
                                          shadowColor: Colors.transparent,
                                          visualDensity: VisualDensity.compact,
                                          elevation: 0,
                                          label: Icon(icon, size: 15, color: Colors.white),
                                        ),
                                      );
                                    }

                                    return const SizedBox();
                                  }
                              )
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical:8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(itm.title, maxLines: 1).bold().fsR(1),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(
                                  builder: (ctx){
                                    if(itm.duration > 0){
                                      final dur = Duration(milliseconds: itm.duration);
                                      return Text('${DurationFormatter.duration(dur, showSuffix: false)} ثانیه').alpha().thinFont();
                                    }

                                    return const SizedBox();
                                  },
                                ),


                                IconButton(
                                    constraints: const BoxConstraints.tightFor(),
                                    padding: const EdgeInsets.all(4),
                                    splashRadius: 20,
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 20,
                                    onPressed: (){
                                      //setFavorite(itm);
                                    },
                                    icon: Icon(itm.isFavorite ? AppIcons.heartSolid: AppIcons.heart,
                                      size: 20,
                                      color: itm.isFavorite ? Colors.red: Colors.black,
                                    )
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteFavorite(SubBucketModel itm) async {
    itm.isFavorite = !itm.isFavorite;
    bool res = await FavoriteService.removeFavorite(itm.id!);

    if(!res){
      AppToast.showToast(context, AppMessages.operationFailed);
      return;
    }

    listItems.removeWhere((element) => element.id == itm.id);

    assistCtr.updateHead();
  }

  void onItemClick(SubBucketModel itm) {
    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      RouteTools.pushPage(context, VideoPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';//widget.injectData.level1model?.title;
      inject.subTitle = itm.title;

      RouteTools.pushPage(context, AudioPlayerPage(injectData: inject));
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      final inject = ContentViewPageInjectData();
      inject.subBucket = itm;

      RouteTools.pushPage(context, ContentViewPage(injectData: inject));
      return;
    }
  }

  void fetchData() async {
    listItems.addAll(LastSeenService.getAllItems());

    for(final m in listItems){
      m.isFavorite = FavoriteService.isFavorite(m.id!);
    }

    assistCtr.clearStates();
    assistCtr.updateHead();
  }
}
