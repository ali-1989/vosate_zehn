import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:iris_tools/api/duration/durationFormatter.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/iris_image_view.dart';
import 'package:iris_tools/widgets/keep_alive_wrap.dart';

import 'package:app/managers/advertising_manager.dart';
import 'package:app/managers/carousel_manager.dart';
import 'package:app/managers/media_manager.dart';
import 'package:app/services/favorite_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/enums.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/models/subBuketModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_broadcast.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/app_tools.dart';
import 'package:app/views/states/empty_data.dart';
import 'package:app/views/states/error_occur.dart';
import 'package:app/views/states/wait_to_load.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
///=============================================================================
class _HomePageState extends StateSuper<HomePage> {
  Requester requester = Requester();
  bool isInFetchData = true;
  String state$fetchData = 'state_fetchData';
  late ThemeData chipTheme;
  List<SubBucketModel> newItems = [];
  List<SubBucketModel> meditationItems = [];
  List<SubBucketModel> videoItems = [];

  @override
  void initState(){
    super.initState();

    chipTheme = AppThemes.instance.themeData.copyWith(canvasColor: Colors.transparent);
    AppBroadcast.newAdvNotifier.addListener(updateOnAdvNotifier);
    AppBroadcast.changeFavoriteNotifier.addListener(updateOnFavoriteNotifier);
    requestData();
  }

