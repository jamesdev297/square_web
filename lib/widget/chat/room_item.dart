import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/align/align.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/message/message_model.dart';
import 'package:square_web/model/room_model.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/blue_dot.dart';
import 'package:square_web/widget/locale_date.dart';
import 'package:square_web/widget/profile/room_profile_image.dart';

class RoomItem extends StatefulWidget {
  final RoomModel model;
  final Function(String)? onTap;
  final bool? isSelectMode;
  final Function(RoomModel)? onPressed;

  RoomItem(this.model, this.onTap, { this.isSelectMode, this.onPressed });

  @override
  _RoomItemState createState() => _RoomItemState();
}

class _RoomItemState extends State<RoomItem> {

  RoomModel get model => widget.model;
  Function(String)? get onTap => widget.onTap;
  bool? get isSelectMode => widget.isSelectMode;
  Function(RoomModel)? get onPressed => widget.onPressed;
  Color backGroundColor = Colors.white;

  bool get isSelected => RoomManager().currentChatRoom?.roomId == model.roomId;
  bool isFirstBuild = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isFirstBuild = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<SelectedRoomBloc, UpdateState>(
      bloc: RoomManager().selectedRoomBloc,
      builder: (context, state) {

        if(backGroundColor == CustomColor.brightBlue && widget.model.roomId != RoomManager().currentChatRoom?.roomId) {
          backGroundColor = Colors.white;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        }

        return BlocBuilder<SelectedRoomBloc, UpdateState>(
          bloc: RoomManager().selectedRoomBloc,
          builder: (context, state) {

            if(state is UpdateInitial && state.param != null && state.param['roomId'] == model.roomId) {

              ContactModel? player = state.param['player'];
              model.isNftTargetProfileImg = player?.profileImgNftId != null;
              model.targetProfileImgUrl = player?.profileImgUrl;
              model.searchName = player?.smallerName;
            }

            return ListTile(
              hoverColor:  RoomManager().currentChatRoom?.roomId == model.roomId ? CustomColor.brightBlue : CustomColor.paleGrey,
              tileColor: RoomManager().currentChatRoom?.roomId == model.roomId ? CustomColor.brightBlue : Colors.white,
              leading: RoomProfileImage(roomModel: model),
              title: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    if(model.isKnown == false)
                      Wrap(
                        children: [
                          Icon36(Assets.img.ico_36_gy),
                          SizedBox(width: Zeplin.size(6)),
                        ],
                      ),
                    Text(model.smallerSearchName ?? "",
                      style: TextStyle(fontSize: Zeplin.size(28), color: Colors.black, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              subtitle: model.lastMsg != null ? _buildTwinRoomSubTitle() : Text(""),
              trailing: isSelectMode == null ? _trailTextWidget(model.isUnread ?? false) : _trailWidget(),
              contentPadding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(6)),
              onTap: isSelectMode == true ? null : () {
                onTap?.call(model.roomId!);
              });
          }
        );
      }
    );
  }

  Widget _buildTwinRoomSubTitle() {
    switch (model.lastMsg!.status) {
      case MessageStatus.normal:
        return Text(
          (model.lastMsg!.getSubtitle())!,
          style: greyText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return Text("");
    }
  }

  Widget _trailWidget() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        if(isSelectMode == true)
          _trailButtonWidget()
        else
          FadeInRightBig(
            from: 20,
            duration: Duration(milliseconds: isFirstBuild == true ? 0 : 300),
            child: _trailTextWidget(model.isUnread ?? false)
          ),
      ],
    );
  }

  Widget _trailTextWidget(bool isUnread) {
    return ColumnRight(
      children: <Widget>[
        SizedBox(height: Zeplin.size(15)),
        Text(model.lastMsgTimeOrRegTime != null ? "${LocaleDate().expressionMsgTime(model.lastMsgTimeOrRegTime)}" : "", style: systemMessageTimeStyle),
        SizedBox(height: Zeplin.size(20)),
        if (isUnread == true) BlueDot(),
      ]
    );
  }
  
  Widget _trailButtonWidget() {
    return FadeInRight(
      from: 10,
      duration: Duration(milliseconds: 300),
      child: SizedBox(
        width: Zeplin.size(200),
        child: PebbleRectButton(
          borderColor: CustomColor.paleGrey,
          backgroundColor: CustomColor.paleGrey,
          onPressed: isSelectMode == true ? () => onPressed!(model) : null,
          child: Center(child: Text(model.isBlocked ? L10n.profile_01_06_unblock : L10n.archive_05_01_unarchive, style: TextStyle(color: Colors.black, fontSize: Zeplin.size(26), fontWeight: FontWeight.w500))),
        ),
        height: Zeplin.size(60),
      ),
    );
  }
}
