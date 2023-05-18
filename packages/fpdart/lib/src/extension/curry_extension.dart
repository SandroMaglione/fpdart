extension CurryExtension2<Input1, Input2, Output> on Output Function(
    Input1, Input2) {
  /// Convert this function from accepting two parameters to a function
  /// that returns another function both accepting one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input2) curry(Input1 input1) =>
      (input2) => this(input1, input2);
}

extension UncurryExtension2<Input1, Input2, Output> on Output Function(Input2)
    Function(Input1) {
  /// Convert a function that returns another function to a single function
  /// accepting two parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2) uncurry() =>
      (Input1 input1, Input2 input2) => this(input1)(input2);
}

extension CurryExtension3<Input1, Input2, Input3, Output> on Output Function(
    Input1, Input2, Input3) {
  /// Convert this function from accepting three parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input3) Function(Input2) curry(Input1 input1) =>
      (input2) => (input3) => this(input1, input2, input3);
}

extension UncurryExtension3<Input1, Input2, Input3, Output>
    on Output Function(Input3) Function(Input2) Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting three parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3) uncurry() =>
      (Input1 input1, Input2 input2, Input3 input3) =>
          this(input1)(input2)(input3);
}

extension CurryExtension4<Input1, Input2, Input3, Input4, Output> on Output
    Function(Input1, Input2, Input3, Input4) {
  /// Convert this function from accepting four parameters to a series
  /// of functions that all accept one parameter.
  ///
  /// Inverse of `uncurry`.
  Output Function(Input4) Function(Input3) Function(Input2) curry(
          Input1 input1) =>
      (input2) => (input3) => (input4) => this(input1, input2, input3, input4);
}

extension UncurryExtension4<Input1, Input2, Input3, Input4, Output>
    on Output Function(Input4) Function(Input3) Function(Input2) Function(
        Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting four parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4) uncurry() =>
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
      curry(Input1 input1) => (input2) => (input3) =>
          (input4) => (input5) => this(input1, input2, input3, input4, input5);
}

extension UncurryExtension5<Input1, Input2, Input3, Input4, Input5, Output>
    on Output Function(Input5) Function(Input4) Function(Input3) Function(
            Input2)
        Function(Input1) {
  /// Convert a function that returns a series of functions to a single function
  /// accepting five parameters.
  ///
  /// Inverse of `curry`.
  Output Function(Input1, Input2, Input3, Input4, Input5) uncurry() =>
      (Input1 input1, Input2 input2, Input3 input3, Input4 input4,
              Input5 input5) =>
          this(input1)(input2)(input3)(input4)(input5);
}
