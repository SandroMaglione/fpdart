import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f,
          {B Function(Object error)? onError}) =>
      switch (this) {
        final Future<A> self => self.then(f, onError: (Object error) {
            if (onError != null) onError(error);
          }),
        final A self => f(self),
      };
}
