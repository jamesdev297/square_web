/*
import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/alarm_settings_model.dart';
import 'package:square_web/service/push_manager.dart';
import 'package:square_web/widget/my_profile_toggle_button.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class AlarmSettingPage extends StatefulWidget with HomeWidget {
  @override
  State<StatefulWidget> createState() => AlarmSettingPageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    leftMenu: MenuPack.backButton(),
    title: Text(L10n.alarmSettings, style: centerTitleTextStyle),
    padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19))
  );
}

class AlarmSettingPageState extends State<AlarmSettingPage> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    PushManager().getAlarmSettings().then((_) {
      isLoading = false;
      updateDim();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  ValueNotifier<bool> onOffDim = ValueNotifier(false);
  void updateDim() async => onOffDim.value = !(await PushManager().isGrantedReceiveAlarm);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      isLoading == true ?
        Center(
          child: SquareCircularProgressIndicator(progressIndicatorSize: ProgressIndicatorSize.size80),
        ) : Column(
        children: [
      SizedBox(height: Zeplin.size(200)),
      _contentWithTrailingListTile(
        L10n.allAlarm,
        MyProfileToggleButton(
          value: PushManager.currentSettings.allAlarm!,
          onPressed: (value) async {

            AlarmSettings? setAlarms = value ? await PushManager().allowReceiveAlarm() : await PushManager().notAllowReceiveAlarm();

            if (setAlarms == null) {
              LogWidget.error("Allow Receive alarm fail.");
              return false;
            }
            updateDim();
            return true;
          },
          minDimMills: 800,
        )
      ),
      Container(
        height: spaceL,
        decoration: BoxDecoration(color: CustomColor.paleGrey),
      ),
      Expanded(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                _contentWithTrailingListTile(
                    L10n.chatAlarm,
                    MyProfileToggleButton(
                        value: PushManager.currentSettings.chatAlarm!,
                        onPressed: (value) async => PushManager().updateAlarmSettings(AlarmSettings(chatAlarm: value)),
                        minDimMills: 800)),
                _contentWithTrailingListTile(
                    L10n.friendRequestAlarm,
                    MyProfileToggleButton(
                        value: PushManager.currentSettings.friendRequestAlarm!,
                        onPressed: (value) async => PushManager().updateAlarmSettings(AlarmSettings(friendRequestAlarm: value)),
                        minDimMills: 800),
                    subTitle: L10n.friendRequestAlarmSubtitle),
                _contentWithTrailingListTile(
                    L10n.tradeRequestAlarm,
                    MyProfileToggleButton(
                        value: PushManager.currentSettings.tradeRequestAlarm!,
                        onPressed: (value) async => PushManager().updateAlarmSettings(AlarmSettings(tradeRequestAlarm: value)),
                        minDimMills: 800)),
                _contentWithTrailingListTile(
                    L10n.likeAlarm,
                    MyProfileToggleButton(
                        value: PushManager.currentSettings.likeAlarm!,
                        onPressed: (value) async => PushManager().updateAlarmSettings(AlarmSettings(likeAlarm: value)),
                        minDimMills: 800)),
                _contentWithTrailingListTile(
                    L10n.etcAlarm,
                    MyProfileToggleButton(
                        value: PushManager.currentSettings.etcAlarm!,
                        onPressed: (value) async {
                          // int? status = await KGPush.enablePush(KGPushOption.player, value);
                          // if (status != KGResultCode.SUCCESS) {
                          //   LogWidget.error("zinny push allow response $status error.");
                          //   return false;
                          // }
                          return PushManager().updateAlarmSettings(AlarmSettings(etcAlarm: value));
                        },
                        minDimMills: 800),
                    subTitle: L10n.etcAlarmSubtitle),
              ],
            ),
            ValueListenableBuilder(
                valueListenable: onOffDim,
                builder: (context, value, child) {
                  if (value == true)
                    return Positioned.fill(
                        child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
                    ));

                  return Container();
                })
          ],
        ),
      ),
        ],
      ),
    );
  }

  ListTile _contentWithTrailingListTile(String title, Widget tailTextWidget,
          {String? subTitle, Color? titleColor, VoidCallback? onTap}) =>
      ListTile(
        onTap: onTap,
        dense: true,
        title: Text(title,
            style: TextStyle(
                fontSize: Zeplin.size(28), fontWeight: FontWeight.w500, color: titleColor ?? Colors.black)),
        subtitle: subTitle == null
            ? null
            : Text(subTitle,
                style: TextStyle(
                    color: CustomColor.blueyGrey, fontWeight: FontWeight.w500, fontSize: Zeplin.size(22))),
        trailing: tailTextWidget,
        contentPadding: EdgeInsets.symmetric(vertical: Zeplin.size(30), horizontal: Zeplin.size(50)),
      );
}
*/
