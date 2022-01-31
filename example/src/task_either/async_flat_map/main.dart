import 'package:fpdart/fpdart.dart';

import 'data.dart';
import 'failure.dart';
import 'student_repo.dart';

TaskEither<ApiFailure, List<Student>> getStudents = TaskEither.tryCatch(
  () => StudentRepo.getAllStudents(),
  (_, __) => StudentFailure(),
);

TaskEither<ApiFailure, List<Course>> getCoursesOfStudents(
  List<Student> studentList,
) =>
    TaskEither.tryCatch(
      () => StudentRepo.getAllCourses(studentList),
      (_, __) => CourseFailure(),
    );

Future<void> logFailure(ApiFailure apiFailure) {
  /// Logs to online service like crashlytics
  throw UnimplementedError();
}

void main() {
  /// How to call `getCoursesOfStudents` only if students is `Right`?
  /// In case there aren't loaded, `logFailure`
  getStudents.flatMap(getCoursesOfStudents).match(logFailure, Future.value);
}
