import 'package:acme_chart/generated/l10n.dart';
import 'package:flutter/material.dart';
import '../indicator_config.dart';
import '../indicator_item.dart';
import 'fcb_indicator_config.dart';

/// Rainbow indicator item in the list of indicator which provide this
/// indicators options menu.
class FractalChaosBandIndicatorItem extends IndicatorItem {
  /// Initializes
  const FractalChaosBandIndicatorItem({
    required super.updateIndicator,
    required super.deleteIndicator,
    super.key,
    FractalChaosBandIndicatorConfig super.config =
        const FractalChaosBandIndicatorConfig(),
  }) : super(title: 'Fractal Chaos Band Indicator');

  @override
  IndicatorItemState<IndicatorConfig> createIndicatorItemState() =>
      FractalChaosBandIndicatorItemState();
}

/// Rainbow IndicatorItem State class
class FractalChaosBandIndicatorItemState
    extends IndicatorItemState<FractalChaosBandIndicatorConfig> {
  /// Rainbow MA bands count
  @protected
  bool? _channelFill;

  @override
  FractalChaosBandIndicatorConfig updateIndicatorConfig() =>
      (widget.config as FractalChaosBandIndicatorConfig).copyWith(
        showChannelFill: currentChannelFill,
      );

  @override
  Widget getIndicatorOptions() => Container();

  // TODO(samin): will add this option after apply the channel fill
  /// Builds show lines option
  @protected
  Widget buildShowChannelFillField() => Row(
    children: <Widget>[
      Text(
        ChartLocalization.of(context).labelLipsPeriod,
        style: const TextStyle(fontSize: 10),
      ),
      const SizedBox(width: 4),
      Switch(
        value: currentChannelFill,
        onChanged: (bool value) {
          setState(() {
            _channelFill = value;
          });
          updateIndicator();
        },
        activeTrackColor: Colors.lightGreenAccent,
        activeThumbColor: Colors.green,
      ),
    ],
  );

  /// Gets current show lines.
  @protected
  bool get currentChannelFill =>
      _channelFill ??
      (widget.config as FractalChaosBandIndicatorConfig).showChannelFill;
}
