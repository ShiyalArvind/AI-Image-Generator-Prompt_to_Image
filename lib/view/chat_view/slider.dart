import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';




class CustomRangeSlider extends StatelessWidget {
  final double values;
  final double min;
  final double max;
  final Function(double) onChanged;

  const CustomRangeSlider({
    super.key,
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SfSlider(
      value:values ,
      min: min,
      max: max,
      interval: 10,
      showTicks: true,
      showLabels: true,
      enableTooltip: true,
      minorTicksPerInterval: 1,
      onChanged: ( newValues) {
        onChanged(newValues); // Call the provided callback
      },
    );
  }
}
