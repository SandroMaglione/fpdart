import 'dart:async';

extension FutureOrThenExtension<A> on FutureOr<A> {
  FutureOr<B> then<B>(FutureOr<B> Function(A a) f,
      {B Function(Object error, StackTrace stackTrace)? onError}) {
    switch (this) {
      case Future<A> self:
        return self.then(
          f,
          onError: (Object error, StackTrace stackTrace) {
            if (onError != null) onError(error, stackTrace);
          },
        );
      case A self:
        try {
          return f(self);
        } catch (error, stackTrace) {
          if (onError != null) return onError(error, stackTrace);
          rethrow;
        }
    }
  }
}
