import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';

import 'package:app/structures/enums/enums.dart';

/// Usage:
/// final view = ImageFullScreen(heroTag: '');
/// AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);

class ImageFullScreenInjectData {
  late ImageType imageType;
  late dynamic imageObj;
  late String heroTag;
  String? info;
  TextStyle? infoStyle;
}
///---------------------------------------------------------------------------------
class ImageFullScreen extends StatefulWidget{

  final ImageFullScreenInjectData injectData;

  ImageFullScreen({
    Key? key,
    required this.injectData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImageFullScreenState();
  }
}
///===============================================================================================================
class ImageFullScreenState extends State<ImageFullScreen> {
  ImageProvider? pic;
  TextStyle? infoStyle;

  @override
  void initState() {
    super.initState();

    infoStyle = widget.injectData.infoStyle?? const TextStyle(color: Colors.white);

    switch(widget.injectData.imageType){
      case ImageType.file:
        pic = FileImage(
          widget.injectData.imageObj,
        );
        break;
      case ImageType.bytes:
        pic = MemoryImage(
          widget.injectData.imageObj,
        );
        break;
      case ImageType.asset:
        pic = AssetImage(
          widget.injectData.imageObj,
        );
        break;
      case ImageType.network:
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
      appBar: AppBar(),
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
                heroAttributes: PhotoViewHeroAttributes(tag: widget.injectData.heroTag,),
              ),
            ),


            Positioned(
                bottom: 0, left: 0, right: 0,
                child: Builder(
                  builder: (ctx){
                    if(widget.injectData.info == null){
                      return SizedBox();
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
                                text: widget.injectData.info,
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
