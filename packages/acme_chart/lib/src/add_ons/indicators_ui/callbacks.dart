import 'package:acme_chart/src/core/chart/data_visualization/chart_series/series.dart';
import 'package:acme_chart/src/models/indicator_input.dart';
import 'package:acme_chart/src/models/tick.dart';
import 'package:acme_indicators/acme_indicators.dart';

import 'indicator_config.dart';

/// A function which takes list of ticks and creates the indicator [Series].
typedef IndicatorBuilder = Series Function(List<Tick> ticks);

/// A function which takes list of ticks and creates an Indicator on it.
typedef FieldIndicatorBuilder =
    Indicator<Tick> Function(IndicatorInput indicatorInput);

/// Callback to update indicator with new [indicatorConfig].
typedef UpdateIndicator = Function(IndicatorConfig indicatorConfig);
