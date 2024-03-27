enum Ordering {
  lessThan(-1),
  equal(0),
  greaterThan(1);

  const Ordering(this.order);
  factory Ordering.fromOrder(int order) => switch (order) {
        (< 0) => Ordering.lessThan,
        (> 0) => Ordering.greaterThan,
        _ => Ordering.equal
      };

  final int order;

  @override
  String toString() => '$name($order)';

  bool get isLessThan => this == Ordering.lessThan;
  bool get isGreaterThan => this == Ordering.greaterThan;
  bool get isEqual => this == Ordering.equal;
}
