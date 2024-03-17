sealed class Exit<L, R> {
  const Exit();
  factory Exit.success(R value) => Success(value);
  factory Exit.failure(L value) => Failure(value);
}

class Success<L, R> extends Exit<L, R> {
  final R value;
  const Success(this.value);

  @override
  bool operator ==(Object other) => (other is Success) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "Exit.Success($value)";
  }
}

class Failure<L, R> extends Exit<L, R> {
  final L value;
  const Failure(this.value);

  @override
  bool operator ==(Object other) => (other is Failure) && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return "Exit.Failure($value)";
  }
}
