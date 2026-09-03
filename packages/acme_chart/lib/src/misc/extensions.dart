import 'package:acme_chart/generated/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Build context extensions.
extension ContextExtension on BuildContext {
  /// Returns [ChartLocalization] of context.
  ChartLocalization get localization => ChartLocalization.of(this);
}
