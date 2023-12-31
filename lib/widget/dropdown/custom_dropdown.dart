library animated_custom_dropdown;

export 'custom_dropdown.dart';

import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/widget/button.dart';

part 'animated_section.dart';
part 'dropdown_field.dart';
part 'dropdown_overlay.dart';
part 'overlay_builder.dart';

enum _SearchType { onListData }

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final TextEditingController controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? selectedStyle;
  final String? errorText;
  final TextStyle? errorStyle;
  final TextStyle? listItemStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? fieldSuffixIcon;
  final Function(String)? onChanged;
  final bool? excludeSelected;
  final Color? fillColor;
  final bool? canCloseOutsideBounds;
  final _SearchType? searchType;

  CustomDropdown({
    Key? key,
    required this.items,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.fieldSuffixIcon,
    this.onChanged,
    this.excludeSelected = true,
    this.fillColor = Colors.white,
  })  : assert(items.isNotEmpty, 'Items list must contain at least one item.'),
        assert(
        controller.text.isEmpty || items.contains(controller.text),
        'Controller value must match with one of the item in items list.',
        ),
        searchType = null,
        canCloseOutsideBounds = true,
        super(key: key);

  CustomDropdown.search({
    Key? key,
    required this.items,
    required this.controller,
    this.hintText,
    this.hintStyle,
    this.selectedStyle,
    this.errorText,
    this.errorStyle,
    this.listItemStyle,
    this.errorBorderSide,
    this.borderRadius,
    this.borderSide,
    this.fieldSuffixIcon,
    this.onChanged,
    this.excludeSelected = true,
    this.canCloseOutsideBounds = true,
    this.fillColor = Colors.white,
  })  : assert(items.isNotEmpty, 'Items list must contain at least one item.'),
        assert(
        controller.text.isEmpty || items.contains(controller.text),
        'Controller value must match with one of the item in items list.',
        ),
        searchType = _SearchType.onListData,
        super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    /// hint text
    final hintText = widget.hintText ?? 'Select value';


    return _OverlayBuilder(
      overlay: (size, hideCallback) {
        return _DropdownOverlay(
          items: widget.items,
          controller: widget.controller,
          size: size,
          layerLink: layerLink,
          hideOverlay: hideCallback,
          headerStyle: widget.controller.text.isNotEmpty ? widget.selectedStyle : widget.hintStyle,
          hintText: hintText,
          listItemStyle: widget.listItemStyle,
          excludeSelected: widget.excludeSelected,
          canCloseOutsideBounds: widget.canCloseOutsideBounds,
          searchType: widget.searchType,
          onChanged: widget.onChanged,
        );
      },
      child: (showCallback) {
        return CompositedTransformTarget(
          link: layerLink,
          child: _DropDownField(
            controller: widget.controller,
            onTap: showCallback,
            style: widget.selectedStyle,
            borderRadius: widget.borderRadius,
            borderSide: widget.borderSide,
            errorBorderSide: widget.errorBorderSide,
            errorStyle: widget.errorStyle,
            errorText: widget.errorText,
            hintStyle: widget.hintStyle,
            hintText: hintText,
            suffixIcon: widget.fieldSuffixIcon,
            onChanged: widget.onChanged,
            fillColor: widget.fillColor,
          ),
        );
      },
    );
  }
}
