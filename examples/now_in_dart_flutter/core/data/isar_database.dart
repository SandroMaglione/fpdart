import 'package:isar/isar.dart';
import 'package:now_in_dart_flutter/core/data/github_header.dart';
import 'package:now_in_dart_flutter/features/detail/core/data/detail_dto.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatabase {
  factory IsarDatabase() => _isarDatabase;
  IsarDatabase._internal();

  static final _isarDatabase = IsarDatabase._internal();

  late Isar _instance;

  Isar get instance => _instance;

  /// Initializes the isar database.
  ///
  /// This method needs to be called before accessing any isar-specific APIs.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isNotEmpty) return;
    _instance = await Isar.open(
      [GithubHeaderSchema, DetailDTOSchema],
      directory: dir.path,
    );
  }
}
