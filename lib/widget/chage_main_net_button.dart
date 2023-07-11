import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/chain_net_type.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/main.dart';
import 'package:square_web/model/contact/contact_model.dart';
import 'package:square_web/widget/button.dart';

import '../custom_dropdown/custom_dropdown_button.dart';

class ChangeMainNetButton extends StatefulWidget {
  final ContactModel contactModel;
  final VoidCallback changedSuccess;
  final ValueNotifier<ChainNetType> selectedChainNetType;

  ChangeMainNetButton(this.contactModel, this.selectedChainNetType, this.changedSuccess);

  @override
  State<ChangeMainNetButton> createState() => _ChangeMainNetButtonState();
}

class _ChangeMainNetButtonState extends State<ChangeMainNetButton> {

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(Zeplin.size(15)),
      child: Material(
        color: Colors.transparent,
        child: CustomDropdownButton<ChainNetType>(
          icon: Icon36(Assets.img.ico_36_arrow_rig),
          underline: Container(),
          value: widget.selectedChainNetType.value,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          items: List.generate(Chain.supportedChainName.length, (index) => DropdownMenuItem<ChainNetType>(
            value: Chain.supportedChainName.toList()[index],
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: Zeplin.size(170)),
              child: Row(
                children: [
                  Icon36(Chain.supportedChainName.elementAt(index).chainIcon),
                  SizedBox(width: Zeplin.size(16)),
                  Text(Chain.supportedChainName.elementAt(index).fullName),
                ],
              ),
            ),
          )),
          onChanged: (ChainNetType? chainNetType) {
            widget.selectedChainNetType.value = chainNetType!;
            prefs.setString(Chain.getSelectedChainNetTypeKey(widget.contactModel.playerId), widget.selectedChainNetType.value.name);
            widget.changedSuccess();

            setState(() {});
          },
        ),
      ),
    );
  }
}
