import 'package:equatable/equatable.dart';
import 'package:use_case_generator/core/usecases/usecase.dart';
import 'package:use_case_generator/feature/repository/test_repository';

class GetUserUseCase extends UseCase<String, GetUserUseCaseParams>{
   final TestRepository testRepository;
   GetUserUseCase(this.testRepository);
  
  @override
  Future<String> call(GetUserUseCaseParams params) {
   return testRepository.getUser(params.userId);
  }
}

class GetUserUseCaseParams extends Equatable{
  final String userId;
  const GetUserUseCaseParams(this.userId);
  @override
  List<Object?> get props => [userId];
}
