import 'package:acme_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/ma_indicator/ma_indicator_item.dart';
import 'package:flutter/material.dart';

import '../indicator_config.dart';
import '../indicator_item.dart';
import 'dpo_indicator_config.dart';

/// Detrended Price Oscillator indicator item in the list of indicator which
/// provide this indicators options menu.
class DPOIndicatorItem extends IndicatorItem {
  /// Initializes
  const DPOIndicatorItem({
    required super.updateIndicator,
    required super.deleteIndicator,
    super.key,
    DPOIndicatorConfig super.config = const DPOIndicatorConfig(),
  }) : super(
          title: 'DPO',
        );

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      DPOIndicatorItemState();
}

/// DpoIndicatorItem State class
class DPOIndicatorItemState extends MAIndicatorItemState {
  @override
  DPOIndicatorConfig updateIndicatorConfig() =>
      (widget.config as DPOIndicatorConfig).copyWith(
        period: getCurrentPeriod(),
        movingAverageType: getCurrentType(),
        fieldType: getCurrentField(),
      );

  @override
  Widget getIndicatorOptions() => Column(
        children: <Widget>[
          buildMATypeMenu(),
          Row(
            children: <Widget>[
              buildPeriodField(),
              const SizedBox(width: 10),
              buildFieldTypeMenu(),
            ],
          ),
        ],
      );

  @override
  int getCurrentPeriod() =>
      period ?? (widget.config as MAIndicatorConfig).period;
}
