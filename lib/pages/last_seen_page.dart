import 'package:app/services/lastSeenService.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appThemes.dart';
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
import 'package:app/views/progressView.dart';
import 'package:iris_tools/widgets/irisImageView.dart';

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
      return ProgressView();
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(10),
              ),

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

                                  return SizedBox();
                                }
                            )
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12),

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
