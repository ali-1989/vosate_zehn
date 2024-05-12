import 'package:app/tools/app_tools.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';

import 'package:app/services/favorite_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/views/baseComponents/appbar_builder.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/wait_to_load.dart';

class FavoritesPage extends StatefulWidget{

  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}
///=============================================================================
class _FavoritesPageState extends StateSuper<FavoritesPage> {
  List<SubBucketModel> listItems = [];

  @override
  void initState(){
    super.initState();

    assistCtr.addState(AssistController.state$loading);
    fetchData();
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
    if(assistCtr.hasState(AssistController.state$loading)) {
      return const WaitToLoad();
    }

    if(listItems.isEmpty) {
      return const EmptyData();
    }

    return GridView.builder(
      itemCount: listItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 200),
      itemBuilder: (ctx, idx){
        return buildListItem(idx);
      },
    );
  }

  Widget buildListItem(int idx){
    final itm = listItems[idx];

    return InkWell(
      onTap: (){
        AppTools.onItemClick(context, itm);
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
              child: Column(
                children: [
                  Stack(
                    children: [
                      Builder(
                        builder: (ctx){
                          if(itm.imageModel?.url != null){
                            return IrisImageView(
                              width: double.infinity,
                              height: 100,
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
                          left: 0,
                          child: Builder(
                              builder: (context) {
                                if(itm.type == SubBucketTypes.video.id()){
                                  return Theme(
                                    data: AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent),
                                    child: Chip(
                                      backgroundColor: Colors.grey.withAlpha(160),
                                      shadowColor: Colors.transparent,
                                      visualDensity: VisualDensity.compact,
                                      elevation: 0,
                                      label: const Icon(AppIcons.videoCamera, size: 15, color: Colors.white),
                                    ),
                                  );
                                }

                                if(itm.type == SubBucketTypes.audio.id()){
                                  return Chip(
                                    backgroundColor: Colors.black.withAlpha(200),
                                    shadowColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                    elevation: 0,
                                    label: const Icon(AppIcons.headset, size: 15, color: Colors.white),
                                  );
                                }

                                return const SizedBox();
                              }
                          )
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(itm.title, maxLines: 1).bold().fsR(1),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: Row(
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
                              deleteFavorite(itm);
                            },
                            icon: const Icon(AppIcons.delete, size: 20, color: Colors.red,)
                        )
                      ],
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

    assistCtr.updateHead();
  }

  void fetchData() async {
    listItems.addAll(FavoriteService.getAllFavorites());

    for(final m in listItems){
      m.isFavorite = true;
    }

    assistCtr.clearStates();
    assistCtr.updateHead();
  }
}
