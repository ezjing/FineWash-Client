import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppSnackBarType { success, warning, error }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  required AppSnackBarType type,
  int durationSeconds = 3,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final backgroundColor = switch (type) {
    AppSnackBarType.success => AppColors.success,
    AppSnackBarType.warning => AppColors.warning,
    AppSnackBarType.error => AppColors.error,
  };

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: durationSeconds),
    ),
  );
}
