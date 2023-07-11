// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/widgets.dart';
import 'package:square_web/debug/overlay_logger_widget.dart';

typedef void OnChangedCallback(String text);
typedef bool ValidatorCallback(String text);

class TextEditingDefault {
  final TextEditingController _textController = new TextEditingController(text: '');
  String get text => _textController.text;
  bool _isComposing = false;
  late State<StatefulWidget> _state;
  VoidCallback? _onPressedSubmit;
  OnChangedCallback? _onChanged;
  String? _name;
  String resultText = "";
  ValidatorCallback? _validatorCallback;

  void init(String name, State<StatefulWidget> state, {VoidCallback? onPressedSubmit, OnChangedCallback? onChanged, ValidatorCallback? validatorCallback}) {
    this._name = name;
    this._state = state;
    this._onPressedSubmit = () {
      resultText = _textController.text;
      resetOnSubmit(resultText);

      LogWidget.debug("$_name submitted : $resultText");

      onPressedSubmit!();
    };
    this._onChanged = onChanged;
    this._validatorCallback = validatorCallback;
  }

  TextEditingController get controller => _textController;
  bool get isComposing => _isComposing;

  void resetOnSubmit(String? text) {
    _textController.clear();
    _state.setState(_setStateOnSubmit);
  }

  void onSubmitted(String text) {
    _onPressedSubmit!();
  }

  void onCompleted() {
    _onPressedSubmit!();
  }

  void onChanged(String text) {
    _isComposing = text.length > 0;
    resultText = text;
    _state.setState(_setStateOnChange);
    _onChanged!(text);
  }

  VoidCallback? getOnPressedSubmit(bool onlyEmoticon) {
    if (_isComposing || onlyEmoticon) {
      return _onPressedSubmit;
    } else {
      return null;
    }
  }

  void _setStateOnSubmit() {
    _isComposing = false;
  }

  void _setStateOnChange() {
    _isComposing = _textController.text.characters.length > 0;
  }

  bool validation() {
    return _validatorCallback?.call(resultText) == true;
  }
}
