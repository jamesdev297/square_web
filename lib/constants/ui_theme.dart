//test
import 'package:flutter/material.dart';

final ThemeData kIOSTheme = new ThemeData(
);

final ThemeData kDefaultTheme = new ThemeData(
    fontFamily: "Roboto",
    textTheme: TextTheme(
      headline1: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      headline2: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      headline3: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      headline4: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      headline5: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      headline6: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      bodyText1: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      bodyText2: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      subtitle1: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      subtitle2: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      caption: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      button: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
      overline: TextStyle(
          inherit: true, color: Colors.black, decoration: TextDecoration.none),
    ),
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
        focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))));

const atomOneDarkTheme = {
  'root':
  TextStyle(color: Color(0xffabb2bf), backgroundColor: Color(0xff282c34)),
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};
