import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/bloc/update_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/constants/route_paths.dart';
import 'package:square_web/home/navigator/home_navigator.dart';
import 'package:square_web/model/me_model.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/service/contact_manager.dart';
import 'package:square_web/widget/profile/profile_image.dart';

class MyProfileItem extends StatelessWidget {
  bool? isMorePage;
  MyProfileItem({Key? key, this.isMorePage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyProfileBloc, UpdateState>(
      bloc: BlocManager.getBloc(),
      builder: (context, state) {
        return BlocBuilder<SelectedContactBloc, UpdateState>(
          bloc: ContactManager().selectedContactBloc,
          builder: (context, selectedContactState) {
            if (selectedContactState is UpdateInitial) {

              return Container(
                color: selectedContactState.param  == MeModel().playerId ? isMorePage! ? CustomColor.paleGrey : CustomColor.brightBlue : null,
                height: Zeplin.size(130),
                child: ListTile(
                  onTap: () {
                    ContactManager().selectedContactBloc.add(Update(param: MeModel().playerId));
                    HomeNavigator.push(RoutePaths.profile.player, arguments: MeModel().playerId!);
                  },
                  tileColor: Colors.white,
                  leading: ProfileImage(contactModel: MeModel().contact!, size: 93, isEdit: false, isShowBlueDot: true),
                  title: Row(
                    children: [
                      Text(MeModel().contact!.name,
                        style: TextStyle(fontSize: Zeplin.size(28), color: CustomColor.darkGrey, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  subtitle: Text(MeModel().contact!.statusMessage ?? "", overflow: TextOverflow.ellipsis, style: TextStyle(color: CustomColor.taupeGray, fontSize: Zeplin.size(24), fontWeight: FontWeight.w500)),
                  contentPadding: EdgeInsets.symmetric(vertical: Zeplin.size(6), horizontal: Zeplin.size(34)),
                ),
              );
            }

            return Container();
          }
        );
      }
    );
  }
}
