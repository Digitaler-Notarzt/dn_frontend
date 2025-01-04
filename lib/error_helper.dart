import 'package:flutter/material.dart';

class ErrorNotifier{
  /// Global Error Handler.
  
  static final ErrorNotifier _instance = ErrorNotifier._internal();
  factory ErrorNotifier() => _instance;
  ErrorNotifier._internal();

  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);

  ValueNotifier<String?> get errorMessageNotifier => _errorMessageNotifier;

  void showError(String message) {
    _errorMessageNotifier.value = message;
  }

  void clearError() {
    _errorMessageNotifier.value = null;
  }
}