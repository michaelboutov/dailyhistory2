import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailyhistor/src/localization/string_hardcoded.dart';
import 'package:dailyhistor/src/utils/alert_dialogs.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    debugPrint('isLoading: $isLoading, hasError: $hasError');
    if (!isLoading && hasError) {
      final message = error.toString();
      showExceptionAlertDialog(
        context: context,
        title: 'Error'.hardcoded,
        exception: message,
      );
    }
  }
}
