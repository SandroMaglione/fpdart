/// `fpdart` extension to chain methods on nullable values `T?`
extension FpdartOnNullable<T> on T? {
  /// Update the value using `f` if is not `null`,
  /// otherwise just return `null`.
  B? map<B>(B Function(T t) f) {
    final value = this;
    return value == null ? null : f(value);
  }

  /// {@template fpdart_nullable_extension_match}
  /// Execute and return the result of `onNotNull` if the value is not `null`,
  /// otherwise return the result of `onNotNull`.
  /// {@endtemplate}
  ///
  /// If you want to return nullable values, use `matchNullable`.
  B match<B>(B Function() onNull, B Function(T t) onNotNull) {
    final value = this;
    return value == null ? onNull() : onNotNull(value);
  }

  /// {@macro fpdart_nullable_extension_match}
  ///
  /// Same as `match`, but returns nullable values.
  B? matchNullable<B>(B? Function() onNull, B? Function(T t) onNotNull) {
    final value = this;
    return value == null ? onNull() : onNotNull(value);
  }
}
