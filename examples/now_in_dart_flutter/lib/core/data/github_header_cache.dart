import 'package:fpdart/fpdart.dart';
import 'package:isar/isar.dart';
import 'package:now_in_dart_flutter/core/data/github_header.dart';
import 'package:now_in_dart_flutter/core/data/isar_database.dart';

abstract class HeaderCache {
  Task<Unit> saveHeader(GithubHeader header);
  Task<GithubHeader?> getHeader(String path);
}

class GithubHeaderCache implements HeaderCache {
  GithubHeaderCache({
    IsarDatabase? isarDb,
  }) : _isarDb = isarDb ?? IsarDatabase();

  final IsarDatabase _isarDb;

  Isar get _isar => _isarDb.instance;

  IsarCollection<GithubHeader> get _githubHeaders => _isar.githubHeaders;

  @override
  Task<Unit> saveHeader(GithubHeader header) {
    final txn = _isar.writeTxn<Unit>(
      () async {
        await _githubHeaders.put(header);
        return unit;
      },
      silent: true,
    );
    return Task(() => txn);
  }

  @override
  Task<GithubHeader?> getHeader(String path) {
    return Task(() => _githubHeaders.getByPath(path));
  }
}
