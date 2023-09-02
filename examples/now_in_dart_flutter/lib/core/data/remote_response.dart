sealed class RemoteResponse<T> {
  const RemoteResponse();
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
}

extension RemoteResponseExt<T> on RemoteResponse<T> {
  A when<A>({
    required A Function() noConnection,
    required A Function() unmodifed,
    required A Function(T data) modified,
  }) {
    return switch (this) {
      NoConnectionRemoteResponse() => noConnection(),
      UnModifiedRemoteResponse() => unmodifed(),
      ModifiedRemoteResponse(:final data) => modified(data),
    };
  }
}
