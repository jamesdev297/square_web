/*
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/profile/player_notice_bloc.dart';
import 'package:square_web/bloc/profile/player_notice_event.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/player_notice_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/util/date_util.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/pebble_widget.dart';
import 'package:square_web/widget/toast/center_toast_overlay.dart';

class NoticePage extends StatefulWidget with HomeWidget {
  @override
  State<StatefulWidget> createState() => NoticePageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    title: Text(
      L10n.notice,
      style: TextStyle(fontFamily: Zeplin.robotoBold, fontSize: Zeplin.size(32)),
    ),
    leftMenu: MenuPack.backButton(),
    padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19))
  );

  @override
  HomeWidgetType get widgetDepth => HomeWidgetType.twoDepthPopUp;
}

class NoticePageState extends State<NoticePage> with TickerProviderStateMixin {
  PlayerNoticeBloc _noticeBloc = BlocManager.getBloc()!;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _noticeBloc.add(LoadNewPlayerNoticeEvent(
        _noticeBloc.state.list.firstOrNull?.sendTime ??
        DateTime.now().millisecondsSinceEpoch));

    _scrollController.addListener(() {
      if (_scrollController.offset > 0.9) {
        if (_noticeBloc.state.nextCursor != null)
          _noticeBloc.add(LoadPrevPlayerNoticeEvent(_noticeBloc.state.nextCursor!));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _noticeBloc.add(InitPlayerNoticeEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.only(top: Zeplin.size(197)),
        child: BlocBuilder<PlayerNoticeBloc, PlayerNoticeState>(
            bloc: _noticeBloc,
            builder: (context, state) {
              PlayerNoticeBloc.removeBlueDot();

              List<PlayerNotice> list = state.list.toList();
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context, int index) {
                  return NoticeTile(list[index], context, _noticeBloc);
                },
                itemCount: list.length,
              );
            }),
      ),
    );
  }

}

class NoticeTile extends StatelessWidget {
  static final _defaultPebbleAvatar = PebbleAvatar(
    child: Stack(
      alignment: Alignment.center,
      children: [Icon46(Assets.img.ico46_alarm_bla)],
    ),
    drawBorder: true,
    size: Zeplin.size(98),
  );

  static Widget _defaultDeleteIcon(PlayerNotice playerNotice, BuildContext buildContext, PlayerNoticeBloc playerNoticeBloc) {
    return IconButton(
      onPressed: () {
        playerNoticeBloc.add(RemovePlayerNoticeEvent(playerNotice.sendTime));
        CenterToastOverlay.show(buildContext: buildContext, text: L10n.removeComplete);
      },
      icon: Icon46(Assets.img.ico_46_close_bla)
    );
  }


  final PebbleAvatar pebbleAvatar;
  final TextSpan? titleText;
  final Widget? titleTextWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final PlayerNotice? notice;
  late ValueNotifier<bool> isRead;

  NoticeTile._(this.notice, this.pebbleAvatar, {this.titleText, this.titleTextWidget, this.onTap, this.trailing}) {
    this.isRead = ValueNotifier(notice?.status == 'read');
    if(notice != null)
      this.titleText?.children?.add(timeTextSpan(notice!.sendTime));
  }

  NoticeTile._default()
      : this.notice = null,
        this.pebbleAvatar = _defaultPebbleAvatar,
        this.titleText = null,
        this.titleTextWidget = null,
        this.trailing = null,
        this.onTap = null;

  static TextSpan timeTextSpan(int sendTime) =>
      TextSpan(
          text:
          " ${DateUtil.dateDurationToString(Duration(milliseconds: DateTime
              .now()
              .millisecondsSinceEpoch - sendTime))}",
          style: TextStyle(color: CustomColor.blueyGrey));

  factory NoticeTile(PlayerNotice? notice, BuildContext buildContext, PlayerNoticeBloc playerNoticeBloc) {
    switch (notice?.noticeType) {
      case NoticeType.kingOfSquare:
        Map<String, dynamic> content = json.decode(notice!.context);
        String squareId = content["squareId"];
        String title = content["title"];
        return NoticeTile._(
          notice,
          PebbleAvatar(
            child: Stack(
              children: [
                Container(
                  color: CustomColor.lemon,
                ),
                Center(child: Image.asset(Assets.img.ico_46_king_bla, width: Zeplin.size(46),))
              ],
            ),
            size: Zeplin.size(98),
          ),
          titleText: TextSpan(children: [
            TextSpan(text: "${L10n.becomeKingOfSquare(title)}".breakWord),
          ]),
          onTap: () {
          },
          trailing: _defaultDeleteIcon(notice, buildContext, playerNoticeBloc),
        );
      break;
      case NoticeType.currencyGetOrRetrieve: {
        Map<String, dynamic> content = json.decode(notice!.context);
        String currencyCode = content["currencyCode"];
        int amount = content["amount"];
        if(amount > 0) {
          return NoticeTile._(
            notice,
            _defaultPebbleAvatar,
            titleText: TextSpan(children: [
              TextSpan(text: "${L10n.flagGetNoticeTileTxt(amount)}".breakWord),
            ]),
            onTap: () => {},
            trailing: _defaultDeleteIcon(notice, buildContext, playerNoticeBloc),
          );
        }
        return NoticeTile._(
          notice,
          _defaultPebbleAvatar,
          titleText: TextSpan(children: [
            TextSpan(text: "${L10n.flagRetrieveNoticeTileTxt(-amount)}".breakWord),
          ]),
          onTap: () => {},
          trailing: _defaultDeleteIcon(notice, buildContext, playerNoticeBloc),
        );
      }
      default:
        return NoticeTile._(
          notice,
          _defaultPebbleAvatar,
          titleText: TextSpan(text: "${notice?.context}"),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isRead,
        builder: (context, value, child) {
          return Container(
        color: value ? null : CustomColor.azureBlue.withOpacity(0.1),
        child: InkWell(
          splashColor: CustomColor.azureBlue.withOpacity(0.1),
          highlightColor: CustomColor.azureBlue.withOpacity(0.1),
          onTap: onTap,
          onLongPress: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
            child: Container(
              height: Zeplin.size(148),
              child: Row(children: [
                pebbleAvatar,
                SizedBox(
                  width: Zeplin.size(25),
                ),
                if(titleText != null)
                  Expanded(
                    child: Text.rich(
                      titleText!,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(24)),
                    ),
                  ),
                if(titleTextWidget != null)
                  Expanded(child: titleTextWidget!),
                if (trailing != null) SizedBox(width: Zeplin.size(20)),
                if (trailing != null) trailing!
              ]),
            ),
          ),
        ),
      );
        }
    );
  }
}
*/
