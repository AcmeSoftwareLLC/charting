import '../../../../../../theme/painting_styles/line_style.dart';

import '../ma_series.dart';
import 'indicator_options.dart';

/// Detrended Price Oscillator indicator options.
class DPOOptions extends MAOptions {
  /// Initializes
  const DPOOptions({
    super.period = 14,
    MovingAverageType movingAverageType = MovingAverageType.simple,
    this.isCentered = true,
    this.lineStyle,
    super.showLastIndicator,
    super.pipSize,
  }) : super(type: movingAverageType);

  /// Line style.
  final LineStyle? lineStyle;

  /// Wether the indicator should be calculated `Centered` or not.
  final bool isCentered;
}
