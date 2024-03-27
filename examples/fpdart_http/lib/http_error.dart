sealed class HttpError {
  const HttpError();
}

final class RequestError extends HttpError {
  const RequestError();
}

final class ResponseError extends HttpError {
  const ResponseError();
}
