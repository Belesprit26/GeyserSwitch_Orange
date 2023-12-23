import 'package:dartz/dartz.dart';
import 'package:gs_orange/core/common/features/course/domain/entities/course.dart';
import 'package:gs_orange/core/common/features/course/domain/repos/course_repo.dart';
import 'package:gs_orange/core/common/features/course/domain/usecases/get_courses.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'course_repo.mock.dart';

void main() {
  late CourseRepo repo;
  late GetCourses usecase;

  setUp(() {
    repo = MockCourseRepo();
    usecase = GetCourses(repo);
  });

  test('should get courses from the repo', () async {
    // arrange
    when(() => repo.getCourses()).thenAnswer((_) async => const Right([]));
    // act
    final result = await usecase();
    // assert
    expect(result, const Right<dynamic, List<Course>>([]));
    verify(() => repo.getCourses()).called(1);
    verifyNoMoreInteractions(repo);
  });
}
