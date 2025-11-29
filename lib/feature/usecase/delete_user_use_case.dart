import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:use_case_generator/core/errors/failures.dart';
import 'package:use_case_generator/core/usecases/usecase.dart';
import 'package:use_case_generator/feature/repository/test_repository';
import 'package:use_case_generator/feature/repository/test_repository.dart';

class DeleteUserUseCase extends UseCase<void, DeleteUserUseCaseParams>{
   final TestRepository testRepository;
   DeleteUserUseCase(this.testRepository);
  
  @override
  Future<Either<Failure, void>> call(DeleteUserUseCaseParams params) {
   return testRepository.deleteUser(params.userId);
  }
}

class DeleteUserUseCaseParams extends Equatable{
  final String userId;
  const DeleteUserUseCaseParams(this.userId);
  @override
  List<Object?> get props => [userId];
}
