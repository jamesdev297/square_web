// 05_01_프로필_01 - 210810_마이_02
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:square_web/bloc/contact/block_contacts_bloc.dart';
import 'package:square_web/bloc/square/square_bloc.dart';
import 'package:square_web/bloc/profile/player_profile_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/model/square/square_model.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/model/player_nft_model.dart';
import 'package:square_web/model/scroll_default.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/service/square_manager.dart';
import 'package:square_web/service/profile_manager.dart';
import 'package:square_web/service/room_manager.dart';
import 'package:square_web/util/image_util.dart';
import 'package:square_web/widget/button.dart';
import 'package:square_web/widget/common/share_link_chat.dart';
import 'package:square_web/widget/contacts/add_contact_button.dart';
import 'package:square_web/widget/contacts/remove_contact_button.dart';
import 'package:square_web/widget/contacts/unblock_blocked_contact_button.dart';
import 'package:square_web/widget/dialog/square_room_dialog.dart';
import 'package:square_web/widget/square/square_item.dart';
import 'package:square_web/widget/profile/my_nickname.dart';
import 'package:square_web/widget/profile/player_nickname.dart';
import 'package:square_web/widget/profile/profile_image.dart';
import 'package:square_web/widget/profile/wallet_copy_row.dart';
import 'package:square_web/widget/static_wigets/square_circular_progress_indicator.dart';


class EmptyProfilePage extends StatelessWidget with HomeWidget {
  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepth;

  @override
  bool get isEmptyPage => true;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  MenuPack get getMenuPack => MenuPack();

  @override
  double? get maxHeight => 0;

  @override
  String pageName() => "EmptyProfilePage";
}

class PlayerProfilePage extends StatefulWidget with HomeWidget {
  final String playerId;
  final PreloadPageController? squareMemberPageController;
  final Function? showEditPage;
  final HomeWidget rootWidget;

  @override
  String pageName() => "PlayerProfilePage";

  // final bool isDimmedBackground;
  PlayerProfilePage(this.playerId, this.rootWidget, {Key? key, this.squareMemberPageController, this.showEditPage}):super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerProfilePageState();

  @override
  MenuPack get getMenuPack => MenuPack(
    padding: EdgeInsets.only(top: Zeplin.size(36)),
    leftMenu: squareMemberPageController != null ? MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ContactManager().selectedContactBloc.add(Update());
          squareMemberPageController!.animateToPage(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
          // HomeNavigator.pop(targetPage: this);
        },
        child: Icon46(Assets.img.ico_46_arrow_bk),
      ),
    ) : null,
    rightFullMenu: Builder(
      builder: (context) {
        return Row(
          children: [
            Spacer(),
            ShareLinkChat(walletAddress: playerId, rootWidget: rootWidget),
            SizedBox(width: Zeplin.size(30)),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  ContactManager().selectedContactBloc.add(Update());
                  HomeNavigator.clearTwoDepthPopUp();
                },
                child: Icon46(Assets.img.ico_46_x_bk),
              ),
            ),
          ],
        );
      }
    )
  );

  @override
  HomeWidgetType get widgetType => HomeWidgetType.twoDepthPopUp;

  @override
  double? get maxWidth => PageSize.defaultPageWidth;

  @override
  double? get maxHeight => PageSize.profilePageHeight;

  @override
  EdgeInsetsGeometry? get padding => PageSize.defaultTwoDepthPopUpPadding;

  @override
  bool get slideShowUpInMobile => true;

}

class _PlayerProfilePageState extends State<PlayerProfilePage> with TickerProviderStateMixin {
  late PlayerProfileBloc playerProfileBloc;
  bool isMe = false;
  late ContactModel? contactModel;
  TextStyle squareIdTextStyle = TextStyle(color: CustomColor.blueyGrey, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500);
  BlockedContactsBloc blockFriendBloc = BlocManager.getBloc<BlockedContactsBloc>()!;
  SquareBloc? squareBloc;
  ValueNotifier<ChainNetType> selectedChainNetType = MeModel().selectedChainNetType;
  ChainNetType? lastSelectedChainNetType;
  late ScrollDefault scrollDefault = ScrollDefault();
  bool lastStatus = true;
  double height = Zeplin.size(300);
  Timer? retryTimer;

