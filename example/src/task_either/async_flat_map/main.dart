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

String logFailure(ApiFailure apiFailure) {
  if (apiFailure is StudentFailure) {
    return 'Error while fetching list of students';
  } else if (apiFailure is CourseFailure) {
    return 'Error while fetching list of courses';
  } else {
    throw UnimplementedError();
  }
}

void main() async {
  /// How to call `getCoursesOfStudents` only if students is `Right`?
  ///
  /// Type: `TaskEither<ApiFailure, List<Course>>`
  final taskEitherRequest = getStudents.flatMap(getCoursesOfStudents);

  /// In case of error map `ApiFailure` to `String` using `logFailure`
  ///
  /// Type: `TaskEither<String, List<Course>>`
  final taskRequest = taskEitherRequest.mapLeft(logFailure);

  /// Run everything at the end!
  ///
  /// Type: `Either<String, List<Course>>`
  final result = await taskRequest.run();
}
