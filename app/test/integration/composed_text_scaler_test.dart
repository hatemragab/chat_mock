import 'package:app/app/theme/composed_text_scaler.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

class NonlinearDeviceScaler extends TextScaler {
  const NonlinearDeviceScaler();
  @override
  double scale(double fontSize) =>
      fontSize < 20 ? fontSize * 1.4 : fontSize * 1.2;
  @override
  double get textScaleFactor => 1.4;
}

void main() {
  test('app text preference multiplies the device nonlinear scaler', () {
    const scaler = ComposedTextScaler(NonlinearDeviceScaler(), 1.2);
    expect(scaler.scale(10), closeTo(16.8, .001));
    expect(scaler.scale(30), closeTo(43.2, .001));
  });
}
