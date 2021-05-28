import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('PartialOrder', () async {
    test('.from', () async {
      final instance = PartialOrder.from((a1, a2) => null);
    });
  });
}
