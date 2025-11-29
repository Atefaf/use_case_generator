import 'dart:io';
import 'models/repository_function.dart';
import 'models/parameter.dart';

class UseCaseGenerator {
  final String repositoryName;
  final String featurePath;
  final String repositoryFilePath;
  final String projectName;
  final bool isProMode;

  UseCaseGenerator({
    required this.repositoryName,
    required this.featurePath,
    required this.repositoryFilePath,
    required this.isProMode,
  }) : projectName = _getProjectName();

  static String _getProjectName() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) return 'mangaweave';

      final content = pubspecFile.readAsStringSync();
      final nameMatch = RegExp(r'name:\s*(\w+)').firstMatch(content);
      return nameMatch?.group(1) ?? 'mangaweave';
    } catch (e) {
      return 'mangaweave';
    }
  }

  Future<void> generateUseCases(String repositoryCode) async {
    final functions = _parseRepositoryFunctions(repositoryCode);

    for (final function in functions) {
      await _generateUseCaseFile(function);
    }

    print('✅ Generated ${functions.length} use case files');
    print('🎯 Mode: ${isProMode ? 'PRO' : 'SIMPLE'}');
  }

  List<RepositoryFunction> _parseRepositoryFunctions(String code) {
    final lines = code.split('\n');
    final functions = <RepositoryFunction>[];

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('Future<Either<Failure,')) {
        final function = _parseEitherFunction(line);
        if (function != null) functions.add(function);
      } else if (trimmedLine.startsWith('Future<') &&
          trimmedLine.contains('(')) {
        final function = _parseSimpleFutureFunction(line);
        if (function != null) functions.add(function);
      }
    }

    return functions;
  }

  RepositoryFunction? _parseEitherFunction(String line) {
    try {
      final returnTypeMatch =
          RegExp(r'Future<Either<Failure,\s*([^>]*(?:<[^>]*>)?[^>]*)>')
              .firstMatch(line);
      final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);

      if (returnTypeMatch == null || functionMatch == null) return null;

      final returnType = returnTypeMatch.group(1)!.trim();
      final functionName = functionMatch.group(1)!;
      final paramsString = functionMatch.group(2)?.trim() ?? '';

      return RepositoryFunction(
        name: functionName,
        returnType: returnType,
        parameters: _parseParameters(paramsString),
        hasEither: true,
        isVoid: returnType == 'void',
      );
    } catch (e) {
      return null;
    }
  }

  RepositoryFunction? _parseSimpleFutureFunction(String line) {
    try {
      final returnTypeMatch = RegExp(r'Future<([^>]*)>').firstMatch(line);
      final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);

      if (returnTypeMatch == null || functionMatch == null) return null;

      final returnType = returnTypeMatch.group(1)!.trim();
      final functionName = functionMatch.group(1)!;
      final paramsString = functionMatch.group(2)?.trim() ?? '';

      return RepositoryFunction(
        name: functionName,
        returnType: returnType,
        parameters: _parseParameters(paramsString),
        hasEither: false,
        isVoid: returnType == 'void',
      );
    } catch (e) {
      return null;
    }
  }

  List<Parameter> _parseParameters(String paramsString) {
    final parameters = <Parameter>[];
    if (paramsString.isEmpty) return parameters;

    final paramParts = paramsString.split(',');
    for (final param in paramParts) {
      final trimmedParam = param.trim();
      if (trimmedParam.isNotEmpty) {
        final paramMatch =
            RegExp(r'(\w+(?:<[^>]*>)?)\s+(\w+)').firstMatch(trimmedParam);
        if (paramMatch != null) {
          parameters.add(Parameter(
            type: paramMatch.group(1)!,
            name: paramMatch.group(2)!,
          ));
        }
      }
    }
    return parameters;
  }

  Future<void> _generateUseCaseFile(RepositoryFunction function) async {
    final useCaseName = '${_pascalCase(function.name)}UseCase';
    final content = isProMode
        ? _generateProUseCase(function, useCaseName)
        : _generateSimpleUseCase(function, useCaseName);

    final directory = Directory(featurePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/${_toSnakeCase(useCaseName)}.dart');
    await file.writeAsString(content);

    print('📁 Generated: ${file.path}');
  }

  String _generateProUseCase(RepositoryFunction function, String useCaseName) {
    final paramsClassName = '${useCaseName}Params';
    final hasGenerics = function.returnType.contains('<');
    final repositoryImportPath = _getRepositoryImportPath();

    final imports = function.hasEither
        ? '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:$projectName/core/usecases/usecase.dart';
'''
        : '''
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/usecases/usecase.dart';
''';

    final returnType = function.isVoid ? 'void' : function.returnType;
    final returnStatement = function.hasEither
        ? 'Future<Either<Failure, $returnType${hasGenerics ? '>' : ''}>>'
        : 'Future<$returnType${hasGenerics ? '>' : ''}>';

    return '''
$imports
import '$repositoryImportPath';

class $useCaseName extends UseCase<$returnType${hasGenerics ? '>' : ''}, $paramsClassName>{
   final $repositoryName ${_toCamelCase(repositoryName)};
   $useCaseName(this.${_toCamelCase(repositoryName)});
  
  @override
  $returnStatement call($paramsClassName params) {
   return ${_toCamelCase(repositoryName)}.${function.name}(${_generateCallParams(function)});
  }
}

class $paramsClassName extends Equatable{
  ${_generateParamsProperties(function.parameters)}
  const $paramsClassName(${_generateParamsConstructor(function.parameters)});
  @override
  List<Object?> get props => [${_generatePropsList(function.parameters)}];
}
''';
  }

  String _generateSimpleUseCase(
      RepositoryFunction function, String useCaseName) {
    final repositoryImportPath = _getRepositoryImportPath();
    final returnType = function.isVoid ? 'void' : function.returnType;

    final imports = function.hasEither
        ? '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/errors/failures.dart';
'''
        : '';

    final returnStatement = function.hasEither
        ? 'Future<Either<Failure, $returnType>>'
        : 'Future<$returnType>';

    return '''
$imports
import '$repositoryImportPath';

class $useCaseName {
   final $repositoryName ${_toCamelCase(repositoryName)};
   $useCaseName(this.${_toCamelCase(repositoryName)});
  
  $returnStatement call(${_generateSimpleParams(function.parameters)}) {
   return ${_toCamelCase(repositoryName)}.${function.name}(${_generateSimpleCallParams(function)});
  }
}
''';
  }

  String _getRepositoryImportPath() {
    // Remove 'lib/' prefix
    String importPath = repositoryFilePath.replaceFirst('lib/', '');

    // Ensure the path ends with .dart
    if (!importPath.endsWith('.dart')) {
      importPath = '$importPath.dart';
    }

    return 'package:$projectName/$importPath';
  }

  String _generateCallParams(RepositoryFunction function) {
    if (function.parameters.isEmpty) return '';
    return function.parameters.map((p) => 'params.${p.name}').join(', ');
  }

  String _generateSimpleCallParams(RepositoryFunction function) {
    if (function.parameters.isEmpty) return '';
    return function.parameters.map((p) => p.name).join(', ');
  }

  String _generateSimpleParams(List<Parameter> parameters) {
    if (parameters.isEmpty) return '';
    return parameters.map((param) => '${param.type} ${param.name}').join(', ');
  }

  String _generateParamsProperties(List<Parameter> parameters) {
    return parameters
        .map((param) => 'final ${param.type} ${param.name};')
        .join('\n  ');
  }

  String _generateParamsConstructor(List<Parameter> parameters) {
    if (parameters.isEmpty) return '';
    return parameters.map((param) => 'this.${param.name}').join(', ');
  }

  String _generatePropsList(List<Parameter> parameters) {
    return parameters.map((param) => param.name).join(', ');
  }

  String _pascalCase(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  String _toSnakeCase(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => '_${m.group(0)!.toLowerCase()}',
        )
        .toLowerCase();
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }
}
