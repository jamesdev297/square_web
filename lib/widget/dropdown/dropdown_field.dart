part of 'custom_dropdown.dart';

const _textFieldIcon = Icon(
  Icons.keyboard_arrow_down_rounded,
  color: Colors.black,
  size: 20,
);
const _contentPadding = EdgeInsets.only(left: 16);
const _noTextStyle = TextStyle(height: 0);
const _borderSide = BorderSide(color: Colors.transparent);
const _errorBorderSide = BorderSide(color: Colors.redAccent, width: 2);

class _DropDownField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTap;
  final Function(String)? onChanged;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final String? errorText;
  final TextStyle? errorStyle;
  final BorderSide? borderSide;
  final BorderSide? errorBorderSide;
  final BorderRadius? borderRadius;
  final Widget? suffixIcon;
  final Color? fillColor;

  const _DropDownField({
    Key? key,
    required this.controller,
    required this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.style,
    this.errorText,
    this.errorStyle,
    this.borderSide,
    this.errorBorderSide,
    this.borderRadius,
    this.fillColor,
  }) : super(key: key);

  @override
  State<_DropDownField> createState() => _DropDownFieldState();
}

class _DropDownFieldState extends State<_DropDownField> {
  String? prevText;
  bool listenChanges = true;

  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) {
      widget.controller.addListener(listenItemChanges);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(listenItemChanges);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DropDownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onChanged != null) {
      widget.controller.addListener(listenItemChanges);
    } else {
      listenChanges = false;
    }
  }

  void listenItemChanges() {
    if (listenChanges) {
      final text = widget.controller.text;
      if (prevText != null && prevText != text && text.isNotEmpty) {
        widget.onChanged!(text);
      }
      prevText = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            border: Border.all(color: CustomColor.borderGrey2, width: 1),
          ),
          height: Zeplin.size(84),
          child: Row(
            children: [
              SizedBox(width: Zeplin.size(26)),
              if(widget.controller.text.isNotEmpty)
                Text(widget.controller.text, style: widget.hintStyle, maxLines: 1, overflow: TextOverflow.ellipsis)
              else
                Text(widget.hintText!, style: widget.hintStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(width: Zeplin.size(10)),
              if(widget.controller.text.isNotEmpty)
                Icon46(Assets.img.ico_46_ch_be),
              Spacer(),
              Icon26(Assets.img.ico_26_h_26_ud_gy),
              SizedBox(width: Zeplin.size(26)),
            ],
          )
        ),
      ),
    );
  }
}
