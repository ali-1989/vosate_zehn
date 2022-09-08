import 'package:app/services/lastSeenService.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/models/abstract/stateBase.dart';
import 'package:app/models/subBuketModel.dart';
import 'package:app/pages/levels/audio_player_page.dart';
import 'package:app/pages/levels/content_view_page.dart';
import 'package:app/pages/levels/video_player_page.dart';
import 'package:app/services/favoriteService.dart';
import 'package:app/system/enums.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appRoute.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:app/views/AppBarCustom.dart';
import 'package:app/views/waitToLoad.dart';

class LastSeenPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/LastSeenPage',
    name: (LastSeenPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => LastSeenPage(),
  );

  const LastSeenPage({Key? key}) : super(key: key);

  @override
  State<LastSeenPage> createState() => _LastSeenPageState();
}
///==================================================================================
class _LastSeenPageState extends StateBase<LastSeenPage> {
  bool isInFetchData = true;
  List<SubBucketModel> listItems = [];

  @override
  void initState(){
    super.initState();

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
    if(isInFetchData) {
      return WaitToLoad();
    }

    return GridView.builder(
      itemCount: listItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 220),
      itemBuilder: (ctx, idx){
        return buildListItem(idx);
      },
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return InkWell(
      onTap: (){
        onItemClick(itm);
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              children: [
                Stack(
                  children: [
                    Builder(
                      builder: (ctx){
                        if(itm.imageModel?.url != null){
                          return Image.network(itm.imageModel!.url!, width: double.infinity, height: 100, fit: BoxFit.contain);
                        }

                        return Image.asset(AppImages.appIcon, width: double.infinity, height: 100, fit: BoxFit.contain);
                      },
                    ),

                    Positioned(
                        top: 0,
                        left: 0,
                        child: Builder(
                            builder: (context) {
                              if(itm.type == SubBucketTypes.video.id()){
                                return Chip(//todo: chip transparent
                                  backgroundColor: Colors.black.withAlpha(200),
                                  shadowColor: Colors.transparent,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                  label: Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                );
                              }

                              if(itm.type == SubBucketTypes.audio.id()){
                                return Chip(
                                  backgroundColor: Colors.black.withAlpha(200),
                                  shadowColor: Colors.transparent,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                  label: Icon(AppIcons.headset, size: 15, color: Colors.white),
                                );
                              }

                              return SizedBox();
                            }
                        )
                    ),
                  ],
                ),

                SizedBox(height: 12),

                Text(itm.title, maxLines: 1).bold().fsR(1),

                SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.duration > 0){
                            final dur = Duration(milliseconds: itm.duration);
                            return Text('${DurationFormatter.duration(dur, showSuffix: false)} ثانیه').alpha().subFont();
                          }

                          return SizedBox();
                        },
                      ),

                      IconButton(
                          constraints: BoxConstraints.tightFor(),
                          padding: EdgeInsets.all(4),
                          splashRadius: 20,
                          visualDensity: VisualDensity.compact,
                          iconSize: 20,
                          onPressed: (){
                            deleteFavorite(itm);
                          },
                          icon: Icon(AppIcons.delete, size: 20, color: Colors.red,)
                      )
                    ],
                  ),
                )
              ],
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

    assistCtr.updateMain();
  }

  void onItemClick(SubBucketModel itm) {
    if(itm.type == SubBucketTypes.video.id()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == SubBucketTypes.audio.id()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.mediaModel!.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';//widget.injectData.level1model?.title;
      inject.subTitle = itm.title;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == SubBucketTypes.list.id()){
      final inject = ContentViewPageInjectData();
      inject.subBucket = itm;

      AppRoute.pushNamed(context, ContentViewPage.route.name!, extra: inject);
      return;
    }
  }

  void fetchData() async {
    listItems.addAll(LastSeenService.getAllItems());

    for(final m in listItems){
      m.isFavorite = FavoriteService.isFavorite(m.id!);
    }

    isInFetchData = false;
    assistCtr.updateMain();
  }
}
