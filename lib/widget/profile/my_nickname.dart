import 'package:flutter/material.dart';
import 'package:square_web/model/me_model.dart';

class MyNickname extends StatefulWidget {
  final Key? key;
  TextStyle? textStyle;

  MyNickname({this.key, this.textStyle}):super(key: key);

  @override
  State<StatefulWidget> createState() => _MyNicknameState();

}

class _MyNicknameState extends State<MyNickname> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Center(child: Text(MeModel().contact!.smallerName, style: widget.textStyle, overflow: TextOverflow.ellipsis)));
  }
}