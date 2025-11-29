import 'package:auto_use_case/src/models/parameter.dart';

class RepositoryFunction {
  final String name;
  final String returnType;
  final List<Parameter> parameters;
  final bool hasEither;
  final bool isVoid;

  const RepositoryFunction({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.hasEither,
    this.isVoid = false,
  });
}
