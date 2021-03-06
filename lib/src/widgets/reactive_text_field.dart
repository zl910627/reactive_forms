// Copyright 2020 Joan Pablo Jiménez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// A [ReactiveTextField] that contains a [TextField].
///
/// This is a convenience widget that wraps a [TextField] widget in a
/// [ReactiveTextField].
///
/// A [ReactiveForm] ancestor is required.
///
class ReactiveTextField<T> extends ReactiveFormField<T> {
  /// Creates a [ReactiveTextField] that contains a [TextField].
  ///
  /// Can optionally provide a [formControl] to bind this widget to a control.
  ///
  /// Can optionally provide a [formControlName] to bind this ReactiveFormField
  /// to a [FormControl].
  ///
  /// Must provide one of the arguments [formControl] or a [formControlName],
  /// but not both at the same time.
  ///
  /// You can optionally set the [validationMessages].
  ///
  /// For documentation about the various parameters, see the [TextField] class
  /// and [new TextField], the constructor.
  ReactiveTextField({
    Key key,
    String formControlName,
    FormControl formControl,
    Map<String, String> validationMessages,
    InputDecoration decoration = const InputDecoration(),
    TextInputType keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction,
    TextStyle style,
    StrutStyle strutStyle,
    TextDirection textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions toolbarOptions,
    bool showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    bool enableSuggestions = true,
    bool maxLengthEnforced = true,
    int maxLines = 1,
    int minLines,
    bool expands = false,
    int maxLength,
    GestureTapCallback onTap,
    List<TextInputFormatter> inputFormatters,
    double cursorWidth = 2.0,
    Radius cursorRadius,
    Color cursorColor,
    Brightness keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder buildCounter,
    ScrollPhysics scrollPhysics,
    VoidCallback onSubmitted,
    InputParser inputParser,
  }) : super(
          key: key,
          formControl: formControl,
          formControlName: formControlName,
          validationMessages: validationMessages ?? const {},
          builder: (ReactiveFormFieldState<T> field) {
            final state = field as _ReactiveTextFieldState;
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(state.context).inputDecorationTheme);

            state.inputParser = inputParser ??
                _ReactiveTextFieldState.getInputParser(field.control);

            return TextField(
              controller: state._textController,
              focusNode: state._focusNode,
              decoration:
                  effectiveDecoration.copyWith(errorText: state.errorText),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              textCapitalization: textCapitalization,
              autofocus: autofocus,
              toolbarOptions: toolbarOptions,
              readOnly: readOnly,
              showCursor: showCursor,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType ??
                  (obscureText
                      ? SmartDashesType.disabled
                      : SmartDashesType.enabled),
              smartQuotesType: smartQuotesType ??
                  (obscureText
                      ? SmartQuotesType.disabled
                      : SmartQuotesType.enabled),
              enableSuggestions: enableSuggestions,
              maxLengthEnforced: maxLengthEnforced,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              onChanged: state._onChanged,
              onTap: onTap,
              onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
              inputFormatters: inputFormatters,
              enabled: field.control.enabled,
              cursorWidth: cursorWidth,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              scrollPadding: scrollPadding,
              scrollPhysics: scrollPhysics,
              keyboardAppearance: keyboardAppearance,
              enableInteractiveSelection: enableInteractiveSelection,
              buildCounter: buildCounter,
            );
          },
        );

  @override
  ReactiveFormFieldState<T> createState() => _ReactiveTextFieldState<T>();
}

class _ReactiveTextFieldState<T> extends ReactiveFormFieldState<T> {
  TextEditingController _textController;
  FocusNode _focusNode = FocusNode();
  StreamSubscription _focusChangesSubscription;
  InputParser inputParser;
  bool _isUpdatingControl = false;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(text: this.value?.toString());
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    this.unsubscribeControl();
    super.dispose();
  }

  @override
  void subscribeControl() {
    super.subscribeControl();
    _focusChangesSubscription =
        this.control.focusChanges.listen(_onFormControlFocusChanged);
  }

  @override
  Future<void> unsubscribeControl() async {
    await Future.wait([
      _focusChangesSubscription?.cancel(),
      super.unsubscribeControl(),
    ]);
  }

  @override
  void updateValueFromControl() {
    if (_isUpdatingControl) {
      _isUpdatingControl = false;
      return;
    }

    _textController.text = this.value == null ? '' : this.value.toString();
    super.updateValueFromControl();
  }

  void _onChanged(String value) {
    _isUpdatingControl = true;
    this.didChange(this.inputParser.parse(value));
  }

  static InputParser getInputParser(FormControl control) {
    if (control is FormControl<int>) {
      return IntInputParser();
    } else if (control is FormControl<double>) {
      return DoubleInputParser();
    }

    return DefaultInputParser();
  }

  void _onFormControlFocusChanged(bool focused) {
    if (focused && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    } else if (!focused && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !this.touched) {
      this.touch();
    }

    if (this.control.focused && !_focusNode.hasFocus) {
      this.control.unfocus();
    } else if (!this.control.focused && _focusNode.hasFocus) {
      this.control.focus();
    }
  }
}
