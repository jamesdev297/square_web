import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/profile/profile_image.dart';

class ContactItem extends StatefulWidget {
  final ContactModel contactModel;
  final MemberStatus? squareMemberStatus;
  final bool isSelected;
  final VoidCallback? onTap;
  Widget? trailingWidget;
  final bool forceShowTrailing;

  ContactItem({required this.contactModel, this.squareMemberStatus, this.isSelected = false, this.onTap, this.trailingWidget, this.forceShowTrailing = false});

  @override
  _ContactItemState createState() => _ContactItemState();
}

class _ContactItemState extends State<ContactItem> {
  bool isAcceptButtonClick = false;
  double height = Zeplin.size(67);
  Color? bgColorTrailingWidget;
  Color? borderColor;
  Widget? textWidget;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: widget.isSelected ? CustomColor.brightBlue : CustomColor.paleGrey,
      onTap: widget.onTap,
      child: FutureBuilder(
        future: widget.contactModel.loadComplete.future,
        builder: (context, snapshot) {
          return Container(
            color: widget.isSelected ? CustomColor.brightBlue : null,
            height: Zeplin.size(128),
            padding: EdgeInsets.only(left: Zeplin.size(33), right: Zeplin.size(33), top: Zeplin.size(19), bottom: Zeplin.size(19)),
            child: Row(
                children: <Widget>[
                  ProfileImage(contactModel: widget.contactModel, size: 93, isEdit: false, isShowBlueDot: widget.contactModel.relationshipStatus == RelationshipStatus.blocked ? false : true),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  if(widget.contactModel.isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon36(Assets.img.ico_36_me_bk),
                                    ),
                                  Flexible(
                                    child: Text(widget.contactModel.smallerName, style: TextStyle(fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: CustomColor.darkGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  if(widget.squareMemberStatus == MemberStatus.restricted)
                                    Padding(
                                      padding: EdgeInsets.only(left:Zeplin.size(5)),
                                      child: Icon36(Assets.img.ico_36_block_gy),
                                    ),
                                ],
                              ),
                              SizedBox(height: Zeplin.size(7)),
                              Text(widget.contactModel.statusMessage ?? "", style: TextStyle(fontSize: Zeplin.size(24), fontWeight: FontWeight.w500, color: CustomColor.taupeGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        trailingWidget(),
                      ],
                    ),
                  ),
                ],
              ),
          );
        }
      ),
    );
  }

  Widget trailingWidget() {
    if (widget.forceShowTrailing == false && MeModel().playerId == widget.contactModel.playerId)
      return Container();

    if (widget.trailingWidget != null) {
      return widget.trailingWidget!;
    } else {
      return Container();
    }
  }
}
