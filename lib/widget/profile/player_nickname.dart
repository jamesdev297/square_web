import 'package:flutter/material.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_edit_nickname_dialog.dart';

class PlayerNickname extends StatefulWidget {
  final ContactModel contactModel;
  final TextStyle? nicknameTextStyle;
  final PlayerProfileBloc? playerProfileBloc;

  PlayerNickname(this.contactModel, {Key? key, this.nicknameTextStyle, this.playerProfileBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerNicknameState();

}

class _PlayerNicknameState extends State<PlayerNickname> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    dynamic child = Row(
      children: [
        if(widget.contactModel.isCustomNickname == true)
          Icon46(Assets.img.ico_36_tag_2_gy),
        Text(widget.contactModel.smallerName, style: widget.nicknameTextStyle),
        // SizedBox(width: Zeplin.size(10)),
        // if(widget.contactModel.blockchainNetType != ChainNetType.ai)
        //   Icon36(Assets.img.ico_36_edit_gy)
      ],
    );

    if(widget.contactModel.blockchainNetType == ChainNetType.ai)
      return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: showEditNicknameDialog,
        child: child,
      ),
    );
  }

  void showEditNicknameDialog() {
    showDialog(
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      context: context,
      builder: (context) => SquareEditNicknameDialog(
        contactModel: widget.contactModel,
        context: context,
        playerProfileBloc: widget.playerProfileBloc
      ));
  }

}
