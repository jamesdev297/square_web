import 'package:flutter/material.dart';
import 'package:square_web/constants/assets.dart';
import 'package:square_web/constants/constants.dart';
import 'package:square_web/model/contact/contact_model.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double? width;
  final double? height;
  final Color color;
  final Color textColor;
  final double fontSize;
  final double padding;

  BottomButton(
      {this.onPressed,
      this.height,
      this.text,
      this.width,
      this.color = Colors.black,
      this.textColor = Colors.white,
      this.fontSize = 18,
      this.padding = 10.0});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(this.padding),
        child: Container(
          width: this.width,
          height: this.height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: this.color,
                textStyle: TextStyle(color: this.textColor),
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))),
            child: Text(
              text!,
              style: TextStyle(fontSize: this.fontSize),
            ),
            onPressed: () {
              this.onPressed!();
            },
          ),
        ));
  }
}

class PinButton104TypePr extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final double ratio = Zeplin.sizeFactor;
  final ContactModel? contactModel;

  PinButton104TypePr({this.onPressed, this.child, this.width, this.contactModel});

  @override
  State<StatefulWidget> createState() => PinButton104TypePrState();
}

class PinButton104TypePrState extends State<PinButton104TypePr> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.btn_pin_pr_104_x_116)),
      ),
      width: 104 * widget.ratio,
      height: 123 * widget.ratio,
      child: RawMaterialButton(
          onPressed: widget.onPressed,
          child: Column(
            children: <Widget>[
              Spacer(),
              if (widget.child != null) widget.child!,
              Spacer(),
              SizedBox(height: (123 - 104) * widget.ratio)
            ],
          )),
    );
  }
}

class Button106Type01 extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final double ratio = Zeplin.sizeFactor;
  final Key? key;

  Button106Type01({this.onPressed, this.child, this.width, this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.btn_106_01)),
      ),
      width: 106 * ratio,
      height: 114 * ratio,
      child: RawMaterialButton(
          onPressed: this.onPressed,
          child: Column(
            children: <Widget>[
              Spacer(),
              if (child != null) this.child!,
              Spacer(),
              SizedBox(
                height: (114 - 106) * ratio,
              )
            ],
          )),
    );
  }
}

class Button106Type01NS extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  final double ratio = Zeplin.sizeFactor;

  Button106Type01NS({this.onPressed, this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.btn_106_01_ns)),
      ),
      width: 106 * ratio,
      height: 114 * ratio,
      child: RawMaterialButton(
          onPressed: this.onPressed,
          child: Column(
            children: <Widget>[
              Spacer(),
              if (child != null) this.child!,
              Spacer(),
              SizedBox(
                height: (114 - 106) * ratio,
              )
            ],
          )),
    );
  }
}

// class ShadowableButtonBackground extends StatelessWidget {
//   final bool? toggleOn;
//   ShadowableButtonBackground({this.toggleOn});
//
//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: 100,
//         ),
//         child: Stack(
//           children: <Widget>[
//             BoolContainer(
//               showContainer: (toggleOn ?? false),
//               container: Image.asset(Assets.img.btn_84_button_yel, width: Zeplin.size(84), height: Zeplin.size(84)),
//               child: Image.asset(Assets.img.button_02_ns, width: Zeplin.size(84), height: Zeplin.size(84)),
//             ),
//             Positioned.fill(
//               bottom: -23,
//               child: BlocBuilder<ButtonShadowBloc, SwitchBlocState>(
//                 bloc: BlocManager.getBloc()!,
//                 builder: (context, state) {
//                   bool _visible = false;
//
//                   if (state is SwitchBlocOffState) {
//                     _visible = false;
//                   }
//                   if (state is SwitchBlocOnState) {
//                     _visible = true;
//                   }
//                   return AnimatedOpacity(
//                     opacity: _visible ? 1.0 : 0.0,
//                     duration: Duration(milliseconds: 500),
//                     child: Image.asset(Assets.img.btn_shadow),
//                   );
//                 }
//               ),
//             ),
//           ],
//         ));
//   }
// }

