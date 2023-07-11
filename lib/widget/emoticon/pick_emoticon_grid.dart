import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/model/emoticon/emoticon_pack_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/emoticon_manager.dart';
import 'package:square_web/widget/emoticon/emoticon_pack.dart';
import 'package:square_web/widget/emoticon/emoticon_pack_icon.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';

class PickEmoticonGrid extends StatefulWidget {
  final bool isMobile;

  PickEmoticonGrid(this.isMobile);

  @override
  State<StatefulWidget> createState() => _PickEmoticonGridState();

}

class _PickEmoticonGridState extends State<PickEmoticonGrid> {
  late List<String> myEmoticonPackIds;
  int selectedIndex = MeModel().lastEmoticonIndex ?? 0;
  late PageController pageController = PageController(initialPage: selectedIndex);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EmoticonManager().loadEmoticonPackList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EmoticonPackModel>>(
      future: EmoticonManager().loadEmoticonPackIdListCompleter.future,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: CustomColor.grey3,
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: SquareCircularProgressIndicator(),
              ),
            ),
          );
        }

        if(snapshot.hasData) {
          List<EmoticonPackModel> emoticonPackList = snapshot.data!;
          return Container(
              color: CustomColor.grey3,
              child: Column(
                children: [
                  Container(
                      height: 40,
                      color: CustomColor.grey3,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) => SizedBox(width: Zeplin.size(8)),
                          padding: EdgeInsets.zero,
                          itemCount: emoticonPackList.length,
                          itemBuilder: (context, index) {

                            EmoticonPackModel emoticonPack = emoticonPackList[index];

                            // if(EmoticonManager().isLoadedHeaderEmoticon(headerEmoticonId))
                            //   return _buildHeaderIcon(index, EmoticonManager().getHeaderEmoticon(headerEmoticonId));

                            return EmoticonPackIcon(emoticonPack : emoticonPack, isSelectedPage: selectedIndex == index, onTap: () {
                                pageController.jumpToPage(index);

                                selectedIndex = index;
                                setState(() {
                                });
                            });
                          })
                  ),
                  Divider(height: 1, thickness: 1, color: CustomColor.veryLightGrey,),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: emoticonPackList.length,
                      itemBuilder: (context, index) {
                        EmoticonPackModel emoticonPack = emoticonPackList[index];
                        // if(EmoticonManager().isLoadedEmoticonPack(emoticonPackId))
                        //   return _buildEmoticonPack(EmoticonManager().getEmoticonPack(emoticonPackId));
                        return EmoticonPack(emoticonPack, selectedIndex == index, widget.isMobile);
                      },
                      onPageChanged: (index) {
                        selectedIndex = index;
                        MeModel().lastEmoticonIndex = index;

                        setState(() {

                        });
                      },
                    ),
                  )
                ],
              )
          );
        }

        return Container(
          color: CustomColor.grey3,
        );
      }
    );
  }
}
