// ignore_for_file: library_private_types_in_public_api

/// Compose a series of functions, the output of the previous function in the chain
/// is automatically passed as input to the next function in the chain.
///```dart
/// int x2(int a) => a * 2;
///
/// /// Compose one input 1️⃣
/// final compose1 = const Compose(x2, 2).c1(x2);
///```
/// Used to compose functions with **only one input** of type `Input`.
/// If the function has more than one input, use [Compose2], [Compose3] (coming soon), etc.

class Compose<Input, Output> {
  final Input _input;
  final Output Function(Input input) _compose;

  /// Instance of [Compose] given the function `Output Function(Input input)` to execute
  /// and the `Input` to pass to the function.
  const Compose(this._compose, this._input);

  /// Chain a function that takes the output `Output` from this [Compose] and
  /// returns a new [Compose] that when called will execute `c1Compose`,
  /// returning a value of type `ComposedOutput`.
  Compose<Input, ComposedOutput> c1<ComposedOutput>(
    ComposedOutput Function(Output output) c1Compose,
  ) =>
      Compose<Input, ComposedOutput>(
        (input) => c1Compose(_compose(input)),
        _input,
      );

  /// Chain a function that takes two inputs:
  /// 1. The output `Output` from this [Compose]
  /// 2. A new input of type `ComposedInput`
  ///
  /// It returns a two-input composable object that when called will execute `c2Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose12<Input, Output, ComposedInput, ComposedOutput>
      c2<ComposedInput, ComposedOutput>(
    ComposedOutput Function(Output output, ComposedInput composedInput)
        c2Compose,
    ComposedInput c2Input,
  ) =>
          _ChainCompose12(c2Compose, _compose, _input, c2Input);

  /// Chain two [Compose]. The second [Compose] must have the same
  /// `Input` and `Output` of the first.
  /// ```dart
  /// int x2(int a) => a * 2;
  ///
  /// /// Compose operator ➕
  /// final composeOperator = x2.c(2) * x2.c;
  ///
  /// // ((2 * 2) * 2) = (2 * 2) = 8
  /// print(composeOperator());
  /// ```
  Compose<Input, Output> operator *(
    Compose<Input, Output> Function(Output output) other,
  ) =>
      c1((output) => other(output)());

  /// Compute the result of the chain.
  Output call() => _compose(_input);
}

/// Compose a series of functions, the output of the previous function in the chain
/// is automatically passed as input to the next function in the chain.
///```dart
/// int sub(int a, int b) => a - b;
///
/// /// Compose two inputs 2️⃣
/// final compose2 = const Compose2(sub, 2, 4).c2(sub, 2);
///```
/// Used to compose functions with **two inputs** of type `Input1` and `Input2`.
/// If the function has a different number of inputs, use [Compose1], [Compose3] (coming soon), etc.
class Compose2<Input1, Input2, Output> {
  final Input1 _input1;
  final Input2 _input2;
  final Output Function(Input1 input1, Input2 input2) _compose;

  /// Instance of [Compose2] given the function `Output Function(Input1 input1, Input2 input2)`
  /// to execute and the `Input1` and `Input2` to pass to the function.
  const Compose2(this._compose, this._input1, this._input2);

  /// Chain a function that takes the output `Output` from this [Compose2] and
  /// returns a new [Compose] that when called will execute `c1Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose21<Input1, Input2, Output, ComposedOutput> c1<ComposedOutput>(
    ComposedOutput Function(Output output) c1Compose,
  ) =>
      _ChainCompose21(c1Compose, _compose, _input1, _input2);

  /// Chain a function that takes two inputs:
  /// 1. The output `Output` from this [Compose2]
  /// 2. A new input of type `ComposedInput`
  ///
  /// It returns a two-input composable object that when called will execute `c2Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose22<Input1, Input2, Output, ComposedInput, ComposedOutput>
      c2<ComposedInput, ComposedOutput>(
    ComposedOutput Function(Output output, ComposedInput c2input) c2Compose,
    ComposedInput composedInput,
  ) =>
          _ChainCompose22(c2Compose, _compose, _input1, _input2, composedInput);

  /// Chain two [Compose2]. The second operand must have inputs of type
  /// `Output` and `Input2` and must return `Output`.
  /// ```dart
  /// int sub(int a, int b) => a - b;
  ///
  /// /// Compose operator ➕
  /// final composeOperator2 = sub.c(4, 2) * sub.c;
  ///
  /// // ((4 - 2) - 2) = (2 - 2) = 0
  /// print(composeOperator2());
  /// ```
  _ChainCompose22<Input1, Input2, Output, Input2, Output> operator *(
    Compose2<Input2, Output, Output> Function(Output output, Input2 input2)
        other,
  ) =>
      c2((output, input2) => other(output, input2)(), _input2);

  /// Compute the result of the chain.
  Output call() => _compose(_input1, _input2);
}

// --- Composition classes below 👇 --- //

/// Compose a function that takes 1 parameter with a function that takes 2 parameters
class _ChainCompose12<InputC1, OutputC1, InputC2, OutputC2> {
  final InputC1 _inputC1;
  final InputC2 _inputC2;
  final OutputC1 Function(InputC1 inputC1) _composeC1;
  final OutputC2 Function(OutputC1 outputC1, InputC2 inputC2) _composeC2;
  const _ChainCompose12(
      this._composeC2, this._composeC1, this._inputC1, this._inputC2);

