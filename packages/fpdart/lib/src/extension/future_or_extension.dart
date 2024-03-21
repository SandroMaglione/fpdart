import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f, {Function? onError}) =>
      switch (this) {
        final Future<A> self => self.then(f, onError: onError),
        final A self => f(self),
      };
}
