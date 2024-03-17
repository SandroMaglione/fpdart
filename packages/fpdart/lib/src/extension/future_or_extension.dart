import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f) {
    if (this is Future) {
      return (this as Future<A>).then(f);
    }

    return f(this as A);
  }
}
