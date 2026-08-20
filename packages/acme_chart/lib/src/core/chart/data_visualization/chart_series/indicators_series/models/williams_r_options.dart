import 'indicator_options.dart';

/// PSAR options
class WilliamsROptions extends IndicatorOptions {
  /// Initializes
  const WilliamsROptions(this.period, {super.showLastIndicator, super.pipSize});

  /// Period
  final int period;

  @override
  List<Object> get props => <Object>[period];
}
