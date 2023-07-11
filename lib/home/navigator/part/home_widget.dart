part of '../home_navigator.dart';

class MenuPack {
  // static final Widget mapBackButton = Button84Type02(
  //     child: Icon46(Assets.img.ico_46_arrow),
  //     onPressed: () {
  //       HomeNavigator.pop();
  //     }
  // );

  static Widget backButton({HomeWidget? targetPage}) =>
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(child: Center(child: Icon46(Assets.img.ico_46_arrow_bk)),
        onTap: () => HomeNavigator.pop(targetPage: targetPage),
      ),
    );

  static Widget closeButton({VoidCallback? onTap, HomeWidget? targetPage}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: SizedBox(height: Zeplin.size(46), width: Zeplin.size(46),
          child: Center(child: Icon46(Assets.img.ico_46_x_bk))),
        onTap: () {
          onTap?.call();
          HomeNavigator.pop(targetPage: targetPage);
        },
      ),
    );
  }


  //각 위젯은 1:5:1 비율로 최대 크기 고정되어있음. rightFullMenu에 값이 있다면 1:6의 형태로 오른쪽메뉴가 뜸
  //값이 없는 부분은 메뉴가 없는 것으로 표시

  //배경으로 깔리는 중앙정렬 타이틀 위젯
  Widget? title;
  //상단 가운데 메뉴에 표시할 위젯(무조건 가운데, 다른메뉴보다 상단 레이어)
  Widget? centerMenu;

  //상단 왼쪽 메뉴에 표시할 위젯
  Widget? leftMenu;
  //왼쪽 남는 공간 전부에 표시할 위젯
  Widget? leftFullMenu;
  //가운데 남는 공간 전부에 표시할 위젯
  Widget? midMenu;
  //상단 오른쪽 메뉴에 표시할 위젯
  Widget? rightMenu;
  //오른쪽 남는 공간 전부에 표시할 위젯
  Widget? rightFullMenu;
  //상단 가운데 위젯의 바로 아래에 표기되는 위젯(가로사이즈 화면 전체, 세로사이즈는 구현에따라)
  Widget? subMenu;
  //상단 메뉴에 white 그라데이션을 배경으로 깔아줄지 여부
  bool isShowLinearGradient;
  //채팅방 배경색상
  Color? backgroundColor;

  EdgeInsets? padding;

  MenuPack({this.title,  this.centerMenu, this.leftMenu, this.leftFullMenu, this.midMenu, this.rightMenu, this.rightFullMenu, this.subMenu, this.isShowLinearGradient = false, this.padding, this.backgroundColor});

  @override
  String toString() {
    return 'MenuPack{title: $title, leftMenu: $leftMenu, midMenu: $centerMenu, rightMenu: $rightMenu, rightFullMenu: $rightFullMenu, subMenu: $subMenu, isShowLinearGradient: $isShowLinearGradient}';
  }
}

//HomeWidget 클래스를 with으로 상속한 뒤 각 옵션을 override 해주면 HomeNavigator에서 사용할 수 있게 됨.
mixin HomeWidget on Widget {
  //해당 위젯이 탭 네비게이터의 root widget일 경우, 탭을 다시 클릭했을때 행해질 초기화 함수
  void resetWidget() => null;

  Type? _pageType;
  Type get pageType {
    if(_pageType != null) return _pageType!;
    _pageType = runtimeType;
    return _pageType!;
  }

  //지도 공간 부분에 표시될 위젯 (없으면 null)
  HomeExpandedWidget? get homeExpandedWidget => null;
  PopActionCallback? popActionCallback;
  bool get isEmptyPage => false;
  String pageName();

  HomeWidgetType get widgetType;

  bool get isInternalImplement => false;
  double? get maxHeight => null;
  double? get maxWidth => null;
  double? get minWidth => PageSize.defaultPageWidth;
  bool get dimmedBackground => false;
  EdgeInsetsGeometry? get padding => null;
  EdgeInsetsGeometry? addedPadding = null;
  bool get expanded => false;

  bool get slideShowUpInMobile => false;

  //상단 메뉴 구현용 getter. 메뉴바를 없애고 싶으면 => MenuPack(); 으로 처리하면 됨
  MenuPack get getMenuPack;
  //home navigator의 탭중 해당 위젯이 push 될 탭 (full = 풀스크린)
  TabCode get targetNavigator => TabCode.full;
  HomeWidgetLayer get homeWidgetLayer => HomeWidgetLayer.onSlidePanel;
}

mixin HomeExpandedWidget on Widget {
  //상단 메뉴 구현용 getter. 메뉴바를 없애고 싶으면 => MenuPack(); 으로 처리하면 됨
  MenuPack get getMenuPack;
  bool get isEmptyWidget => false;
}

enum HomeWidgetType {
  oneDepth,
  twoDepth,
  twoDepthPopUp,
  overlay,
  overlayPopUp,
}