  /// Chain a function that takes the output `OutputC2` from this composable and
  /// returns a new composable that when called will execute `c1Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose21<OutputC1, InputC2, OutputC2, ComposedOutput> c1<
              ComposedOutput>(
          ComposedOutput Function(OutputC2 outputC2) c1Compose) =>
      _ChainCompose21(c1Compose, _composeC2, _composeC1(_inputC1), _inputC2);

  /// Chain a function that takes two inputs:
  /// 1. The output `OutputC2` from this composable
  /// 2. A new input of type `ComposedInput`
  ///
  /// It returns a two-input composable object that when called will execute `c2Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose22<OutputC1, InputC2, OutputC2, ComposedInput, ComposedOutput>
      c2<ComposedInput, ComposedOutput>(
    ComposedOutput Function(OutputC2 outputC2, ComposedInput composedInput)
        c2Compose,
    ComposedInput composedInput,
  ) =>
          _ChainCompose22(c2Compose, _composeC2, _composeC1(_inputC1), _inputC2,
              composedInput);

  /// Compute the result of the chain.
  OutputC2 call() => _composeC2(_composeC1(_inputC1), _inputC2);
}

/// Compose a function that takes 2 parameters with a function that takes 1 parameter
class _ChainCompose21<Input1C2, Input2C2, OutputC2, OutputC1> {
  final Input1C2 _input1c2;
  final Input2C2 _input2c2;
  final OutputC1 Function(OutputC2 i) _composeC1;
  final OutputC2 Function(Input1C2 i1, Input2C2 i2) _composeC2;
  const _ChainCompose21(
      this._composeC1, this._composeC2, this._input1c2, this._input2c2);

  /// Chain a function that takes the output `OutputC1` from this composable and
  /// returns a new composable that when called will execute `c1Compose`,
  /// returning a value of type `ComposedOutput`.
  Compose<OutputC1, ComposedOutput> c1<ComposedOutput>(
    ComposedOutput Function(OutputC1 outputC1) c1Compose,
  ) =>
      Compose(c1Compose, call());

  /// Chain a function that takes two inputs:
  /// 1. The output `OutputC1` from this composable
  /// 2. A new input of type `ComposedInput`
  ///
  /// It returns a two-input composable object that when called will execute `c2Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose12<OutputC2, OutputC1, ComposedInput, ComposedOutput>
      c2<ComposedInput, ComposedOutput>(
    ComposedOutput Function(OutputC1 outputC1, ComposedInput composedInput)
        c2Compose,
    ComposedInput composedInput,
  ) =>
          _ChainCompose12(
            c2Compose,
            _composeC1,
            _composeC2(_input1c2, _input2c2),
            composedInput,
          );

  /// Compute the result of the chain.
  OutputC1 call() => _composeC1(_composeC2(_input1c2, _input2c2));
}

/// Compose a function that takes 2 parameters with another function that takes 2 parameters
class _ChainCompose22<Input1C2_1, Input2C2_1, OutputC2_1, InputC2_2,
    OutputC2_2> {
  final Input1C2_1 _input1c2_1;
  final Input2C2_1 _input2c2_1;
  final InputC2_2 _inputC2_2;
  final OutputC2_1 Function(
    Input1C2_1 input1c2_1,
    Input2C2_1 input2c2_1,
  ) _composeC2_1;
  final OutputC2_2 Function(
    OutputC2_1 outputC2_1,
    InputC2_2 inputC2_2,
  ) _composeC2_2;
  const _ChainCompose22(
    this._composeC2_2,
    this._composeC2_1,
    this._input1c2_1,
    this._input2c2_1,
    this._inputC2_2,
  );

  /// Chain a function that takes the output `Output` from this composable and
  /// returns a new composable that when called will execute `c1Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose21<OutputC2_1, InputC2_2, OutputC2_2, ComposedOutput>
      c1<ComposedOutput>(
    ComposedOutput Function(OutputC2_2 outputC2_2) c1Compose,
  ) =>
          _ChainCompose21(
            c1Compose,
            _composeC2_2,
            _composeC2_1(_input1c2_1, _input2c2_1),
            _inputC2_2,
          );

  /// Chain a function that takes two inputs:
  /// 1. The output `OutputC2_2` from this composable
  /// 2. A new input of type `ComposedInput`
  ///
  /// It returns a two-input composable object that when called will execute `c2Compose`,
  /// returning a value of type `ComposedOutput`.
  _ChainCompose22<OutputC2_1, InputC2_2, OutputC2_2, ComposedInput,
      ComposedOutput> c2<ComposedInput, ComposedOutput>(
    ComposedOutput Function(OutputC2_2 outputC2_2, ComposedInput composedInput)
        c2Compose,
    ComposedInput composedInput,
  ) =>
      _ChainCompose22(
        c2Compose,
        _composeC2_2,
        _composeC2_1(_input1c2_1, _input2c2_1),
        _inputC2_2,
        composedInput,
      );

  /// Compute the result of the chain.
  OutputC2_2 call() =>
      _composeC2_2(_composeC2_1(_input1c2_1, _input2c2_1), _inputC2_2);
}

// --- Extensions below 👇 --- //

extension ComposeOnFunction1<Input, Output> on Output Function(Input) {
  /// Build a [Compose] from the function that can be used to
  /// easily compose functions in a chain.
  Compose<Input, Output> c(Input input) => Compose(this, input);
}

extension ComposeOnFunction2<Input1, Input2, Output> on Output Function(
    Input1, Input2) {
  /// Build a [Compose2] from the function that can be used to
  /// easily compose functions in a chain.
  Compose2<Input1, Input2, Output> c(Input1 input1, Input2 input2) =>
      Compose2(this, input1, input2);
}
