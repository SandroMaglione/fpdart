import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f,
      {B Function(Object error)? onError}) {
    switch (this) {
      case Future<A> self:
        return self.then(
          f,
          onError: (Object error) {
            if (onError != null) onError(error);
          },
        );
      case A self:
        try {
          return f(self);
        } catch (error) {
          if (onError != null) return onError(error);
          rethrow;
        }
    }
  }
}
