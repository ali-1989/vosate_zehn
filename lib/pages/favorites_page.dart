import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:iris_tools/api/duration/durationFormater.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:vosate_zehn/models/enums.dart';
import 'package:vosate_zehn/models/level2Model.dart';
import 'package:vosate_zehn/pages/levels/audio_player_page.dart';
import 'package:vosate_zehn/pages/levels/content_view_page.dart';
import 'package:vosate_zehn/pages/levels/video_player_page.dart';
import 'package:vosate_zehn/services/favoriteService.dart';
import 'package:vosate_zehn/system/extensions.dart';
import 'package:vosate_zehn/system/stateBase.dart';
import 'package:vosate_zehn/tools/app/appIcons.dart';
import 'package:vosate_zehn/tools/app/appMessages.dart';
import 'package:vosate_zehn/tools/app/appRoute.dart';
import 'package:vosate_zehn/tools/app/appToast.dart';
import 'package:vosate_zehn/views/AppBarCustom.dart';
import 'package:vosate_zehn/views/waitToLoad.dart';

class FavoritesPage extends StatefulWidget {
  static final route = GoRoute(
    path: '/FavoritesPage',
    name: (FavoritesPage).toString().toLowerCase(),
    builder: (BuildContext context, GoRouterState state) => FavoritesPage(),
  );

  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}
///==================================================================================
class _FavoritesPageState extends StateBase<FavoritesPage> {
  bool isInFetchData = true;
  List<Level2Model> listItems = [];

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
              title: Text(AppMessages.favorites),
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
                    Image.network(itm.imageModel?.url?? '', height: 100, width: double.infinity, fit: BoxFit.fill),

                    Positioned(
                        top: 0,
                        left: 0,
                        child: Builder(
                            builder: (context) {
                              if(itm.type == Level2Types.video.type()){
                                return Chip(//todo: chip transparent
                                  backgroundColor: Colors.black.withAlpha(200),
                                  shadowColor: Colors.transparent,
                                  visualDensity: VisualDensity.compact,
                                  elevation: 0,
                                  label: Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                );
                              }

                              if(itm.type == Level2Types.audio.type()){
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

                Text('${itm.title}', maxLines: 1).bold().fsR(1),

                SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.duration != null && itm.duration! > 0){
                            final dur = Duration(milliseconds: itm.duration!);
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

  void deleteFavorite(Level2Model itm) async {
    itm.isFavorite = !itm.isFavorite;
    bool res = await FavoriteService.removeFavorite(itm.id!);

    if(!res){
      AppToast.showToast(context, AppMessages.operationFailed);
      return;
    }

    listItems.removeWhere((element) => element.id == itm.id);

    assistCtr.updateMain();
  }

  void onItemClick(Level2Model itm) {
    if(itm.type == Level2Types.video.type()){
      final inject = VideoPlayerPageInjectData();
      inject.srcAddress = itm.url!;
      inject.videoSourceType = VideoSourceType.network;

      AppRoute.pushNamed(context, VideoPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == Level2Types.audio.type()){
      final inject = AudioPlayerPageInjectData();
      inject.srcAddress = itm.url!;
      inject.audioSourceType = AudioSourceType.network;
      inject.title = '';//widget.injectData.level1model?.title;
      inject.subTitle = itm.title;

      AppRoute.pushNamed(context, AudioPlayerPage.route.name!, extra: inject);
      return;
    }

    if(itm.type == Level2Types.list.type()){
      final inject = ContentViewPageInjectData();
      inject.level2model = itm;

      AppRoute.pushNamed(context, ContentViewPage.route.name!, extra: inject);
      return;
    }
  }

  void fetchData() async {
    listItems.addAll(FavoriteService.getAllFavorites());

    for(final m in listItems){
      m.isFavorite = true;
    }

    isInFetchData = false;
    assistCtr.updateMain();
  }
}
