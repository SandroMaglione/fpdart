import 'package:fpdart/fpdart.dart';

/// You must run one [Future] after the other, no way around this...
Future<int> asyncI() {
  return Future.value(10).then((value) => value * 10);
}

/// No need of `async`, you decide when to run the [Future] ⚡
Task<int> asyncF() {
  return Task(() async => 10).map((a) => a * 10);
}

void main() {}
