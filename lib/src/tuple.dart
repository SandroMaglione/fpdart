class Tuple2<T1, T2> {
  final T1 value1;
  final T2 value2;
  const Tuple2(this.value1, this.value2);

  A apply<A>(A Function(T1 v1, T2 v2) f) => f(value1, value2);

  Tuple2<TN, T2> map1<TN>(TN Function(T1 v1) f) => Tuple2(f(value1), value2);
  Tuple2<T1, TN> map2<TN>(TN Function(T2 v2) f) => Tuple2(value1, f(value2));

  @override
  String toString() => 'Tuple2($value1, $value2)';

  Tuple2<T1, T2> copyWith({
    T1? value1,
    T2? value2,
  }) =>
      Tuple2(
        value1 ?? this.value1,
        value2 ?? this.value2,
      );
}
