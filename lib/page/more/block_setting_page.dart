// 05_01_프로필_01 - 210810_마이_02
import 'package:flutter/material.dart';
import 'package:square_web/command/command_profile.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/data_service.dart';
import 'package:square_web/widget/static_wigets/fullscreen_loading_spinner.dart';
import 'package:square_web/widget/toggle_button.dart';

enum BlockOption {
  // all,
  sendHistory,
  // balance,
  hasNft,
  // hasNftHistory,
  // certainNft
}

class BlockSettingPage extends StatefulWidget with HomeWidget {
  final Function? showPage;

  BlockSettingPage({this.showPage});

  @override
  State<StatefulWidget> createState() => _BlockSettingPageState();

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  HomeWidgetType get widgetType => HomeWidgetType.oneDepth;


  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  String pageName() => "BlockSettingPage";


  @override
  bool get isInternalImplement => true;
}

class _BlockSettingPageState extends State<BlockSettingPage> with TickerProviderStateMixin {

  Map<BlockOption, String> blockOptionName = {
    BlockOption.sendHistory : L10n.my_01_13_history_wallet,
    BlockOption.hasNft : L10n.my_01_15_nft_owner,
  };

  late Set<BlockOption> selectedSet;

  @override
  void initState() {
    super.initState();
    selectedSet = MeModel().blockOption;

    /*HomeNavigator.popHomeWidgetStreamController?.stream.listen((event) {
      if(event == widget) {
        widget.showPage?.call(0);
      }
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: Zeplin.size(100)),
          ListView.builder(shrinkWrap:true, itemBuilder: (context, index) {
            return _buildBlockSettingItem(BlockOption.values[index]);
          }, itemCount: BlockOption.values.length),
        ],
      ),
    );
  }

  Widget _buildBlockSettingItem(BlockOption option) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
      height: 50,
      child: Row(
        children: [
          Text(blockOptionName[option]!, style: TextStyle(color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
          Spacer(),
          ToggleButton(
            onPressed: () async {

              FullScreenSpinner.show(context);
              bool isChecked = selectedSet.contains(option);

              if(isChecked) {
                selectedSet.remove(option);
              }else {
                selectedSet.add(option);
              }

              SetBlockOptionCommand command = SetBlockOptionCommand(selectedSet.map((e) => e.name).toList());
              if(await DataService().request(command)) {
                LogWidget.debug("SetBlockOptionCommand success!!");
              } else {
                LogWidget.debug("SetBlockOptionCommand failed!!");
                if(isChecked) {
                  selectedSet.add(option);
                }else {
                  selectedSet.remove(option);
                }
              }

              Future.delayed(Duration(milliseconds: playerSettingDelayMills), () {
                FullScreenSpinner.hide();
                setState(() {});
              });
            },
            toggleSelect: selectedSet.contains(option),
          )
          // SquareCheckbox(value: selectedSet.contains(option), size: Zeplin.size(40))
        ],
      ),
    );
  }
}








