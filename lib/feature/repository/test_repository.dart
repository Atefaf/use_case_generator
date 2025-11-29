
import 'package:dartz/dartz.dart';
import 'package:use_case_generator/core/errors/failures.dart';
//!dart use_case_generator.dart -r test_repository.dart
 abstract class TestRepository {
  Future<String> getUser(String userId);
  Future<Either<Failure, List<String>>> getAllUsers();
  Future<Either<Failure, void>> deleteUser(String userId);
}

