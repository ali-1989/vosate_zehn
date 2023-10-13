import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:photo_view/photo_view.dart';

import 'package:app/structures/enums/enums.dart';

/// Usage:
/// final view = FullScreenImage();
/// AppRoute.pushPage(context, view);

///=============================================================================
class FullScreenImage extends StatefulWidget {
  late final ImageType imageType;
  late final dynamic imageObj;
  final String? heroTag;
  final String? info;
  final Color? appBarColor;
  final TextStyle? infoStyle;

  FullScreenImage({
    Key? key,
    required this.imageType,
    required this.imageObj,
    this.heroTag,
    this.info,
    this.appBarColor,
    this.infoStyle,
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FullScreenImageState();
  }
}
///=============================================================================
class FullScreenImageState extends State<FullScreenImage> {
  ImageProvider? pic;
  TextStyle? infoStyle;

  @override
  void initState() {
    super.initState();

    infoStyle = widget.infoStyle?? const TextStyle(color: Colors.white);

    switch(widget.imageType){
      case ImageType.file:
        pic = FileImage(
          widget.imageObj,
        );
        break;
      case ImageType.bytes:
        pic = MemoryImage(
          widget.imageObj,
        );
        break;
      case ImageType.asset:
        pic = AssetImage(
          widget.imageObj,
        );
        break;
      case ImageType.network:
        pic = NetworkImage(
          widget.imageObj,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Widget pic;
    /*
    ImageType.File:
        pic = Image.file(
          widget.imageObj,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        );
     */

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
          backgroundColor: widget.appBarColor,
        iconTheme: IconThemeData(color: ColorHelper.getUnNearColor(widget.appBarColor?? Colors.black, Colors.black, Colors.white)),
      ),
      body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: PhotoView(
                imageProvider: pic,
                basePosition: Alignment.center,
                disableGestures: false,
                enableRotation: true,
                gaplessPlayback: true,
                maxScale: 3.0,
                gestureDetectorBehavior: HitTestBehavior.translucent,
                //initialScale: 1.0,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag?? ''),
              ),
            ),


            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Builder(
                builder: (ctx){
                  if(widget.info == null){
                    return const SizedBox();
                  }

                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(70), //AppThemes.currentTheme.inactiveTextColor.withAlpha(200),
                      //borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            overflow: TextOverflow.fade,
                            maxLines: 6,
                            text: TextSpan(
                              text: widget.info,
                              style: infoStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void update(){
    if(mounted){
      setState(() {});
    }
  }
}
