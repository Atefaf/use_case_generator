import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaweave/core/errors/failures.dart';
import 'package:mangaweave/core/usecases/usecase.dart';
import '../test.dart';

class GetAllUsersUseCase extends UseCase<List<String>, GetAllUsersUseCaseParams>{
   final Test test;
   GetAllUsersUseCase(this.test);
  
  @override
  Future<Either<Failure, List<String>>> call(GetAllUsersUseCaseParams params) {
   return test.getAllUsers();
  }
}

class GetAllUsersUseCaseParams extends Equatable{
  
  const GetAllUsersUseCaseParams();
  @override
  List<Object?> get props => [];
}
