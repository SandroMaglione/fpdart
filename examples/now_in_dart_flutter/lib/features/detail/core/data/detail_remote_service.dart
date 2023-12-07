import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:now_in_dart_flutter/core/data/data.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';

typedef _FailureOrRemoteResponse = TaskEither<Failure, RemoteResponse<String>>;

abstract class DetailRemoteService {
  DetailRemoteService({
    Dio? dio,
    HeaderCache? headerCache,
  })  : _dio = dio ?? Dio(),
        _headerCache = headerCache ?? GithubHeaderCache();

  final Dio _dio;
  final HeaderCache _headerCache;

  @protected
  @visibleForTesting
  _FailureOrRemoteResponse getDetail(
    int id,
    String fullPathToMarkdownFile,
  ) {
    return TaskEither.Do(
      (_) async {
        final requestUri = await _(
          uriParser(fullPathToMarkdownFile).toTaskEither(),
        );

        final cachedHeader = await _(
          _headerCache.getHeader(fullPathToMarkdownFile).toTaskEither(),
        );

        return _(
          TaskEither<Failure, Response<String>>.tryCatch(
            () => _dio.getUri<String>(
              requestUri,
              options: Options(
                headers: <String, String>{
                  'If-None-Match': cachedHeader?.eTag ?? '',
                },
              ),
            ),
            (e, stackTrace) {
              return ApiFailure(
                'Error on network request',
                errorObject: e,
                stackTrace: stackTrace,
              );
            },
          ).flatMap(
            (response) {
              return TaskEither<Failure, RemoteResponse<String>>(
                () async {
                  if (response.statusCode == 200) {
                    final header = GithubHeader.parse(
                      id,
                      response,
                      fullPathToMarkdownFile,
                    );

                    await _(_headerCache.saveHeader(header).toTaskEither());

                    final html = response.data!;
                    return right(ModifiedRemoteResponse(html));
                  }

                  return right(const UnModifiedRemoteResponse());
                },
              );
            },
          ).orElse(
            (failure) {
              final error = failure.errorObject;
              if (error is DioException && error.isNoConnectionError) {
                return TaskEither.right(const NoConnectionRemoteResponse());
              }
              return TaskEither.left(failure);
            },
          ),
        );
      },
    );
  }
}
