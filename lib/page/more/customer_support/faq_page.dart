import 'dart:html';

import 'package:flutter/material.dart';
import 'package:square_web/config.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'dart:ui' as ui;

class FAQPage extends StatefulWidget with HomeWidget{
  FAQPage();

  @override
  _FAQPageState createState() => _FAQPageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    rightMenu: MenuPack.closeButton(),
    centerMenu: Text(L10n.my_01_21_faq, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500)),
    padding: EdgeInsets.only(top: Zeplin.size(36), left: Zeplin.size(19)));

  @override
  HomeWidgetType get widgetType => HomeWidgetType.overlayPopUp;

  @override
  bool get dimmedBackground => true;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultOverlayPadding;

  @override
  double? get maxWidth => Zeplin.size(500, isPcSize: true);

  @override
  double? get maxHeight => Zeplin.size(500, isPcSize: true);

  @override
  String pageName() => "FAQPage";
}

class _FAQPageState extends State<FAQPage> {
  final IFrameElement _iframeElement = IFrameElement();

  @override
  void initState() {
    super.initState();

    _iframeElement.height = '500';
    _iframeElement.width = '500';

    _iframeElement.src = Config.faqUrl;
    _iframeElement.style.border = 'none';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('faq', (int viewId) => _iframeElement);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(left: Zeplin.size(4), bottom: Zeplin.size(40)),
        child: Column(
          children: [
            SizedBox(height: Zeplin.size(50, isPcSize: true)),
            Expanded(
              child: HtmlElementView(
                viewType: 'faq',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
