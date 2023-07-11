import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/emoticon/emoticon_pack_model.dart';
import 'package:square_web/util/http_resource_util.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';


class EmoticonPackIcon extends StatefulWidget {
  final EmoticonPackModel emoticonPack;
  final bool isSelectedPage;
  final VoidCallback onTap;

  EmoticonPackIcon({required this.emoticonPack, required this.isSelectedPage, required this.onTap});

  @override
  State<EmoticonPackIcon> createState() => _EmoticonPackIconState();
}

class _EmoticonPackIconState extends State<EmoticonPackIcon> {
  late Completer<Uint8List?> completer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    completer = Completer();
    rootBundle.load(widget.emoticonPack.packIconPath).then((value) {
      completer.complete(value.buffer.asUint8List());
    });
  }

  Widget _buildIcon(Uint8List bytes) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: Image.memory(bytes, width: Zeplin.size(57)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Zeplin.size(76),
      decoration: BoxDecoration(color: widget.isSelectedPage ? CustomColor.paleGreyDark : null),
      child:  FutureBuilder<Uint8List?>(
        future: completer.future,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data != null) {
              return _buildIcon(snapshot.data!);
            }
          }
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SquareCircularProgressIndicator());
          }
          return Container();
        },
      )
    );
  }
}

