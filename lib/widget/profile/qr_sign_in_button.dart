import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/util/string_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/dialog/square_default_dialog.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class QRSignInButton extends StatelessWidget {
  QRSignInButton({
    Key? key,
  }) : super(key: key);


  String loadString() {
    return "This is a sample Plain Text QR Code with just words";
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          SquareDefaultDialog.showSquareDialog(
            padding: EdgeInsets.only(
              top: Zeplin.size(22, isPcSize: true),
              right: Zeplin.size(15, isPcSize: true),
              left: Zeplin.size(15, isPcSize: true),
              bottom: 0),
            barrierDismissible: false,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: Zeplin.size(46)),
                        Spacer(),
                        Text(L10n.common_40_qr_login, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(34), color: Colors.black)),
                        Spacer(),
                        InkWell(
                          child: SizedBox(height: Zeplin.size(46), width: Zeplin.size(46), child: Center(child: Icon46(Assets.img.ico_46_x_bk))),
                          onTap: () => SquareDefaultDialog.closeDialog().call(),
                        )
                      ],
                    ),
                    SizedBox(height: Zeplin.size(20)),
                    _buildQr()
                  ],
                );
              }
            ),
          );
        },
        child: Icon46(Assets.img.ico_36_qr_bk),
      ),
    );
  }

  Widget _buildQr() {
    DateTime expiredTime = DateTime.fromMillisecondsSinceEpoch(60 * 1000 * 3);
    QrImage qrCode = QrImage(data: loadString(),
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
        // embeddedImage: AssetImage(Assets.img.square_qr_logo),
        // embeddedImageStyle: QrEmbeddedImageStyle(size: Size(160, 70)),
        size: 300, padding: EdgeInsets.zero);

    return Column(
      children: [
        Text(L10n.common_41_qr_login_content, style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.taupeGray), textAlign: TextAlign.center),
        /*TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
          DateTime now = DateTime.now();

          if(now.isAfter(expiredTime)) {
            SquareDefaultDialog.closeDialog().call();
          }

          return RichText(
            text: TextSpan(
                children: StringUtil.parseColorText(L10n.common_42_qr_login_content(now.isAfter(expiredTime) ? "expired" : expiredTime.difference(now).inSeconds), CustomColor.azureBlue, boldToAccent: true, fontSize: Zeplin.size(26)),
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: Zeplin.size(26), color: CustomColor.taupeGray)
            ),
            textAlign: TextAlign.center,
          );
        }),*/
        SizedBox(height: Zeplin.size(42)),
        qrCode
      ],
    );
  }
}
