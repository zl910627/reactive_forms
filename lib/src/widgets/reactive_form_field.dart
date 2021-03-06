// Copyright 2020 Joan Pablo Jiménez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Signature for building the widget representing the form field.
///
/// Used by [FormField.builder].
typedef ReactiveFormFieldBuilder<T> = Widget Function(
    ReactiveFormFieldState<T> field);

/// A single reactive form field.
///
/// This widget maintains the current state of the reactive form field,
/// so that updates and validation errors are visually reflected in the UI.
///
/// It is the base class for all other reactive widgets.
class ReactiveFormField<T> extends StatefulWidget {
  /// Function that returns the widget representing this form field. It is
  /// passed the form field state as input, containing the current value and
  /// validation state of this field.
  final ReactiveFormFieldBuilder<T> _builder;

  /// The name of the [FormControl] that is bound to this widget.
  final String formControlName;

  /// The control that is bound to this widget.
  final FormControl formControl;

  /// A [Map] that store custom validation messages for each error.
  final Map<String, String> validationMessages;

  /// Creates an instance of the [ReactiveFormField].
  ///
  /// Must provide a [forControlName] or a [formControl] but not both
  /// at the same time.
  ///
  /// The [builder] arguments are required.
  const ReactiveFormField({
    Key key,
    this.formControl,
    this.formControlName,
    @required ReactiveFormFieldBuilder<T> builder,
    Map<String, String> validationMessages,
  })  : assert(
            (formControlName != null && formControl == null) ||
                (formControlName == null && formControl != null),
            'Must provide a formControlName or a formControl, but not both at the same time.'),
        assert(builder != null),
        _builder = builder,
        validationMessages = validationMessages ?? const {},
        super(key: key);

  @override
  ReactiveFormFieldState<T> createState() => ReactiveFormFieldState<T>();
}

/// Represents the state of the [ReactiveFormField] stateful widget.
class ReactiveFormFieldState<T> extends State<ReactiveFormField<T>> {
  /// The [FormControl] that is bound to this state.
  FormControl control;
  bool _touched;
  StreamSubscription _valueChangesSubscription;
  StreamSubscription _statusChangesSubscription;
  StreamSubscription _touchChangesSubscription;

  /// The current value of the [FormControl].
  T get value => this.control.value;

  /// Gets true if the widget is touched, otherwise return false.
  bool get touched => _touched;

  /// Sets the value of [touched] and rebuilds the widget.
  set touched(bool value) {
    if (this._touched != value) {
      setState(() {
        this._touched = value;
      });
    }
  }

  /// Gets the error text calculated from validators of the control.
  ///
  /// If the control has several errors, then the first error is selected
  /// for visualizing in UI.
  String get errorText {
    if (this.control.invalid && this.touched) {
      return widget.validationMessages
              .containsKey(this.control.errors.keys.first)
          ? widget.validationMessages[this.control.errors.keys.first]
          : this.control.errors.keys.first;
    }

    return null;
  }

  @override
  void initState() {
    this.control = _getFormControl();
    this.subscribeControl();

    super.initState();
  }

  @override
  void didChangeDependencies() async {
    final newControl = _getFormControl();
    if (this.control != newControl) {
      await this.unsubscribeControl();
      this.control = newControl;
      subscribeControl();
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this.unsubscribeControl();
    super.dispose();
  }

  @protected
  void subscribeControl() {
    _statusChangesSubscription =
        this.control.statusChanged.listen(_onControlStatusChanged);
    _valueChangesSubscription =
        this.control.valueChanges.listen(_onControlValueChanged);
    _touchChangesSubscription =
        this.control.touchChanges.listen(_onControlTouched);

    this._touched = this.control.touched;
  }

  @protected
  Future<void> unsubscribeControl() async {
    await Future.wait([
      _statusChangesSubscription.cancel(),
      _valueChangesSubscription.cancel(),
      _touchChangesSubscription.cancel(),
    ]);
  }

  FormControl _getFormControl() {
    if (widget.formControl != null) {
      return widget.formControl;
    }

    final form =
        ReactiveForm.of(context, listen: false) as FormControlCollection;
    if (form == null) {
      throw FormControlParentNotFoundException(widget);
    }

    return form.control(widget.formControlName);
  }

  void _onControlValueChanged(_) {
    this.updateValueFromControl();
    this.touched = this.control.touched;
  }

  void _onControlStatusChanged(ControlStatus status) {
    setState(() {});
  }

  void _onControlTouched(bool touched) {
    this.touched = touched;
  }

  @protected
  void updateValueFromControl() {}

  @protected
  void touch() {
    this.control.touch();
  }

  /// Updates this field's state to the new value. Useful for responding to
  /// child widget changes.
  ///
  /// Updates the value of the [FormControl] bound to this widget.
  void didChange(T value) {
    this.control.value = value;
    if (this.touched) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(this);
  }
}
