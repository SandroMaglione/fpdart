import 'package:equatable/equatable.dart';

sealed class RemoteResponse<T> extends Equatable {
  const RemoteResponse();

  @override
  List<Object?> get props => [];
}

class NoConnectionRemoteResponse<T> extends RemoteResponse<T> {
  const NoConnectionRemoteResponse();
}

class UnModifiedRemoteResponse<T> extends RemoteResponse<T> {
  const UnModifiedRemoteResponse();
}

class ModifiedRemoteResponse<T> extends RemoteResponse<T> {
  const ModifiedRemoteResponse(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

extension RemoteResponseExt<T> on RemoteResponse<T> {
  A when<A>({
    required A Function() noConnection,
    required A Function() unmodified,
    required A Function(T data) modified,
  }) {
    return switch (this) {
      NoConnectionRemoteResponse() => noConnection(),
      UnModifiedRemoteResponse() => unmodified(),
      ModifiedRemoteResponse(:final data) => modified(data),
    };
  }
}
