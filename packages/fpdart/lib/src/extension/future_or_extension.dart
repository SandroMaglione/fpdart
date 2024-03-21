import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f) => switch (this) {
        final Future<A> self => self.then(f),
        final A self => f(self),
      };
}
