class Unit {
  static const Unit _unit = Unit._instance();
  const Unit._instance();

  @override
  String toString() => '()';
}

const unit = Unit._unit;
