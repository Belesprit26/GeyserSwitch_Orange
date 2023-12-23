import 'package:gs_orange/core/common/features/course/domain/entities/course.dart';
import 'package:gs_orange/core/common/features/course/domain/repos/course_repo.dart';
import 'package:gs_orange/core/usecases/usecases.dart';
import 'package:gs_orange/core/utils/typdefs.dart';

class AddCourse extends UsecaseWithParams<void, Course> {
  const AddCourse(this._repo);

  final CourseRepo _repo;

  @override
  ResultFuture<void> call(Course params) async => _repo.addCourse(params);
}
