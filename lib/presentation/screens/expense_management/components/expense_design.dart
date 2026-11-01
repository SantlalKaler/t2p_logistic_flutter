import 'package:flutter/material.dart';

import '../../../theme/app_design.dart';

/// Expense screens retain the same styling as the shared app design.
class ExpenseDesign {
  static const accent = AppDesign.accent;
  static const ink = AppDesign.ink;
  static const muted = AppDesign.muted;

  static ThemeData theme(BuildContext context) => AppDesign.theme(context);
}
