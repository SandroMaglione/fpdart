import 'package:fpdart/fpdart.dart';

class Parent {
  final int value1;
  final double value2;
  const Parent(this.value1, this.value2);
}

void main() {
  /// Order values of type [Parent] based on their `value1` ([int]).
  final orderParentInt = Order.orderInt().contramap<Parent>(
    (p) => p.value1,
  );

  /// Order values of type [Parent] based on their `value2` ([double]).
  final orderParentDouble = Order.orderDouble().contramap<Parent>(
    (p) => p.value2,
  );
}
