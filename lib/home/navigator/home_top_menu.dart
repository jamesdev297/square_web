import 'package:flutter/material.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/home_navigator.dart';

class HomeTopMenu extends StatefulWidget {
  final MenuPack? menuPack;

  HomeTopMenu(this.menuPack);

  @override
  State<StatefulWidget> createState() => _HomeTopMenuState();
}

class _HomeTopMenuState extends State<HomeTopMenu> {
  MenuPack? beforeMenuPack;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomeTopMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // LogWidget.debug("menu rebuild");

    /*    if(widget.menuPack?.rightFullMenu != null)
      widget.menuPack!.rightMenu = widget.menuPack?.rightFullMenu;
    if(widget.menuPack?.leftFullMenu != null)
      widget.menuPack!.leftMenu = widget.menuPack?.leftFullMenu;*/

    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: Zeplin.size(18), vertical: 0.0),
      child: homeTopMenuChild(),
    );
  }

  Widget homeTopMenuChild() => Padding(
    padding: widget.menuPack?.padding ?? EdgeInsets.only(top: Zeplin.size(40), left: Zeplin.size(10)),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Zeplin.size(6)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.menuPack?.title != null) Center(child: widget.menuPack?.title),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //디버그용 컬러 배경
                  /*if(widget.menuPack?.leftMenu != null)
                              Container(child: widget.menuPack!.leftMenu!, color: Colors.amber.withOpacity(0.7)),
                            if(widget.menuPack?.leftFullMenu != null)
                              Expanded(child: Container(child: Align(child: widget.menuPack?.leftFullMenu, alignment: Alignment.centerLeft), color: Colors.green.withOpacity(0.7))),
                            if(widget.menuPack?.leftFullMenu == null && widget.menuPack?.rightFullMenu == null)
                              Spacer(),
                            if (widget.menuPack?.leftFullMenu != null || widget.menuPack?.rightFullMenu != null)
                            SizedBox(
                              width: Zeplin.size(30),
                            )
                            if(widget.menuPack?.rightMenu != null)
                              Container(child: widget.menuPack!.rightMenu!, color: Colors.amber.withOpacity(0.7)),
                            if(widget.menuPack?.rightFullMenu != null)
                              Expanded(child: Container(child: Align(child: widget.menuPack?.rightFullMenu, alignment: Alignment.centerRight), color: Colors.green.withOpacity(0.7))),*/
                  if (widget.menuPack?.leftMenu != null) widget.menuPack!.leftMenu!,
                  if (widget.menuPack?.leftFullMenu != null)
                    Expanded(child: Align(child: widget.menuPack?.leftFullMenu, alignment: Alignment.centerLeft)),
                  if (widget.menuPack?.leftFullMenu == null && widget.menuPack?.rightFullMenu == null && widget.menuPack?.midMenu == null) Spacer(),
                  if (widget.menuPack?.leftFullMenu != null || widget.menuPack?.rightFullMenu != null && widget.menuPack?.midMenu == null) SizedBox(width: Zeplin.size(20)),
                  if (widget.menuPack?.midMenu != null)
                    Expanded(child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: Zeplin.size(20)),
                      child: Align(child: widget.menuPack?.midMenu, alignment: Alignment.center),
                    )),
                  if (widget.menuPack?.rightMenu != null) widget.menuPack!.rightMenu!,
                  if (widget.menuPack?.rightFullMenu != null)
                    Expanded(child: Align(child: widget.menuPack?.rightFullMenu, alignment: Alignment.centerRight)),
                ],
              ),
              if (widget.menuPack?.centerMenu != null) Center(child: widget.menuPack?.centerMenu),
            ],
          ),
        ),
        if (widget.menuPack?.subMenu != null) widget.menuPack!.subMenu!,
      ],
    ),
  );
}
