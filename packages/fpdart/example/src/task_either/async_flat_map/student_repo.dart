import 'data.dart';

// ignore: avoid_classes_with_only_static_members
class StudentRepo {
  static Future<List<Student>> getAllStudents() async => [
        Student("Juan"),
        Student("Maria"),
      ];

  static Future<List<Course>> getAllCourses(List<Student> studentList) async =>
      [
        Course("Math"),
        Course("Physics"),
      ];
}
