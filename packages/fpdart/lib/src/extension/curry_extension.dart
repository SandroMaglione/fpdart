/// {@template fpdart_curry_extension}
/// Extract first parameter from this function to allow curring.
/// {@endtemplate}
///
/// {@template fpdart_curry_last_extension}
/// Extract **last** parameter from this function to allow curring.
/// {@endtemplate}

extension CurryExtension2<Input1, Input2, Output> on Output Function(
    Input1, Input2) {
  /// Convert this function from accepting two parameters to a function
  /// that returns another function both accepting one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input2) Function(Input1) get curry =>
      (input1) => (input2) => this(input1, input2);

  /// Convert this function from accepting two parameters to a function
  /// that returns another function both accepting one parameter.
  ///
  /// Curry the **last** parameter in the function.
  Output Function(Input1) Function(Input2) get curryLast =>
      (input2) => (input1) => this(input1, input2);
}

extension UncurryExtension2<Input1, Input2, Output> on Output Function(Input2)
    Function(Input1) {
  /// Convert a function that returns another function to a single function
  /// accepting two parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2) get uncurry =>
      (input1, input2) => this(input1)(input2);
}

extension CurryExtension3<Input1, Input2, Input3, Output> on Output Function(
    Input1, Input2, Input3) {
  /// Convert this function from accepting three parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input3) Function(Input2) Function(Input1) get curryAll =>
      (input1) => (input2) => (input3) => this(input1, input2, input3);

  /// {@macro fpdart_curry_extension}
  Output Function(Input2, Input3) Function(Input1) get curry =>
      (input1) => (input2, input3) => this(input1, input2, input3);

  /// {@macro fpdart_curry_last_extension}
  Output Function(Input1, Input2) Function(Input3) get curryLast =>
      (input3) => (input1, input2) => this(input1, input2, input3);
}

extension UncurryExtension3<Input1, Input2, Input3, Output>
    on Output Function(Input3) Function(Input2) Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting three parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3) get uncurry =>
      (input1, input2, input3) => this(input1)(input2)(input3);
}

extension CurryExtension4<Input1, Input2, Input3, Input4, Output> on Output
    Function(Input1, Input2, Input3, Input4) {
  /// Convert this function from accepting four parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input4) Function(Input3) Function(Input2) Function(Input1)
      get curryAll => (input1) => (input2) =>
          (input3) => (input4) => this(input1, input2, input3, input4);

  /// {@macro fpdart_curry_extension}
  Output Function(Input2, Input3, Input4) Function(Input1) get curry =>
      (input1) =>
          (input2, input3, input4) => this(input1, input2, input3, input4);

  /// {@macro fpdart_curry_last_extension}
  Output Function(Input1, Input2, Input3) Function(Input4) get curryLast =>
      (input4) =>
          (input1, input2, input3) => this(input1, input2, input3, input4);
}

extension UncurryExtension4<Input1, Input2, Input3, Input4, Output>
    on Output Function(Input4) Function(Input3) Function(Input2) Function(
        Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting four parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4) get uncurry =>
      (Input1 input1, Input2 input2, Input3 input3, Input4 input4) =>
          this(input1)(input2)(input3)(input4);
}

extension CurryExtension5<Input1, Input2, Input3, Input4, Input5, Output>
    on Output Function(Input1, Input2, Input3, Input4, Input5) {
  /// Convert this function from accepting five parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input5) Function(Input4) Function(Input3) Function(Input2)
          Function(Input1)
      get curryAll => (input1) => (input2) => (input3) =>
          (input4) => (input5) => this(input1, input2, input3, input4, input5);

  /// {@macro fpdart_curry_extension}
  Output Function(Input2, Input3, Input4, Input5) Function(Input1) get curry =>
      (input1) => (input2, input3, input4, input5) =>
          this(input1, input2, input3, input4, input5);

  /// {@macro fpdart_curry_last_extension}
  Output Function(Input1, Input2, Input3, Input4) Function(Input5)
      get curryLast => (input5) => (input1, input2, input3, input4) =>
          this(input1, input2, input3, input4, input5);
}

extension UncurryExtension5<Input1, Input2, Input3, Input4, Input5, Output>
    on Output Function(Input5) Function(Input4) Function(Input3) Function(
            Input2)
        Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting five parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4, Input5) get uncurry =>
      (input1, input2, input3, input4, input5) =>
          this(input1)(input2)(input3)(input4)(input5);
}
