import 'package:acme_chart/src/add_ons/extensions.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/aroon/aroon_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/commodity_channel_index/cci_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/stochastic_oscillator_indicator/stochastic_oscillator_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/roc/roc_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/dpo_indicator/dpo_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/gator/gator_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/awesome_oscillator/awesome_oscillator_indicator_config.dart';
import 'package:acme_chart/src/add_ons/indicators_ui/smi/smi_indicator_config.dart';
import 'package:acme_chart/src/add_ons/repository.dart';
import 'package:acme_chart/src/widgets/animated_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './ma_indicator/ma_indicator_config.dart';
import 'adx/adx_indicator_config.dart';
import 'alligator/alligator_indicator_config.dart';
import 'bollinger_bands/bollinger_bands_indicator_config.dart';
import 'donchian_channel/donchian_channel_indicator_config.dart';
import 'fcb_indicator/fcb_indicator_config.dart';
import 'ichimoku_clouds/ichimoku_cloud_indicator_config.dart';
import 'indicator_config.dart';
import 'ma_env_indicator/ma_env_indicator_config.dart';
import 'macd_indicator/macd_indicator_config.dart';
import 'parabolic_sar/parabolic_sar_indicator_config.dart';
import 'rainbow_indicator/rainbow_indicator_config.dart';
import 'rsi/rsi_indicator_config.dart';
import 'williams_r/williams_r_indicator_config.dart';
import 'zigzag_indicator/zigzag_indicator_config.dart';

/// Indicators dialog with selected indicators.
class IndicatorsDialog extends StatefulWidget {
  const IndicatorsDialog({super.key});

  @override
  State<IndicatorsDialog> createState() => _IndicatorsDialogState();
}

class _IndicatorsDialogState extends State<IndicatorsDialog> {
  IndicatorConfig? _selectedIndicator;

  @override
  Widget build(BuildContext context) {
    final Repository<IndicatorConfig> repo = context
        .watch<Repository<IndicatorConfig>>();

    return AnimatedPopupDialog(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<IndicatorConfig>(
                value: _selectedIndicator,
                hint: const Text('Select indicator'),
                items: const <DropdownMenuItem<IndicatorConfig>>[
                  DropdownMenuItem<IndicatorConfig>(
                    value: MAIndicatorConfig(),
                    child: Text('Moving average'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: MAEnvIndicatorConfig(),
                    child: Text('Moving average envelope'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: BollingerBandsIndicatorConfig(),
                    child: Text('Bollinger bands'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: DonchianChannelIndicatorConfig(),
                    child: Text('Donchian channel'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: AlligatorIndicatorConfig(),
                    child: Text('Alligator'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: RainbowIndicatorConfig(),
                    child: Text('Rainbow'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: ZigZagIndicatorConfig(),
                    child: Text('ZigZag'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: IchimokuCloudIndicatorConfig(),
                    child: Text('Ichimoku Clouds'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: ParabolicSARConfig(),
                    child: Text('Parabolic SAR'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: RSIIndicatorConfig(),
                    child: Text('RSI'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: CCIIndicatorConfig(),
                    child: Text('Commodity Channel Index'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: FractalChaosBandIndicatorConfig(),
                    child: Text('FCB'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: StochasticOscillatorIndicatorConfig(),
                    child: Text('StochasticOscillator'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: ADXIndicatorConfig(),
                    child: Text('ADX'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: DPOIndicatorConfig(),
                    child: Text('DPO'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: SMIIndicatorConfig(),
                    child: Text('Stochastic Momentum Index'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: WilliamsRIndicatorConfig(),
                    child: Text('Williams %R'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: AwesomeOscillatorIndicatorConfig(),
                    child: Text('AwesomeOscillator'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: MACDIndicatorConfig(),
                    child: Text('MACD'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: AroonIndicatorConfig(),
                    child: Text('Aroon'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: ROCIndicatorConfig(),
                    child: Text('Price Rate Of Changes'),
                  ),
                  DropdownMenuItem<IndicatorConfig>(
                    value: GatorIndicatorConfig(),
                    child: Text('Gator Oscillator'),
                  ),
                  // Add new indicators here.
                ],
                onChanged: (IndicatorConfig? config) {
                  setState(() {
                    _selectedIndicator = config;
                  });
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _selectedIndicator != null
                    ? () {
                        final IndicatorConfig config = _selectedIndicator!;
                        // TODO(Ramin): later this will handled internally by
                        // the repository itself.
                        final int postFixNumber = repo.getNumberForNewAddOn(
                          config,
                        );
                        repo.add(config.copyWith(number: postFixNumber));
                        setState(() {});
                      }
                    : null,
                child: const Text('Add'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: repo.items.length,
              itemBuilder: (BuildContext context, int index) =>
                  repo.items[index].getItem(
                    (IndicatorConfig updatedConfig) =>
                        repo.updateAt(index, updatedConfig),
                    () {
                      repo.removeAt(index);
                      setState(() {});
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
