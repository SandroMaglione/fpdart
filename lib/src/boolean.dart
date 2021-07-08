/// `fpdart` extension methods on [bool]
extension FpdartBoolean on bool {
  /// Pattern matching on [bool]. Execute `onFalse` when the value is `false`,
  /// otherwise execute `onTrue`.
  ///
  /// Same as `fold`.
  T match<T>(T Function() onFalse, T Function() onTrue) =>
      this ? onTrue() : onFalse();

  /// Pattern matching on [bool]. Execute `onFalse` when the value is `false`,
  /// otherwise execute `onTrue`.
  ///
  /// Same as `match`.
  T fold<T>(T Function() onFalse, T Function() onTrue) =>
      match(onFalse, onTrue);
}
