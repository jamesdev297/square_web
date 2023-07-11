import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/home/navigator/tab/bloc/blue_dot_bloc.dart';
import 'package:square_web/service/bloc_manager.dart';
import 'package:square_web/widget/common/blue_dot.dart';

class NaviBlueDotBuilder extends StatelessWidget {
  final TabCode tabCode;
  const NaviBlueDotBuilder({Key? key, required this.tabCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlueDotBloc, BlueDotState>(
      bloc: BlocManager.getBloc()!,
      // buildWhen: (prev, current) => prev.hasBlueDot(tabCode) != current.hasBlueDot(tabCode),
      builder: (context, state) => state.hasBlueDot(tabCode) ?
        Transform.translate(offset: Offset(Zeplin.size(42), Zeplin.size(-12)), child: BlueDot()) : Container(width: 1, height: 1)
    );
  }
}
