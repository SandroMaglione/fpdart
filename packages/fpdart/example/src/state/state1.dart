/// Source: http://www.learnyouahaskell.com/for-a-few-monads-more
import 'package:fpdart/src/state.dart';
import 'package:fpdart/src/unit.dart';

/// [Stack] is an alias for [List<String>].
typedef Stack = List<String>;

const Stack stack = ['a', 'b', 'c'];

/// Example Without State Monad
///
/// We need to explicitly pass the state [Stack] every time we call `pop` or `push`.

(String, Stack) pop(Stack s) => (s.last, s.sublist(0, s.length - 1));

(Unit, Stack) push(String value, Stack s) => (unit, [...s, value]);

/// Example Using State Monad
///
/// The global variable [Stack] is hidden using [State].

State<Stack, String> popState() => State(
      (s) => (s.last, s.sublist(0, s.length - 1)),
    );

State<Stack, Unit> pushState(String value) => State(
      (s) => (unit, [...s, value]),
    );

void main() {
  // Without State Monad
  final pop1NoState = pop(stack);
  final push1NoState = push('d', pop1NoState.$2);
  final pop2NoState = pop(push1NoState.$2);
  print('No State');
  print(stack);
  print('Pop');
  print(pop1NoState.$2);
  print(pop1NoState.$1);
  print("Push 'd'");
  print(push1NoState.$2);
  print('Pop');
  print(pop2NoState.$2);
  print(pop2NoState.$1);

  // Using State Monad
  print('---');
  print('Using State');
  final withState = popState().execute(
    pushState('d').execute(
      popState().run(stack).$2,
    ),
  );
  final withState2 = popState()(pushState('d'))(popState()).run(stack);
  print(withState);
  print(withState2);
}
