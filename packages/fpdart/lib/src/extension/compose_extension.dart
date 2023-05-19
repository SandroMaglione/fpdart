import '../compose.dart';

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
