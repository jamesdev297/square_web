import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/util/http_resource_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/locale_date.dart';
import 'package:square_web/widget/square/square_item.dart';

class ViewFullImagePage extends StatefulWidget with HomeWidget {
  final String imageUrl;
  final String? name;
  final int? msgSendTime;
  final PlayerNftModel? playerNftModel;

  ViewFullImagePage(this.imageUrl, { this.msgSendTime, this.playerNftModel, this.name });

  @override
  String pageName() => "ViewFullImagePage";

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  State<StatefulWidget> createState() => _ViewFullImagePageState();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.overlay;

  // @override
  // bool get dimmedBackground => true;

  // @override
  // EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;

  // @override
  // double? get maxWidth => PageSize.defaultOverlayMaxWidth;

  // @override
  // double? get maxHeight => PageSize.defaultOverlayMaxHeight;
}

class _ViewFullImagePageState extends State<ViewFullImagePage> with TickerProviderStateMixin{
  bool isExpired = false;
  PhotoViewController controller = PhotoViewController();

  bool get isProfile => widget.msgSendTime == null;
  bool get isPfp => isProfile && widget.playerNftModel != null;
  bool isOriginalSize = false;
  late ImageProvider networkImage;
  late Size imageSize;
  Uint8List? bytes;
  double scaleRatio = 0.25;

