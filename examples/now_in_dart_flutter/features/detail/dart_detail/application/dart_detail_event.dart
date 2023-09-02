part of 'dart_detail_bloc.dart';

sealed class DartDetailEvent {
  const DartDetailEvent();
}

class DartChangelogDetailRequested extends DartDetailEvent {
  const DartChangelogDetailRequested(this.id);

  final int id;
}

extension DartDetailEventExt on DartDetailEvent {
  A when<A>({required A Function(int) changelogDetailRequested}) {
    return switch (this) {
      DartChangelogDetailRequested(:final id) => changelogDetailRequested(id),
    };
  }
}