  @override
  void dispose(){
    requester.dispose();
    AppBroadcast.newAdvNotifier.removeListener(updateOnAdvNotifier);
    AppBroadcast.changeFavoriteNotifier.removeListener(updateOnFavoriteNotifier);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            body: buildBody(),
          );
        }
    );
  }

  Widget buildBody(){
    if(isInFetchData) {
      return const WaitToLoad();
    }

    if(!assistCtr.hasState(state$fetchData)){
      return ErrorOccur(onTryAgain: tryLoadClick);
    }

    if(newItems.isEmpty && meditationItems.isEmpty){
      return const EmptyData();
    }

    return ListView(
      addAutomaticKeepAlives: true,
     children: [
       buildCarousel(),
       buildNews(),
       buildAdv1(),
       buildMeditation(),
       buildVideo(),
       buildAdv2(),
     ],
    );
  }

  Widget buildCarousel(){
    return KeepAliveWrap(
      child: Builder(
        builder: (ctx){
          final sliders = CarouselManager.getCarousel();

          if(sliders.isEmpty){
            return const SizedBox();
          }

          return CarouselSlider(
            options: CarouselOptions(
                height: 180.0,
              autoPlay: true,
              autoPlayAnimationDuration: const Duration(seconds: 2),
              autoPlayInterval: const Duration(seconds: 8),
              reverse: true,
              viewportFraction: 1.0,
            ),
            items: sliders,
          );
        },
      ),
    );
  }

  Widget buildAdv1(){
    return KeepAliveWrap(
      child: Builder(
        builder: (ctx){
          final adv = AdvertisingManager.getAdv1();

          if(adv == null || adv.mediaModel == null){
            return const SizedBox();
          }

          return GestureDetector(
            onTap: (){
              AdvertisingManager.onAdvertisingClick(adv);
            },
            child: IrisImageView(
              height: 170,
              url: adv.mediaModel!.url,
              fit: BoxFit.fill,
              imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
            ),
          );
        },
      ),
    );
  }

  Widget buildAdv2(){
    return KeepAliveWrap(
      child: Builder(
        builder: (ctx){
          final adv = AdvertisingManager.getAdv2();

          if(adv == null || adv.mediaModel == null){
            return const SizedBox();
          }

          return GestureDetector(
            onTap: (){
              AdvertisingManager.onAdvertisingClick(adv);
            },
            child: IrisImageView(
              height: 170,
              url: adv.mediaModel!.url,
              fit: BoxFit.fill,
              imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
            ),
          );
        },
      ),
    );
  }

  /*Widget buildAdv3(){
    return Builder(
      builder: (ctx){
        final adv = AdvertisingManager.getAdv3();

        if(adv == null || adv.mediaModel == null){
          return SizedBox();
        }
        return GestureDetector(
          onTap: (){
            if(adv.clickUrl?.isNotEmpty?? false){
              UrlHelper.launchLink(adv.clickUrl!);
            }
          },
          child: IrisImageView(
            height: 170,
            url: adv.mediaModel!.url,
            fit: BoxFit.fill,
            imagePath: AppDirectories.getSavePathMedia(adv.mediaModel, SavePathType.anyOnInternal, null),
          ),
        );
      },
    );
  }*/

  Widget buildNews(){
    return Builder(
      builder: (ctx){
        if(newItems.isEmpty){
          return const SizedBox();
        }

        return Column(
          children: [
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Chip(
                    backgroundColor: AppThemes.instance.currentTheme.differentColor,
                      label: const Text('جدیدترین ها').bold().boldFont().color(Colors.white)
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 172,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                  itemCount: newItems.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (ctx, idx){
                    final itm = newItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildMeditation(){
    return Builder(
      builder: (ctx){
        if(meditationItems.isEmpty){
          return const SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Chip(
                      backgroundColor: AppThemes.instance.currentTheme.differentColor,
                      label: const Text('مدیتیشن').bold().boldFont().color(Colors.white)
                  ),
                ),
                TextButton(
                  onPressed: moreMeditation,
                  child: const Text('بیشتر').fsR(1).color(Colors.lightBlue),
                ),
              ],
            ),

            SizedBox(
              height: 172,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: meditationItems.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (ctx, idx){
                    final itm = meditationItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildVideo(){
    return Builder(
      builder: (ctx){
        if(videoItems.isEmpty){
          return const SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10.0),
                  child: Chip(
                      backgroundColor: AppThemes.instance.currentTheme.differentColor,
                      label: const Text('ویدئو').bold().boldFont().color(Colors.white)
                  ),
                ),
                TextButton(
                  onPressed: moreVideo,
                  child: const Text('بیشتر').fsR(1).color(Colors.lightBlue),
                ),
              ],
            ),

            SizedBox(
              height: 172,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videoItems.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (ctx, idx){
                    final itm = videoItems[idx];

                    return buildListItem(itm);
                  }
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget buildListItem(SubBucketModel itm){
    return KeepAliveWrap(
      child: SizedBox(
        width: 170,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: InkWell(
            onTap: (){
              AppTools.onItemClick(context, itm);
            },
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
                      /// logo, icons
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

                          /// video / audio icon
                          Positioned(
                              top: 0,
                              left: 0,
                              child: Builder(
                                  builder: (context) {
                                    if(itm.type == SubBucketTypes.video.id()){
                                      return Theme(
                                        data: chipTheme,
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

                          /// vip
                          Positioned(
                              top: 3,
                              right: 3,
                              child: Builder(
                                  builder: (context) {
                                    if(itm.isVip){
                                      return Image.asset(AppImages.vip1, width: 30, height: 30);
                                    }

                                    return const SizedBox();
                                  }
                              )
                          ),
                        ],
                      ),

                      /// title
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(itm.title, maxLines: 1).bold(),
                      ),

                      /// duration , like icon
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
                                splashRadius: 18,
                                visualDensity: VisualDensity.compact,
                                iconSize: 18,
                                onPressed: (){
                                  setFavorite(itm);
                                },
                                icon: Icon(itm.isFavorite ? AppIcons.heartSolid: AppIcons.heart,
                                  size: 18,
                                  color: itm.isFavorite ? Colors.red: Colors.black,
                                )
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateOnFavoriteNotifier(){
    for(final k in newItems){
      k.isFavorite = FavoriteService.isFavorite(k.id!);
    }

    for(final k in meditationItems){
      k.isFavorite = FavoriteService.isFavorite(k.id!);
    }

    for(final k in videoItems){
      k.isFavorite = FavoriteService.isFavorite(k.id!);
    }

    assistCtr.updateHead();
  }

  void updateOnAdvNotifier(){
    assistCtr.updateHead();
  }

  void moreMeditation(){
    AppBroadcast.layoutPageKey.currentState?.gotoPage(1);
  }

  void moreVideo(){
    AppBroadcast.layoutPageKey.currentState?.gotoPage(4);
  }

  void tryLoadClick() async {
    isInFetchData = true;
    assistCtr.updateHead();

    requestData();
  }

  void onLoadingMoreCall(){
    requestData();
  }

  void setFavorite(SubBucketModel itm) async {
    itm.isFavorite = !itm.isFavorite;
    bool res;

    if(itm.isFavorite){
      res = await FavoriteService.addFavorite(itm);
    }
    else {
      res = await FavoriteService.removeFavorite(itm.id!);
    }

    if(res){
      if(itm.isFavorite){
        AppToast.showToast(context, AppMessages.isAddToFavorite);
      }
    }
    else {
      AppToast.showToast(context, AppMessages.operationFailed);
    }

    //this is will call by broadcast : assistCtr.updateHead();
  }

  void requestData() async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'get_home_page_data';
    js[Keys.requesterId] = SessionService.getLastLoginUser()?.userId;

    requester.httpRequestEvents.onFailState = (req, r) async {
      isInFetchData = false;
      assistCtr.removeStateAndUpdateHead(state$fetchData);
      return true;
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      isInFetchData = false;

      final List mediaList = data['media_list']?? [];
      final List list = data['new_list']?? [];
      final List mList = data['new_meditation_list']?? [];
      final List vList = data['new_video_list']?? [];

      MediaManager.addItemsFromMap(mediaList);
      MediaManager.sinkItems(MediaManager.mediaList);

      for(final m in list){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);
        newItems.add(itm);
      }

      for(final m in mList){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);

        meditationItems.add(itm);
      }

      for(final m in vList){
        final itm = SubBucketModel.fromMap(m);
        itm.isFavorite = FavoriteService.isFavorite(itm.id!);
        itm.imageModel = MediaManager.getById(itm.coverId);
        itm.mediaModel = MediaManager.getById(itm.mediaId);
        videoItems.add(itm);
      }

      assistCtr.addStateAndUpdateHead(state$fetchData);
    };

    requester.bodyJson = js;
    requester.prepareUrl();
    requester.request();
  }
}
