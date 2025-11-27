#!/usr/bin/env dart

import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
    _printUsage();
    return;
  }

  try {
    final config = _parseArguments(arguments);
    
    print('🚀 Repository Implementation Generator - FIXED');
    print('=' * 50);
    
    // Read repository file
    final repositoryFile = File(config.repositoryFile);
    if (!await repositoryFile.exists()) {
      print('❌ Repository file not found: ${config.repositoryFile}');
      exit(1);
    }

    final repositoryCode = await repositoryFile.readAsString();
    
    final generator = RepositoryImplGenerator(
      repositoryName: config.repositoryName,
      repositoryFile: config.repositoryFile,
      dataSourceName: config.dataSourceName,
    );
    
    print('📁 Repository: ${config.repositoryName}');
    print('📄 Source: ${config.repositoryFile}');
    print('🔌 Data Source: ${config.dataSourceName}');
    print('-' * 50);
    
    await generator.generateRepositoryImpl(repositoryCode);
    
    print('=' * 50);
    print('✅ Repository implementation generated successfully!');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void _printUsage() {
  print('''
🎯 Repository Implementation Generator - FIXED

Usage: dart repo_impl_generator_fixed.dart -r <repository_file> [options]

Required:
  -r, --repository <file>    Path to the repository Dart file

Options:
  -n, --name <name>          Repository class name (auto-detected if not provided)
  -d, --datasource <name>    Data source class name (default: <RepositoryName>RemoteDataSource)
  -h, --help                 Show this help message

Example:
  dart repo_impl_generator_fixed.dart -r auth_repository.dart
''');
}

class CliConfig {
  final String repositoryFile;
  final String repositoryName;
  final String dataSourceName;

  CliConfig({
    required this.repositoryFile,
    required this.repositoryName,
    required this.dataSourceName,
  });
}

CliConfig _parseArguments(List<String> arguments) {
  String? repositoryFile;
  String? repositoryName;
  String? dataSourceName;

  for (int i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    
    switch (arg) {
      case '-r':
      case '--repository':
        if (i + 1 < arguments.length) {
          repositoryFile = arguments[++i];
        }
        break;
      
      case '-n':
      case '--name':
        if (i + 1 < arguments.length) {
          repositoryName = arguments[++i];
        }
        break;
      
      case '-d':
      case '--datasource':
        if (i + 1 < arguments.length) {
          dataSourceName = arguments[++i];
        }
        break;
      
      case '-h':
      case '--help':
        _printUsage();
        exit(0);
    }
  }

  if (repositoryFile == null) {
    print('❌ Error: Repository file is required (-r)');
    _printUsage();
    exit(1);
  }

  repositoryName ??= _extractRepositoryNameFromFile(repositoryFile);
  dataSourceName ??= '${repositoryName.replaceAll('Repository', '')}RemoteDataSource';

  return CliConfig(
    repositoryFile: repositoryFile,
    repositoryName: repositoryName,
    dataSourceName: dataSourceName,
  );
}

String _extractRepositoryNameFromFile(String filePath) {
  final filename = filePath.split(Platform.pathSeparator).last;
  final nameWithoutExtension = filename.replaceAll('.dart', '');
  
  final parts = nameWithoutExtension.split('_');
  final pascalCaseName = parts.map((part) => 
    part[0].toUpperCase() + part.substring(1)
  ).join('');
  
  return pascalCaseName;
}

class RepositoryImplGenerator {
  final String repositoryName;
  final String repositoryFile;
  final String dataSourceName;

  RepositoryImplGenerator({
    required this.repositoryName,
    required this.repositoryFile,
    required this.dataSourceName,
  });

  Future<void> generateRepositoryImpl(String repositoryCode) async {
    final functions = _parseRepositoryFunctions(repositoryCode);
    
    if (functions.isEmpty) {
      print('❌ No repository methods found.');
      return;
    }
    
    final content = _generateRepositoryImpl(functions);
    
    // SIMPLE FIX: Create file in current directory
    final outputFile = '${repositoryFile.replaceAll('.dart', '')}_impl.dart';
    final file = File(outputFile);
    
    print('📝 Writing to: ${file.absolute.path}');
    
    await file.writeAsString(content);
    
    // Verify
    if (await file.exists()) {
      final stats = await file.stat();
      print('✅ SUCCESS: File created (${stats.size} bytes)');
      print('📁 Location: ${file.absolute.path}');
    } else {
      print('❌ FAILED: File was not created');
    }
  }

  List<RepositoryFunction> _parseRepositoryFunctions(String code) {
    final functions = <RepositoryFunction>[];
    final methodPattern = RegExp(r'Future<Either<Failure,[^>]+>>\s+(\w+)\([^)]*\)[^;]*;', multiLine: true);
    final matches = methodPattern.allMatches(code);
    
    for (final match in matches) {
      final methodLine = match.group(0)!;
      print('🔍 Found: ${match.group(1)}');
      final function = _parseFunction(methodLine);
      if (function != null) {
        functions.add(function);
      }
    }

    return functions;
  }

  RepositoryFunction? _parseFunction(String line) {
    try {
      final returnTypeMatch = RegExp(r'Future<Either<Failure,\s*([^>]*(?:<[^>]*>)*[^>]*)>>').firstMatch(line);
      if (returnTypeMatch == null) return null;

      final returnType = returnTypeMatch.group(1)!.trim();
      final functionNameMatch = RegExp(r'(\w+)\([^)]*\)').firstMatch(line);
      if (functionNameMatch == null) return null;

      final functionName = functionNameMatch.group(1)!;
      final paramsMatch = RegExp(r'\(([\s\S]*?)\)').firstMatch(line);
      if (paramsMatch == null) return null;

      final paramsString = paramsMatch.group(1)!.trim();
      final parameters = _parseParameters(paramsString);

      return RepositoryFunction(
        name: functionName,
        returnType: returnType,
        parameters: parameters,
      );
    } catch (e) {
      return null;
    }
  }

  List<Parameter> _parseParameters(String paramsString) {
    final parameters = <Parameter>[];
    if (paramsString.isEmpty) return parameters;

    if (paramsString.contains('{') && paramsString.contains('}')) {
      final braceMatch = RegExp(r'\{(.*)\}').firstMatch(paramsString);
      if (braceMatch != null) {
        final namedParamsContent = braceMatch.group(1)!;
        final paramParts = _splitParameters(namedParamsContent);
        
        for (final param in paramParts) {
          final trimmedParam = param.trim();
          if (trimmedParam.isNotEmpty) {
            if (trimmedParam.contains('required')) {
              final requiredMatch = RegExp(r'required\s+([^ ]+)\s+([^,]+)').firstMatch(trimmedParam);
              if (requiredMatch != null) {
                parameters.add(Parameter(
                  type: requiredMatch.group(1)!,
                  name: 'required ${requiredMatch.group(2)!}',
                ));
              }
            } else {
              final optionalMatch = RegExp(r'([^ ]+)\s+([^,=]+)').firstMatch(trimmedParam);
              if (optionalMatch != null) {
                parameters.add(Parameter(
                  type: optionalMatch.group(1)!,
                  name: optionalMatch.group(2)!,
                ));
              }
            }
          }
        }
      }
    } else {
      final paramParts = _splitParameters(paramsString);
      for (final param in paramParts) {
        final trimmedParam = param.trim();
        if (trimmedParam.isNotEmpty) {
          final paramMatch = RegExp(r'([^ ]+)\s+([^,]+)').firstMatch(trimmedParam);
          if (paramMatch != null) {
            parameters.add(Parameter(
              type: paramMatch.group(1)!,
              name: paramMatch.group(2)!,
            ));
          }
        }
      }
    }
    
    return parameters;
  }

  List<String> _splitParameters(String paramsString) {
    final parts = <String>[];
    var current = '';
    var depth = 0;
    
    for (var i = 0; i < paramsString.length; i++) {
      final char = paramsString[i];
      if (char == '<') depth++;
      if (char == '>') depth--;
      
      if (char == ',' && depth == 0) {
        parts.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    if (current.trim().isNotEmpty) {
      parts.add(current.trim());
    }
    
    return parts;
  }

  String _generateRepositoryImpl(List<RepositoryFunction> functions) {
    final repositoryFileName = repositoryFile.split(Platform.pathSeparator).last;
    final implName = '${repositoryName}Impl';
    final dataSourceVarName = _toCamelCase(dataSourceName.replaceAll('RemoteDataSource', ''));
    
    return '''
import 'package:dartz/dartz.dart';
import 'package:mangaweave/core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/$repositoryFileName';
import '../datasources/${_toSnakeCase(dataSourceName)}.dart';

class $implName implements $repositoryName {
  final $dataSourceName $dataSourceVarName;

  $implName(this.$dataSourceVarName);

${functions.map((function) => _generateMethod(function, dataSourceVarName)).join('\n\n')}
}
''';
  }

  String _generateMethod(RepositoryFunction function, String dataSourceVarName) {
    final paramSignature = _buildParameterSignature(function.parameters);
    final dataSourceParams = _buildDataSourceParameters(function.parameters);
    
    final returnType = function.returnType == 'void' ? 'void' : function.returnType;
    final returnValue = function.returnType == 'void' ? 'const Right(null)' : 'Right(result)';
    final awaitKeyword = function.returnType == 'void' ? 'await' : 'final result = await';
    
    return '''
  @override
  Future<Either<Failure, $returnType>> ${function.name}($paramSignature) async {
    try {
      $awaitKeyword $dataSourceVarName.${function.name}($dataSourceParams);
      return $returnValue;
    } catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }''';
  }

  String _buildParameterSignature(List<Parameter> parameters) {
    if (parameters.isEmpty) return '';
    
    final hasRequiredParams = parameters.any((p) => p.name.startsWith('required'));
    
    if (hasRequiredParams) {
      final requiredParams = parameters.where((p) => p.name.startsWith('required')).map((p) {
        final cleanName = p.name.replaceFirst('required', '').trim();
        return 'required ${p.type} $cleanName';
      }).join(', ');
      
      final optionalParams = parameters.where((p) => !p.name.startsWith('required')).map((p) {
        return '${p.type} ${p.name}';
      }).join(', ');
      
      if (optionalParams.isNotEmpty) {
        return '$requiredParams, {$optionalParams}';
      } else {
        return '$requiredParams';
      }
    } else {
      return parameters.map((p) => '${p.type} ${p.name}').join(', ');
    }
  }

  String _buildDataSourceParameters(List<Parameter> parameters) {
    if (parameters.isEmpty) return '';
    
    final cleanParamNames = parameters.map((p) {
      if (p.name.startsWith('required')) {
        return p.name.replaceFirst('required', '').trim();
      }
      return p.name;
    });
    
    final hasRequiredParams = parameters.any((p) => p.name.startsWith('required'));
    
    if (hasRequiredParams) {
      return cleanParamNames.map((name) => '$name: $name').join(', ');
    } else {
      return cleanParamNames.join(', ');
    }
  }

  String _toSnakeCase(String text) {
    return text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => '_${m.group(0)!.toLowerCase()}',
    ).toLowerCase();
  }

  String _toCamelCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toLowerCase() + text.substring(1);
  }
}

class RepositoryFunction {
  final String name;
  final String returnType;
  final List<Parameter> parameters;

  RepositoryFunction({
    required this.name,
    required this.returnType,
    required this.parameters,
  });
}

class Parameter {
  final String type;
  final String name;

  Parameter({required this.type, required this.name});
}