  @override
  void initState() {
    super.initState();
    if(widget.imageUrl.startsWith("http")) {
      networkImage = NetworkImage(widget.imageUrl);
    } else {
      bytes = base64Decode(widget.imageUrl);
      networkImage = MemoryImage(bytes!);
    }

    _getImage().then((value) => imageSize = value);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Size> _getImage() {
    Completer<Size> completer = Completer();
    networkImage.resolve(new ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {

    bool isMobile = screenWidthNotifier.value < maxWidthMobile;

    return Material(
      color: isMobile ? Colors.black : Colors.black.withOpacity(0.8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              if(isMobile)
                _buildPhotoView(isMobile)
              else
                Center(
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.6,
                    child: _buildPhotoView(isMobile)
                  ),
                ),
              _buildTopMenu(),
              _buildBottomMenu(isMobile, screenHeight)
            ],
          );
        }
      ),
    );
  }

  Widget _buildTopMenu() {
    late Widget child;
    if(isPfp)
      child = _buildPfpTopMenu();
    else if(isProfile)
      child = _buildProfileTopMenu();
    else
      child = _buildMessageTopMenu();

    return Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: Zeplin.size(160),
            child: Stack(
              children: [
                Transform.scale(
                  scaleX: 1.2,
                  child: Transform.translate(
                    offset: Offset(0, -2),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              // color: Colors.grey.withOpacity(Zeplin.sizeFactor),
                              spreadRadius: 15,
                              blurRadius: 40,
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(36)),
                  child: child,
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildBottomMenu(bool isMobile, double screenHeight) {
    if(!isMobile || isPfp)
      return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: Zeplin.size(160),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Transform.scale(
                  scaleX: 1.2,
                  child: Transform.translate(
                    offset: Offset(0, 2),
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              // color: Colors.grey.withOpacity(Zeplin.sizeFactor),
                              spreadRadius: 15,
                              blurRadius: 40,
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(isPfp)
                      Expanded(child: _buildPfpBottomMenu(isMobile)),
                    if(isPfp == false && isMobile == false)
                      Spacer(),
                    if(isMobile == false)
                      _buildNotMobileBottomMenu(screenHeight)
                  ],
                ),
              ),
            ],
          ),
        ),
      );

    return Container();
  }

  String getSquareName() {
    return widget.playerNftModel!.squareName ?? SquareModel.smallerWallet(widget.playerNftModel!.contractAddress);
  }

  Widget _buildPfpBottomMenu(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              SquareManager().clickSquare(widget.playerNftModel!.squareModel!, popBeforeWidget: true, joined: widget.playerNftModel!.joined == true);
            },
            child: SquareImage(widget.playerNftModel!.squareModel!, width: Zeplin.size(100), height: Zeplin.size(100))
          ),
        ),
        SizedBox(width: Zeplin.size(20)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(Zeplin.size(5)),
                      child: Icon28(widget.playerNftModel!.blockchainNetType.chainIcon),
                      decoration: new BoxDecoration(color: CustomColor.paleGrey, shape: BoxShape.circle)),
                  SizedBox(width: Zeplin.size(10)),
                  Text(getSquareName(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28)), overflow: TextOverflow.ellipsis),
                ],
              ),
              SizedBox(height: Zeplin.size(5)),
              Row(
                children: [
                  SizedBox(width: Zeplin.size(10)),
                  Icon24(Assets.img.ico_26_fre_we),
                  SizedBox(width: Zeplin.size(10)),
                  Text("${widget.playerNftModel!.memberCount ?? 0}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))),
                ],
              ),
            ],
          ),
        ),
        if(isMobile)
          Spacer()
        else
          SizedBox(width: Zeplin.size(68)),
      ],
    );
  }

  Widget _buildNotMobileBottomMenu(double screenHeight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              controller.scale = scaleRatio + controller.scale!;
            },
            child: Tooltip(message: L10n.common_54_plus, child: Icon46(Assets.img.ico_46_plus_bk))
          ),
        ),
        SizedBox(width: Zeplin.size(20)),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              double updatedScale = -scaleRatio + (controller.scale ?? 0);
              if(updatedScale > 0) {
                controller.scale = updatedScale;
              }
            },
            child: Tooltip(message: L10n.common_55_minus, child: Icon46(Assets.img.ico_46_minus_bk))
          ),
        ),
        SizedBox(width: Zeplin.size(20)),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              isOriginalSize = !isOriginalSize;

              if(isOriginalSize == true) {
                // controller.reset();
                final double _minScale = screenHeight / imageSize.height;
                controller.scale = _minScale;
              } else {
                controller.scale = null;
              }
            },
            child: Tooltip(message: isOriginalSize ? L10n.common_56_original_size : L10n.common_57_scale, child: Icon46(isOriginalSize ? Assets.img.ico_46_zoom_2_bk : Assets.img.ico_46_zoom_bk))),
        ),
        SizedBox(width: Zeplin.size(20)),
      ],
    );
  }

  Widget _buildPhotoView(bool isMobile) {

    return PhotoView.customChild(
      controller: controller,
      minScale: PhotoViewComputedScale.contained * 1.0,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      basePosition: Alignment.center,
      child: bytes != null ? Image.memory(bytes!, fit: BoxFit.contain, errorBuilder: _buildExpireImage):
          Image.network(widget.imageUrl, fit: BoxFit.contain, errorBuilder: _buildExpireImage)
    );
  }

  Widget _buildPfpTopMenu() {
    return Row(
      children: [
        SizedBox(width: Zeplin.size(46)),
        Spacer(),
        Text("${getSquareName()} #${widget.playerNftModel!.tokenId}", textAlign: TextAlign.center, style: TextStyle(fontSize: Zeplin.size(26), color: Colors.white, fontWeight: FontWeight.w500)),
        Spacer(),
        MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(child: Icon46(Assets.img.ico_46_close_we), onTap: () => HomeNavigator.pop())),
      ],
    );
  }

  Widget _buildProfileTopMenu() {
    return Row(
      children: [
        Spacer(),
        MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(child: Icon46(Assets.img.ico_46_close_we), onTap: () => HomeNavigator.pop())),
      ],
    );
  }

  Widget _buildMessageTopMenu() {
    return  Row(
      children: [
        isExpired == false ? MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () async {
                Map<String, dynamic>? map = await HttpResourceUtil.downloadFile(widget.imageUrl);

                if(map == null)
                  return;

                String ext = (map['content-type'] as String).split("/")[1];

                late MimeType mimeType;
                if(ext == "gif")
                  mimeType = MimeType.GIF;
                else
                  mimeType = MimeType.PNG;

                await FileSaver.instance.saveFile(LocaleDate().getDateMDY(widget.msgSendTime!), map['bytes'], ext, mimeType: mimeType);

              },
              child: Icon46(Assets.img.ico_46_download_we)),
        ) : SizedBox(width: Zeplin.size(46)),
        Spacer(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(widget.name ?? "", textAlign: TextAlign.center, style: TextStyle(fontSize: Zeplin.size(26), color: Colors.white, fontWeight: FontWeight.w500))),
            Center(child: Text(LocaleDate().getDateMDY(widget.msgSendTime!), textAlign: TextAlign.center, style: TextStyle(fontSize: Zeplin.size(26), color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        Spacer(),
        MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(child: Icon46(Assets.img.ico_46_close_we), onTap: () => HomeNavigator.pop())),
      ],
    );
  }

  Widget _buildExpireImage(BuildContext context, Object error, StackTrace? stackTrace) {

    isExpired = true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(Assets.img.ico_100_expired_pic, height: Zeplin.size(95), width: Zeplin.size(95)),
        SizedBox(height: Zeplin.size(19)),
        Text(L10n.common_46_expire, style: TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(30), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
      ],
    );
  }
}
