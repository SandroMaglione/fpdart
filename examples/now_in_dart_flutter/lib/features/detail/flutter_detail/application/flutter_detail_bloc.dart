import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:now_in_dart_flutter/core/domain/failure.dart';
import 'package:now_in_dart_flutter/core/domain/fresh.dart';
import 'package:now_in_dart_flutter/features/detail/core/domain/detail.dart';
import 'package:now_in_dart_flutter/features/detail/flutter_detail/data/flutter_detail_repository.dart';

part 'flutter_detail_event.dart';
part 'flutter_detail_state.dart';

typedef _DetailFailureOrSuccess = TaskEither<Failure, Fresh<Detail>>;

class FlutterDetailBloc extends Bloc<FlutterDetailEvent, FlutterDetailState> {
  FlutterDetailBloc({
    required FlutterDetailRepository repository,
  })  : _repository = repository,
        super(const FlutterDetailState()) {
    on<FlutterDetailEvent>(
      (event, emit) async {
        await event.when(
          flutterWhatsNewDetailRequested: (id) {
            return _onFlutterWhatsNewDetailRequested(emit, id);
          },
          flutterReleaseNotesDetailRequested: (id) {
            return _onFlutterReleaseNotesDetailRequested(emit, id);
          },
        );
      },
    );
  }

  final FlutterDetailRepository _repository;

  Future<Unit> _onFlutterWhatsNewDetailRequested(
    Emitter<FlutterDetailState> emit,
    int id,
  ) {
    return _onFlutterDetailRequested(
      _repository.getWhatsNewFlutterDetail,
      emit,
      id,
    );
  }

  Future<Unit> _onFlutterReleaseNotesDetailRequested(
    Emitter<FlutterDetailState> emit,
    int id,
  ) {
    return _onFlutterDetailRequested(
      _repository.getFlutterReleaseNotesDetail,
      emit,
      id,
    );
  }

  Future<Unit> _onFlutterDetailRequested(
    _DetailFailureOrSuccess Function(int) caller,
    Emitter<FlutterDetailState> emit,
    int id,
  ) async {
    emit(state.copyWith(status: () => FlutterDetailStatus.loading));
    final failureOrSuccessDetail = await caller(id).run();
    return failureOrSuccessDetail.match(
      (failure) {
        emit(
          state.copyWith(
            status: () => FlutterDetailStatus.failure,
            failureMessage: () {
              return switch (failure) {
                ApiFailure() => failure.message,
                UriParserFailure() => failure.message,
              };
            },
          ),
        );
        return unit;
      },
      (detail) {
        emit(
          state.copyWith(
            status: () => FlutterDetailStatus.success,
            detail: () => detail,
            failureMessage: () => null,
          ),
        );
        return unit;
      },
    );
  }
}
