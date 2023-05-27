import 'package:fpdart/fpdart.dart';

class Parent {
  final int value1;
  final double value2;
  const Parent(this.value1, this.value2);
}

void main() {
  /// Equality for values of type [Parent] based on their `value1` ([int]).
  final eqParentInt = Eq.eqInt.contramap<Parent>(
    (p) => p.value1,
  );

  /// Equality for of type [Parent] based on their `value2` ([double]).
  final eqParentDouble = Eq.eqDouble.contramap<Parent>(
    (p) => p.value2,
  );
}