typedef void CallBackWithContext(BuildContext context);

// class Button84Type02 extends StatelessWidget {
//   final Widget? child;
//   final VoidCallback? onPressed;
//   final CallBackWithContext? onPressedWithContext;
//   final double? width;
//   final double ratio = Zeplin.sizeFactor;
//   final Key? key;
//   final bool? toggleOn;
//
//   Button84Type02({this.onPressed, this.child, this.width, this.key, this.onPressedWithContext, this.toggleOn})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 84 * ratio,
//       height: 92 * ratio,
//       child: Stack(
//         children: <Widget>[
//           ShadowableButtonBackground(toggleOn: toggleOn),
//           RawMaterialButton(
//             onPressed: this.onPressedWithContext == null ? this.onPressed : () => this.onPressedWithContext?.call(context),
//             child: Column(
//               children: <Widget>[
//                 Spacer(),
//                 if(child != null)
//                   this.child!,
//                 Spacer(),
//                 SizedBox(height: (8) * ratio)
//               ],
//             )
//           )
//         ],
//       ),
//     );
//   }
// }

class Button84Type02NS extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final CallBackWithContext? onPressedWithContext;
  final double? width;
  final double ratio = Zeplin.sizeFactor;

  Button84Type02NS({this.onPressed, this.child, this.width, this.onPressedWithContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.button_02_ns)),
      ),
      width: 84 * ratio,
      height: 84 * ratio,
      child: RawMaterialButton(
          onPressed: this.onPressedWithContext == null ? this.onPressed : () => this.onPressedWithContext?.call(context),
          child: Column(
            children: <Widget>[
              Spacer(),
              if (child != null) this.child!,
              Spacer(),
            ],
          )),
    );
  }
}

class Button84TypeGray extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final double? width;
  double ratio = Zeplin.sizeFactor;

  Button84TypeGray({this.onPressed, this.child, this.width, this.ratio = 0.57});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.btn_gray_ns)),
      ),
      width: 84 * ratio,
      height: 84 * ratio,
      child: Transform.translate(
        offset: Offset(0, -2),
        child: RawMaterialButton(onPressed: this.onPressed, child: this.child),
      ),
    );
  }
}

class Button104TypePr extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final double? ratio;

  Button104TypePr({this.onPressed, this.onPointerDown, this.child, this.onPointerUp, double? ratio})
      : this.ratio = ratio ?? Zeplin.sizeFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Assets.img.btn_pr_104)),
        ),
        width: 104 * ratio!,
        height: 112 * ratio!,
        child: Listener(
          onPointerDown: (details) {
            this.onPointerDown?.call();
          },
          onPointerUp: (details) {
            this.onPointerUp?.call();
          },
          behavior: HitTestBehavior.translucent,
          child: RawMaterialButton(
              onPressed: this.onPressed,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  if (child != null) this.child!,
                  Spacer(),
                  SizedBox(
                    height: (112 - 104) * ratio!,
                  )
                ],
              )),
        ));
  }
}

class ButtonSkill extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onPointerDown;
  final VoidCallback? onPointerUp;
  final double ratio = Zeplin.sizeFactor;

  ButtonSkill({this.onPressed, this.onPointerDown, this.child, this.onPointerUp});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Assets.img.mask_copy_5_shadow)),
        ),
        width: 104 * ratio,
        height: 112 * ratio,
        child: Listener(
          onPointerDown: (details) {
            this.onPointerDown?.call();
          },
          onPointerUp: (details) {
            this.onPointerUp?.call();
          },
          behavior: HitTestBehavior.translucent,
          child: RawMaterialButton(
              onPressed: this.onPressed,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  if (child != null) this.child!,
                  Spacer(),
                  SizedBox(
                    height: (112 - 104) * ratio,
                  )
                ],
              )),
        ));
  }
}

