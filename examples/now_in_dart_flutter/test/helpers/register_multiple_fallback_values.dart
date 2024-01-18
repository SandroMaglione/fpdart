import 'package:mocktail/mocktail.dart';

void registerMultipleFallbackValues(List<Fake> values) {
  for (final value in values) {
    registerFallbackValue(value);
  }
}
