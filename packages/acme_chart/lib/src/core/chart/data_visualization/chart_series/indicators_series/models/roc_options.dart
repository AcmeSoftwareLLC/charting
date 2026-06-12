import '../../../../../../core/chart/data_visualization/chart_series/indicators_series/models/indicator_options.dart';

/// ROC indicator options.
class ROCOptions extends IndicatorOptions {
  /// Initializes
  const ROCOptions({
    this.period = 14,
    super.showLastIndicator,
    super.pipSize,
  });

  /// The Period
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
