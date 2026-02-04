import 'package:flutter/foundation.dart';

/// Notifier whose value getter and setter uses the given functions
class FunctionNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  FunctionNotifier(T Function() getValue, void Function(T) setValue)
    : _getValue = getValue,
      _setValue = setValue;

  T Function() _getValue;
  void Function(T) _setValue;

  @override
  get value => _getValue();

  void set value(T newValue) {
    _setValue(newValue);
    notifyListeners();
  }
}
