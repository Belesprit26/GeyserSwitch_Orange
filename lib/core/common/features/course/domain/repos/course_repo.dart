import 'package:gs_orange/core/common/features/course/domain/entities/course.dart';
import 'package:gs_orange/core/utils/typdefs.dart';

abstract class CourseRepo {
  const CourseRepo();

  ResultFuture<List<Course>> getCourses();

  ResultFuture<void> addCourse(Course course);
}
