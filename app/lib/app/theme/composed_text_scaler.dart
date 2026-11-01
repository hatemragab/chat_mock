import 'package:flutter/painting.dart';

/// Applies an app preference after the device's potentially nonlinear scaling.
class ComposedTextScaler extends TextScaler {
  const ComposedTextScaler(this.device, this.factor);
  final TextScaler device;
  final double factor;

  @override
  double scale(double fontSize) => device.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is ComposedTextScaler &&
      other.device == device &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(device, factor);
}
