part of 'flutter_detail_bloc.dart';

sealed class FlutterDetailEvent {
  const FlutterDetailEvent();
}

class FlutterWhatsNewDetailRequested extends FlutterDetailEvent {
  const FlutterWhatsNewDetailRequested(this.id);

  final int id;
}

class FlutterReleaseNotesDetailRequested extends FlutterDetailEvent {
  const FlutterReleaseNotesDetailRequested(this.id);

  final int id;
}

extension FlutterDetailEventExt on FlutterDetailEvent {
  A when<A>({
    required A Function(int) flutterWhatsNewDetailRequested,
    required A Function(int) flutterReleaseNotesDetailRequested,
  }) {
    return switch (this) {
      FlutterWhatsNewDetailRequested(:final id) =>
        flutterWhatsNewDetailRequested(id),
      FlutterReleaseNotesDetailRequested(:final id) =>
        flutterReleaseNotesDetailRequested(id),
    };
  }
}
