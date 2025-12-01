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
  final functions = <RepositoryFunction>[];
  
  // Remove all comments first
  final withoutComments = _removeComments(code);
  final lines = withoutComments.split('\n');

  for (final line in lines) {
    final trimmedLine = line.trim();
    
    // Skip empty lines
    if (trimmedLine.isEmpty) {
      continue;
    }
    
    // Match Future<Either<Failure, T>> pattern
    if (trimmedLine.startsWith('Future<Either<Failure,')) {
      final function = _parseEitherFunction(trimmedLine);
      if (function != null) {
        functions.add(function);
        print('🔍 Found: ${function.name}');
      }
    }
    // Match Future<T> pattern (simple futures)
    else if (trimmedLine.startsWith('Future<') && trimmedLine.contains('(')) {
      final function = _parseSimpleFutureFunction(trimmedLine);
      if (function != null) {
        functions.add(function);
        print('🔍 Found: ${function.name}');
      }
    }
    // Match Stream<T> pattern
    else if (trimmedLine.startsWith('Stream<') && trimmedLine.contains('(')) {
      final function = _parseStreamFunction(trimmedLine);
      if (function != null) {
        functions.add(function);
        print('🔍 Found: ${function.name} (Stream)');
      }
    }
  }

  return functions;
}

String _removeComments(String code) {
  // Remove single-line comments (// and ///)
  var result = code.replaceAll(RegExp(r'//[^\n]*'), '');
  result = result.replaceAll(RegExp(r'///[^\n]*'), '');
  
  // Remove multi-line comments (/* ... */)
  result = result.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  
  return result;
}

RepositoryFunction? _parseStreamFunction(String line) {
  try {
    // Extract return type from Stream<T>
    final returnTypeMatch = RegExp(r'Stream<([^>]*)>').firstMatch(line);
    if (returnTypeMatch == null) return null;

    final returnType = returnTypeMatch.group(1)!.trim();

    // Extract function name and parameters
    final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);
    if (functionMatch == null) return null;

    final functionName = functionMatch.group(1)!;
    final paramsString = functionMatch.group(2)?.trim() ?? '';
    
    final parameters = _parseParameters(paramsString);

    return RepositoryFunction(
      name: functionName,
      returnType: returnType,
      parameters: parameters,
      hasEither: false,
      isVoid: false,
      isStream: true, // Mark as stream function
    );
  } catch (e) {
    print('Error parsing stream function: $line - $e');
    return null;
  }
}
RepositoryFunction? _parseEitherFunction(String line) {
  try {
    // Extract the complete return type including generics
    final returnTypeMatch = RegExp(r'Future<Either<Failure,\s*([^>]*(?:<[^>]*>)?[^>]*)>').firstMatch(line);
    if (returnTypeMatch == null) return null;

    final returnType = returnTypeMatch.group(1)!.trim();
    final isVoid = returnType == 'void';

    // Extract function name and parameters
    final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);
    if (functionMatch == null) return null;

    final functionName = functionMatch.group(1)!;
    final paramsString = functionMatch.group(2)?.trim() ?? '';
    
    final parameters = _parseParameters(paramsString);

    return RepositoryFunction(
      name: functionName,
      returnType: returnType,
      parameters: parameters,
      hasEither: true,
      isVoid: isVoid,
      isStream: false,
    );
  } catch (e) {
    print('Error parsing either function: $line - $e');
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

  // Handle imports based on function type
  String imports;
  if (function.isStream) {
    imports = '''
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/usecases/usecase.dart';
''';
  } else if (function.hasEither) {
    imports = '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:$projectName/core/usecases/usecase.dart';
''';
  } else {
    imports = '''
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/usecases/usecase.dart';
''';
  }

  // Handle return types based on function type
  final returnType = function.isVoid ? 'void' : function.returnType;
  String returnStatement;
  if (function.isStream) {
    returnStatement = 'Stream<$returnType${hasGenerics ? '>' : ''}>';
  } else if (function.hasEither) {
    returnStatement = 'Future<Either<Failure, $returnType${hasGenerics ? '>' : ''}>>';
  } else {
    returnStatement = 'Future<$returnType${hasGenerics ? '>' : ''}>';
  }

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

 String _generateSimpleUseCase(RepositoryFunction function, String useCaseName) {
  final repositoryImportPath = _getRepositoryImportPath();
  
  // Handle return types based on function type
  final returnType = function.isVoid ? 'void' : function.returnType;
  String returnStatement;
  String imports = '';
  
  if (function.isStream) {
    returnStatement = 'Stream<$returnType>';
  } else if (function.hasEither) {
    returnStatement = 'Future<Either<Failure, $returnType>>';
    imports = '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/core/errors/failures.dart';
''';
  } else {
    returnStatement = 'Future<$returnType>';
  }

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
