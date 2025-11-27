#!/usr/bin/env dart

import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
    _printUsage();
    return;
  }

  try {
    final config = _parseArguments(arguments);
    
    print('🚀 Use Case Generator');
    print('=' * 50);
    
    // Read repository file
    final repositoryFile = File(config.repositoryFile);
    if (!await repositoryFile.exists()) {
      print('❌ Repository file not found: ${config.repositoryFile}');
      exit(1);
    }

    final repositoryCode = await repositoryFile.readAsString();
    
    final generator = UseCaseGenerator(
      repositoryName: config.repositoryName,
      repositoryFile: config.repositoryFile,
    );
    
    print('📁 Repository: ${config.repositoryName}');
    print('📄 Source: ${config.repositoryFile}');
    print('-' * 50);
    
    await generator.generateUseCases(repositoryCode);
    
    print('=' * 50);
    print('✅ Use case generation completed!');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void _printUsage() {
  print('''
🎯 Use Case Generator

Usage: dart use_case_generator.dart -r <repository_file> [options]

Required:
  -r, --repository <file>    Path to the repository Dart file

Options:
  -n, --name <name>          Repository class name (auto-detected if not provided)
  -h, --help                 Show this help message

Example:
  dart use_case_generator.dart -r lib/features/chat/repositories/chat_repository.dart

  dart use_case_generator.dart -r test_repository.dart -n UserRepository
''');
}

class CliConfig {
  final String repositoryFile;
  final String repositoryName;

  CliConfig({
    required this.repositoryFile,
    required this.repositoryName,
  });
}

CliConfig _parseArguments(List<String> arguments) {
  String? repositoryFile;
  String? repositoryName;

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

  return CliConfig(
    repositoryFile: repositoryFile,
    repositoryName: repositoryName,
  );
}

String _extractRepositoryNameFromFile(String filePath) {
  final filename = filePath.split(Platform.pathSeparator).last;
  final nameWithoutExtension = filename.replaceAll('.dart', '');
  
  // Convert to PascalCase (e.g., test_repository -> TestRepository)
  final parts = nameWithoutExtension.split('_');
  final pascalCaseName = parts.map((part) => 
    part[0].toUpperCase() + part.substring(1)
  ).join('');
  
  return pascalCaseName;
}

class UseCaseGenerator {
  final String repositoryName;
  final String repositoryFile;

  UseCaseGenerator({
    required this.repositoryName,
    required this.repositoryFile,
  });

  Future<void> generateUseCases(String repositoryCode) async {
    final functions = _parseRepositoryFunctions(repositoryCode);
    
    if (functions.isEmpty) {
      print('❌ No repository methods found.');
      print('   Make sure your methods follow: Future<Either<Failure, ReturnType>> methodName(Parameters);');
      return;
    }
    
    for (final function in functions) {
      await _generateUseCaseFile(function);
    }
    
    print('✅ Generated ${functions.length} use case files');
  }

  List<RepositoryFunction> _parseRepositoryFunctions(String code) {
    final lines = code.split('\n');
    final functions = <RepositoryFunction>[];

    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Look for repository method patterns
      if (trimmedLine.startsWith('Future<Either<Failure,') ||
          trimmedLine.contains('Future<Either<Failure,')) {
        
        print('🔍 Found method: $trimmedLine');
        final function = _parseFunction(trimmedLine);
        if (function != null) {
          print('   ✅ Parsed: ${function.name} -> ${function.returnType}');
          functions.add(function);
        } else {
          print('   ❌ Failed to parse');
        }
      }
    }

    return functions;
  }

  RepositoryFunction? _parseFunction(String line) {
    try {
      // Improved regex to handle nested generics
      final returnTypeMatch = RegExp(r'Future<Either<Failure,\s*([^>]*(?:<[^>]*>)*[^>]*)>>').firstMatch(line);
      if (returnTypeMatch == null) {
        print('   ❌ Could not extract return type');
        return null;
      }

      final returnType = returnTypeMatch.group(1)!.trim();

      // Extract function name and parameters
      final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);
      if (functionMatch == null) {
        print('   ❌ Could not extract function name');
        return null;
      }

      final functionName = functionMatch.group(1)!;
      final paramsString = functionMatch.group(2)?.trim() ?? '';
      
      // Parse parameters
      final parameters = <Parameter>[];
      if (paramsString.isNotEmpty) {
        final paramParts = paramsString.split(',');
        for (final param in paramParts) {
          final trimmedParam = param.trim();
          if (trimmedParam.isNotEmpty) {
            final paramMatch = RegExp(r'(\w+(?:<[^>]*>)?)\s+(\w+)').firstMatch(trimmedParam);
            if (paramMatch != null) {
              parameters.add(Parameter(
                type: paramMatch.group(1)!,
                name: paramMatch.group(2)!,
              ));
            }
          }
        }
      }

      return RepositoryFunction(
        name: functionName,
        returnType: returnType,
        parameters: parameters,
      );
    } catch (e) {
      print('   ❌ Error parsing function: $e');
      return null;
    }
  }

  Future<void> _generateUseCaseFile(RepositoryFunction function) async {
    final useCaseName = '${_pascalCase(function.name)}UseCase';
    final paramsClassName = '${useCaseName}Params';
    
    final content = _generateUseCase(function, useCaseName, paramsClassName);

    // Create usecases directory next to repository file
    final repositoryDir = File(repositoryFile).parent;
    final useCasesDir = Directory('${repositoryDir.path}/usecases');
    
    if (!await useCasesDir.exists()) {
      await useCasesDir.create(recursive: true);
      print('   📁 Created directory: ${useCasesDir.path}');
    }

    // Write file
    final fileName = _toSnakeCase(useCaseName);
    final file = File('${useCasesDir.path}/$fileName.dart');
    await file.writeAsString(content);
    
    print('   📄 Generated: ${file.path}');
  }

  String _generateUseCase(
    RepositoryFunction function, 
    String useCaseName, 
    String paramsClassName,
  ) {
    final hasGenerics = function.returnType.contains('<');
    final repositoryFileName = repositoryFile.split(Platform.pathSeparator).last;
    
    return '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaweave/core/errors/failures.dart';
import 'package:mangaweave/core/usecases/usecase.dart';
import '../$repositoryFileName';

class $useCaseName extends UseCase<${function.returnType}${hasGenerics ? '>' : ''}, $paramsClassName>{
   final $repositoryName ${_toCamelCase(repositoryName)};
   $useCaseName(this.${_toCamelCase(repositoryName)});
  
  @override
  Future<Either<Failure, ${function.returnType}${hasGenerics ? '>' : ''}>> call($paramsClassName params) {
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

  String _generateCallParams(RepositoryFunction function) {
    if (function.parameters.isEmpty) return '';
    return function.parameters.map((p) => 'params.${p.name}').join(', ');
  }

  String _generateParamsProperties(List<Parameter> parameters) {
    return parameters.map((param) => 'final ${param.type} ${param.name};').join('\n  ');
  }

  String _generateParamsConstructor(List<Parameter> parameters) {
    if (parameters.isEmpty) return '';
    return parameters.map((param) => 'this.${param.name}').join(', ');
  }

  String _generatePropsList(List<Parameter> parameters) {
    return parameters.map((param) => param.name).join(', ');
  }

  String _pascalCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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