class Button104TypeCancel extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double ratio = Zeplin.sizeFactor;

  Button104TypeCancel({this.onPressed, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(Assets.img.btn_104_cancel)),
      ),
      width: 104 * ratio,
      height: 112 * ratio,
      child: RawMaterialButton(
          onPressed: this.onPressed,
          child: Column(
            children: <Widget>[
              Spacer(),
              Image.asset(
                Assets.img.text_cancel,
                width: 46 * ratio,
                height: 26 * ratio,
              ),
              Spacer(),
              SizedBox(
                height: (112 - 104) * ratio,
              )
            ],
          )),
    );
  }
}

class Icon64 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon64(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 128 * ratio,
      height: 64 * ratio,
    );
  }
}

class Icon60 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon60(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 60 * ratio,
      height: 60 * ratio,
    );
  }
}

class Icon46 extends StatelessWidget {
  final String iconPath;
  final double ratio;
  final Color? color;

  Icon46(this.iconPath, {double? ratio, this.color}) : this.ratio = ratio ?? Zeplin.sizeFactor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 46 * ratio,
      height: 46 * ratio,
      color: color,
    );
  }
}

class Icon40 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;
  final Color? color;

  Icon40(this.iconPath, {this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 40 * ratio,
      height: 40 * ratio,
      color: color,
    );
  }
}

class Icon24 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;
  final Color? color;

  Icon24(this.iconPath, {this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(iconPath, width: 24 * ratio, height: 24 * ratio, color: color);
  }
}

class Icon26 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon26(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 26 * ratio,
      height: 26 * ratio,
    );
  }
}

class Icon28 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon28(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 28 * ratio,
      height: 28 * ratio,
    );
  }
}

class Icon36 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;
  final Color? color;

  Icon36(this.iconPath, {this.color});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 36 * ratio,
      height: 36 * ratio,
      color: color,
    );
  }
}

class Icon120 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon120(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 120 * ratio,
      height: 120 * ratio,
    );
  }
}

class Icon14 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon14(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 14 * ratio,
      height: 14 * ratio,
    );
  }
}

class IconDragUpdown extends StatelessWidget {
  final double ratio = Zeplin.sizeFactor;

  IconDragUpdown();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.img.ico_drag_up_down,
      width: 60 * ratio,
      height: 8 * ratio,
    );
  }
}

class Icon12 extends StatelessWidget {
  final String iconPath;
  final double ratio = Zeplin.sizeFactor;

  Icon12(this.iconPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: 12 * ratio,
      height: 12 * ratio,
    );
  }
}

class PebbleRectButton extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final double strokeWidth;
  final double radius;

  PebbleRectButton(
      {required this.onPressed,
      this.borderColor = Colors.black,
      required this.child,
      this.strokeWidth = 2.5,
      this.backgroundColor = Colors.white,
      this.radius = 10});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        child: this.child,
        onPressed: this.onPressed,
        style: OutlinedButton.styleFrom(
            side: BorderSide(
              width: 1.0,
              color: borderColor,
              style: BorderStyle.solid,
            ),
            backgroundColor: backgroundColor,
            padding: EdgeInsets.zero,
            primary: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius)))));
  }
}

class Pebble4DividedRectButton extends StatelessWidget {
  final Widget? child;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final double strokeWidth;
  final double? curveSize;

  Pebble4DividedRectButton({
    required this.onPressed,
    this.borderColor = Colors.black,
    this.curveSize,
    this.child,
    this.strokeWidth = 3.0,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: this.child!,
      onPressed: this.onPressed,
      onLongPress: () {},
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled))
              return backgroundColor.withOpacity(0.7);
            else
              return backgroundColor;
          }),
          padding: MaterialStateProperty.all(EdgeInsets.zero)),
    );
  }
}


class ConnectButton extends StatelessWidget {
  final Image image;
  final String text;
  final VoidCallback onTap;
  const ConnectButton({Key? key, required this.image, required this.text, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              SizedBox(width: Zeplin.size(16)),
              Text(text, style: TextStyle(fontSize: Zeplin.size(32), fontWeight: FontWeight.w500, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}
