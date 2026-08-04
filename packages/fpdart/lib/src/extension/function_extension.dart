/// Extension to allow building a pipe (analogous to Linux pipes) of functions through which
/// an input value can be eventually transformed to an output value
extension Pipe<Input> on Input {
  Output pipe<Output>(Output Function(Input value) transform) =>
      transform(this);
}

/// Similar to pipe but does not need a starting value as an input.
/// Can construct a composite function by piping multiple functions together.
extension Flow<ImplicitInput, FunOutput1> on FunOutput1 Function(
    ImplicitInput) {
  FunOutput2 Function(ImplicitInput) flow<FunOutput2>(
          FunOutput2 Function(FunOutput1) next) =>
      (ImplicitInput value) => next(this(value));
}