  double _initialLoadedSize = 0;
  int _lastLoadTime = 0;
  double initialScrollOffset = 0;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return scrollDefault.controller.hasClients && scrollDefault.controller.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();

    playerProfileBloc = PlayerProfileBloc(widget.playerId);
    ProfileManager().currentPlayerProfileBloc = playerProfileBloc;
    FocusManager.instance.primaryFocus?.unfocus();

    String? tempChainNetType = prefs.getString(Chain.getSelectedChainNetTypeKey(widget.playerId));
    if (tempChainNetType != null) {
      selectedChainNetType.value = ChainNetType.values[tempChainNetType]!;
    }

    if (MeModel().playerId == widget.playerId) {
      isMe = true;
      contactModel = MeModel().contact;
      squareBloc = SquareManager().getPlayerSquareBloc(contactModel!);
    } else {
      playerProfileBloc.add(FetchPlayerProfileEvent(targetPlayerId: widget.playerId));
    }

    scrollDefault.init();
    scrollDefault.controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    scrollDefault.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMe == true) {
      return _buildProfile();
    }

    return BlocBuilder<PlayerProfileBloc, PlayerProfileBlocState>(
      bloc: playerProfileBloc,
      builder: (context, state) {
        if (state is PlayerProfileUninitialized) {
          return Scaffold(body: SquareCircularProgressIndicator());
        }

        if (state is PlayerProfileLoaded) {
          contactModel = state.player!;
          return _buildProfile();
        }

        return Container();
      },
    );
  }


  Widget _buildPlayerProfile() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          onTap: () async {
            if (contactModel!.profileImgUrl == null)
              return;

            PlayerNftModel? playerNftModel;
            String imgUrl = contactModel!.profileImgUrl!;

            if (contactModel!.profileImgNftId != null) {
              playerNftModel = await SquareManager().loadProfilePicture(contactModel!.playerId, contactModel!.profileImgNftId!);
              imgUrl = ImageUtil.convertRawImgUrl(playerNftModel?.imgUrl ?? contactModel!.profileImgUrl!)!;
            }

            HomeNavigator.push(RoutePaths.common.fullImageView, arguments: { "imageUrl": imgUrl, "playerNftModel": playerNftModel });
          },
          child: ProfileImage(contactModel: contactModel!, isEdit: false, size: _isShrink ? 60 : 100, isShowBlueDot: contactModel?.relationshipStatus == RelationshipStatus.blocked ? false : true)),
    );
  }

  Widget _buildProfile() {
    if (lastSelectedChainNetType != selectedChainNetType.value) {
      squareBloc = SquareManager().getPlayerSquareBloc(contactModel!);
      lastSelectedChainNetType = selectedChainNetType.value;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: scrollDefault.controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: height,
              floating: false,
              pinned: true,
              elevation: 1,
              // title: Text("DEMO"),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(vertical: Zeplin.size(20)),
                centerTitle: true,
                title: _buildPlayerProfile(),
              ),
            ),
          ];
        },
        body: NotificationListener<ScrollUpdateNotification>(
          onNotification: (evt) {
            double _listGap = evt.metrics.maxScrollExtent - evt.metrics.pixels;

            if (_initialLoadedSize == 0) {
              _initialLoadedSize = _listGap;
            }
            //LogWidget.debug("_listPixelSize : ${_listGap}, ${_initialLoadedSize/3}, ${_initialLoadedSize}");
            if (evt.metrics.pixels >= evt.metrics.maxScrollExtent &&
                !evt.metrics.outOfRange) {
              squareBloc?.add(LoadSquare());
            } else if (_listGap < _initialLoadedSize / 3) {
              if (_lastLoadTime + 50 > DateTime
                  .now()
                  .millisecondsSinceEpoch) {
                return false;
              }
              squareBloc?.add(LoadSquare());

              _lastLoadTime = DateTime
                  .now()
                  .millisecondsSinceEpoch;
            }
            return true;
          },
          child: ListView(
            shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            // controller: scrollDefaultSquareList.controller,
            children: [
              SizedBox(height: Zeplin.size(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(isMe)
                    MyNickname(textStyle: TextStyle(
                        color: Colors.black, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500))
                  else
                    PlayerNickname(contactModel!, nicknameTextStyle: TextStyle(
                        color: Colors.black, fontSize: Zeplin.size(34), fontWeight: FontWeight.w500),
                        playerProfileBloc: playerProfileBloc)
                ],
              ),
              SizedBox(height: Zeplin.size(10)),
              if(contactModel!.statusMessage != null)
                Center(child: SizedBox(
                  width: Zeplin.size(550),
                  child: Text(contactModel!.statusMessage!, textAlign: TextAlign.center, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)))))
              else
                if(contactModel!.isNotSignedUp)
                  Center(child: Text(L10n.profile_status_01_01_no_login, style: TextStyle(color: CustomColor.taupeGray, fontWeight: FontWeight.w500, fontSize: Zeplin.size(26)))),
              SizedBox(height: Zeplin.size(49)),

              if(isMe)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      widget.showEditPage?.call(1);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: Zeplin.size(94),
                          height: Zeplin.size(94),
                          decoration: BoxDecoration(color: CustomColor.paleGrey, shape: BoxShape.circle),
                          child: Center(child: Icon46(Assets.img.ico_46_edit_gy)),
                        ),
                        SizedBox(height: Zeplin.size(10)),
                        Text(L10n.my_01_07_edit_profile, style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))),
                      ],
                    ),
                  ),
                )
              else
                BlocBuilder<PlayerProfileBloc, PlayerProfileBlocState>(
                  bloc: playerProfileBloc,
                  builder: (context, state) {
                    LogWidget.debug("PlayerProfileBloc state ${state} ${contactModel?.friendTime}");

                    return _buildContactsMenuItems(contactModel!);
                  },
                ),
              SizedBox(height: Zeplin.size(60)),
              Divider(thickness: Zeplin.size(20), color: CustomColor.paleGrey),
              Container(
                height: Zeplin.size(121),
                padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34)),
                child: WalletCopyRow(contactModel: contactModel!, rootWidget: widget.rootWidget,),
              ),
              Divider(thickness: Zeplin.size(20), color: CustomColor.paleGrey),
              if(squareBloc != null)
                _buildSquareList()
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSquareList() {
    return BlocConsumer<SquareBloc, SquareState>(
        bloc: squareBloc,
        listener: (context, state) {
          if (state is LoadedSquareState) {
            if (NftQueueStatus.isRunning(state.queueStatus) ||
                state.queueStatus == null && state.errorCode != Chain.notSupportChainErrorCode) {
              retryTimer?.cancel();
              retryTimer = Timer(Duration(seconds: Chain.loadNftRetryDelaySeconds), () {
                squareBloc?.add(LoadSquare());
              });
            }
          }
        },
        builder: (context, state) {
          LogWidget.debug("SquareBloc state $state");
          if (state is LoadedSquareState) {
            List<SquareModel> squares = state.squareList;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: Zeplin.size(34), vertical: Zeplin.size(40)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(L10n.profile_01_01_nft_square, style: TextStyle(
                          color: CustomColor.darkGrey, fontSize: Zeplin.size(28), fontWeight: FontWeight.w500)),
                      SizedBox(width: Zeplin.size(10)),
                      Text("${state.totalCount}", style: TextStyle(
                          color: CustomColor.azureBlue, fontWeight: FontWeight.w500, fontSize: Zeplin.size(28))),
                      Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => squareBloc?.add(RefreshSquare()),
                          child: Icon36(Assets.img.ico_46_re_gy)
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: Zeplin.size(30)),
                  if(squares.length > 0)
                    GridView.count(
                      crossAxisCount: 2,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: .7,
                      children: squares.map((e) => SquareItem(e, onTap: () {
                        SquareManager().clickSquare(e, joined: e.joined == true, popBeforeWidget: true);
                      })).toList(),
                      shrinkWrap: true,
                    ),
                  if((state.queueStatus == null && state.errorCode != Chain.notSupportChainErrorCode) ||
                      NftQueueStatus.isRunning(state.queueStatus) || !state.hasReachedMax)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SquareCircularProgressIndicator(),
                      ],
                    )
                  else if(squares.isEmpty)
                    Container(
                        padding: EdgeInsets.only(top: Zeplin.size(40, isPcSize: true)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              L10n.square_01_23_no_accessible_square_context,
                              style: TextStyle(
                                  fontSize: Zeplin.size(26),
                                  color: CustomColor.taupeGray,
                                  fontWeight: FontWeight.w500, height: 1.2),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ))
                ],
              ),
            );
          } else if (state is LoadingSquareState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareCircularProgressIndicator(),
              ],
            );
          }
          return Container();
        });
  }

  Widget _buildMenuItem(String iconPath, Color color, String text, VoidCallback onPressed) {
    return SizedBox(
      width: Zeplin.size(180),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onTap: onPressed,
            child: Container(
              height: Zeplin.size(94),
              width: Zeplin.size(94),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(child: Icon46(iconPath)),
            ),
          ),
          SizedBox(height: Zeplin.size(10)),
          Center(child: Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))))
        ],
      ),
    );
  }

  Widget _buildBlockedContactsMenuItems(ContactModel contactModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            UnblockBlockedContactButton(contactModel: contactModel, onProfilePage: true, playerProfileBloc: playerProfileBloc, successFunc: () {
              contactModel.relationshipStatus = RelationshipStatus.removed;
              playerProfileBloc.add(ReloadPlayerProfileEvent(contactModel));
              setState(() {});
              RoomManager().updateChatPage(contactModel: contactModel);
            }),
            SizedBox(height: Zeplin.size(10)),
            Center(child: Text(L10n.profile_01_06_unblock,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))))
          ],
        )
      ],
    );
  }

  Widget _buildContactsMenuItems(ContactModel contactModel) {
    bool isFriend = contactModel.friendTime != null && contactModel.friendTime != -1;
    bool isBlocked = contactModel.relationshipStatus == RelationshipStatus.blocked;

    if (isBlocked)
      return _buildBlockedContactsMenuItems(contactModel);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 15),
        if(isFriend)
          SizedBox(
            width: Zeplin.size(180),
            child: Center(
              child: Column(
                children: [
                  RemoveContactButton(contactModel: contactModel, successFunc: () {
                    contactModel.friendTime = null;
                    playerProfileBloc.add(ReloadPlayerProfileEvent(contactModel));
                    // setState(() {});
                    RoomManager().updateChatPage(contactModel: contactModel);
                  }),
                  SizedBox(height: Zeplin.size(10)),
                  Center(child: Text(L10n.profile_01_07_delete_contact, style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))))
                ],
              ),
            ),
          )
        else
          SizedBox(
            width: Zeplin.size(180),
            child: Center(
              child: Column(
                children: [
                  AddContactButton(contactModel: contactModel, onProfilePage: true, successFunc: (contact) {
                    contactModel.update(contact);
                    playerProfileBloc.add(ReloadPlayerProfileEvent(contactModel));
                    // setState(() {});
                    RoomManager().updateChatPage(contactModel: contactModel);
                  }),
                  SizedBox(height: Zeplin.size(10)),
                  Center(child: Text(L10n.profile_01_03_add_contact, style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500, fontSize: Zeplin.size(24))))
                ],
              ),
            ),
          ),
        _buildMenuItem(Assets.img.ico_46_talk_be, CustomColor.linkWater, L10n.profile_01_04_send_msg, () {
          HomeNavigator.pop(targetPage: widget);
          RoomManager().openTwinRoom(contactModel);
        }),

        if(contactModel.blockchainNetType == ChainNetType.ai)
          _buildMenuItem(Assets.img.ico_46_square_btn, CustomColor.linkWater, L10n.square_01_01_square, () {
            SquareModel square = SquareModel(squareId: SquareManager().makeSquareId(contactModel.playerId), contractAddress: contactModel.playerId, chainNetType: ChainNetType.ai, squareType: SquareType.etc);
            SquareManager().clickSquare(square, joined: true, popBeforeWidget: true);
          })
        else
          _buildMenuItem(Assets.img.ico_46_block_gy, CustomColor.paleGrey, L10n.profile_01_05_block, () {
            SquareRoomDialog.showBlockPlayerOverlay(contactModel, successFunc: () {
              playerProfileBloc.add(ReloadPlayerProfileEvent(contactModel));
            });
          }),
        SizedBox(width: 15),
      ],
    );
  }
}


