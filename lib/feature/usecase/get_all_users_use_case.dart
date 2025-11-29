import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:use_case_generator/core/errors/failures.dart';
import 'package:use_case_generator/core/usecases/usecase.dart';
import 'package:use_case_generator/feature/repository/test_repository';

class GetAllUsersUseCase extends UseCase<List<String>, GetAllUsersUseCaseParams>{
   final TestRepository testRepository;
   GetAllUsersUseCase(this.testRepository);
  
  @override
  Future<Either<Failure, List<String>>> call(GetAllUsersUseCaseParams params) {
   return testRepository.getAllUsers();
  }
}

class GetAllUsersUseCaseParams extends Equatable{
  
  const GetAllUsersUseCaseParams();
  @override
  List<Object?> get props => [];
}
