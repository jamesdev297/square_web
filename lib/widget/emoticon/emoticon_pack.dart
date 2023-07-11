import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:square_web/bloc/switch_bloc.dart';
import 'package:square_web/bloc/switch_bloc_event.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/emoticon/emoticon_pack_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/util/http_resource_util.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class EmoticonPack extends StatefulWidget {
  final EmoticonPackModel emoticonPack;
  final bool isSelected;
  final bool isMobile;
  EmoticonPack(this.emoticonPack, this.isSelected, this.isMobile);

  @override
  State<EmoticonPack> createState() => _EmoticonPackState();
}

class _EmoticonPackState extends State<EmoticonPack> {
  late Completer<dynamic> loadPackCompleter;

  Future<dynamic> loadEmoticonPack() async {
    final yaml = await HttpResourceUtil.downloadYaml(widget.emoticonPack.metaDataPath);
    if(yaml == null)
      return null;

    int? emoticonCount = yaml["emoticonCount"];

    if(emoticonCount == null) {
      LogWidget.error("EmoticonPackFactory.make err : length must be exist");
      return null;
    }
    ui.Image? image = await HttpResourceUtil.downloadImage(widget.emoticonPack.imagePath);
    // EmoticonManager().loadedEmoticonPackMap.putIfAbsent(emoticonPackId, () => emoticonPackModel);
    return {
      "image" : image,
      "emoticonCount" : emoticonCount,
      "imageColumn" : yaml["imageColumn"] ?? EmoticonConfig.defaultEmoticonPackColumn,
      "imageRow" : yaml["imageRow"] ?? EmoticonConfig.defaultEmoticonPackColumn,
    };
  }

  @override
  void initState() {
    super.initState();
    loadPackCompleter = Completer();
    loadPackCompleter.complete(loadEmoticonPack());
  }

  Widget _buildInternal(Map<String, dynamic> data, double pageWidth) {
    ui.Image? image = data["image"];
    int? emoticonCount = data["emoticonCount"];
    int imageColumn = data["imageColumn"];
    int imageRow = data["imageRow"];

    if(image != null && emoticonCount != null) {
      int maxColumnCount = (pageWidth / (EmoticonConfig.emoticonPackImageSize + EmoticonConfig.emoticonPackPaddingSize)).round();

      return GridView.builder(
        padding: EdgeInsets.only(bottom: Zeplin.size(30)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: maxColumnCount),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              String emoticonId = "${widget.emoticonPack.emoticonPackId}/$index";

              // EmoticonModel? emoticonModel;
              // if(EmoticonManager().isLoadedEmoticon(emoticonId)) {
              //   emoticonModel = EmoticonManager().getEmoticon(emoticonId);
              // } else {
              // emoticonModel = await EmoticonManager().loadEmoticonById(emoticonId);
              // }

              BlocManager.getBloc<ShowEmoticonExampleBloc>()!.add(OnEvent(param: emoticonId));
            },
            child: EmoticonThumbnail(
                image: image,
                width: image.width/imageColumn,
                height: image.height/imageRow,
                index: index,
                column: imageColumn
            ),
          );
        },
        itemCount: emoticonCount,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if(widget.isSelected) {
      child = LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth = constraints.maxWidth;
          return FutureBuilder<dynamic>(
            future: loadPackCompleter.future,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return _buildInternal(snapshot.data!, pageWidth);
              }
              if(snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              }
              return Container();
            },
          );
        },
      );
    }

    return Center(
      child: child ?? _buildLoading()
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      width: 50,
      height: 50,
      child: SquareCircularProgressIndicator(),
    );
  }
}

class EmoticonThumbnail extends StatelessWidget {
  final ui.Image image;
  final double width;
  final double height;
  final int index;
  final int column;

  EmoticonThumbnail({
    required this.image,
    required this.width,
    required this.height,
    required this.index,
    required this.column
  });


  @override
  Widget build(BuildContext context) {
    double y = (index~/column)*width;
    double x = height*(index%column);
    return Align(
        alignment: Alignment.topLeft,
        child: CustomPaint(painter: EmoticonPainter(image, x, y, width, height)));
  }
}

class EmoticonPainter extends CustomPainter {
  ui.Image? image;
  double width;
  double height;
  double x;
  double y;

  EmoticonPainter(this.image, this.x, this.y, this.width, this.height);


  @override
  void paint(Canvas canvas, Size size) {
    final imageSize = Size(width, width);
    final src = Offset(x,y) & imageSize;
    final dst = Offset.zero &
      Size(EmoticonConfig.emoticonPackImageSize, EmoticonConfig.emoticonPackImageSize);
    canvas.translate(EmoticonConfig.emoticonPackPaddingSize/2, EmoticonConfig.emoticonPackPaddingSize/2);
    canvas.drawImageRect(image!, src, dst, EmoticonConfig.paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}