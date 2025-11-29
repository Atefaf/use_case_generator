import 'dart:io';

class UseCaseGenerator {
  final String repositoryName;
  final String featurePath;
  final String repositoryFilePath;
  final String projectName;

  UseCaseGenerator({
    required this.repositoryName,
    required this.featurePath,
    required this.repositoryFilePath,
  }) : projectName = _getProjectName();

  static String _getProjectName() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        print('⚠️  pubspec.yaml not found, using default project name');
        return 'mangaweave';
      }
      
      final content = pubspecFile.readAsStringSync();
      final nameMatch = RegExp(r'name:\s*(\w+)').firstMatch(content);
      
      if (nameMatch != null) {
        return nameMatch.group(1)!;
      } else {
        print('⚠️  Could not find project name in pubspec.yaml, using default');
        return 'mangaweave';
      }
    } catch (e) {
      print('⚠️  Error reading pubspec.yaml: $e, using default project name');
      return 'mangaweave';
    }
  }

  Future<void> generateUseCases(String repositoryCode) async {
    final functions = _parseRepositoryFunctions(repositoryCode);
    
    for (final function in functions) {
      await _generateUseCaseFile(function);
    }
    
    print('✅ Generated ${functions.length} use case files');
  }

  List<RepositoryFunction> _parseRepositoryFunctions(String code) {
    final lines = code.split('\n');
    final functions = <RepositoryFunction>[];

    for (final line in lines) {
      if (line.trim().startsWith('Future<Either<Failure,')) {
        final function = _parseFunction(line);
        if (function != null) {
          functions.add(function);
        }
      }
    }

    return functions;
  }

  RepositoryFunction? _parseFunction(String line) {
    try {
      // Extract the complete return type including generics
      final returnTypeMatch = RegExp(r'Future<Either<Failure,\s*([^>]*(?:<[^>]*>)?[^>]*)>').firstMatch(line);
      if (returnTypeMatch == null) return null;

      final returnType = returnTypeMatch.group(1)!.trim();

      // Extract function name and parameters
      final functionMatch = RegExp(r'(\w+)\(([^)]*)\)').firstMatch(line);
      if (functionMatch == null) return null;

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
      print('Error parsing function: $line - $e');
      return null;
    }
  }

  Future<void> _generateUseCaseFile(RepositoryFunction function) async {
    final useCaseName = '${_pascalCase(function.name)}UseCase';
    final paramsClassName = '${useCaseName}Params';
    
    final content = _generateUseCase(function, useCaseName, paramsClassName);

    // Use the featurePath directly without adding 'lib/'
    final directory = Directory(featurePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Write file to the exact path provided
    final file = File('${directory.path}/${_toSnakeCase(useCaseName)}.dart');
    await file.writeAsString(content);
    
    print('📁 Generated: ${file.path}');
  }

  String _generateUseCase(
    RepositoryFunction function, 
    String useCaseName, 
    String paramsClassName,
  ) {
    final hasGenerics = function.returnType.contains('<');
    final repositoryImportPath = _getRepositoryImportPath();
    
    return '''
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:$projectName/core/errors/failures.dart';
import 'package:$projectName/core/usecases/usecase.dart';
import '$repositoryImportPath';

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

  String _getRepositoryImportPath() {
    // Convert file path to package import path
    String importPath = repositoryFilePath.replaceFirst('lib/', '').replaceFirst('.dart', '');
    return 'package:$projectName/$importPath';
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

void main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('-h') || arguments.contains('--help')) {
    _printUsage();
    return;
  }

  try {
    final config = _parseArguments(arguments);
    
    print('🚀 Use Case Generator - Standard Pattern');
    print('=' * 50);
    
    // Read repository file
    final repositoryFile = File(config.repositoryFile);
    if (!await repositoryFile.exists()) {
      print('❌ Repository file not found: ${config.repositoryFile}');
      exit(1);
    }

    final repositoryCode = await repositoryFile.readAsString();
    
    // Extract actual repository class name from the file content
    final actualRepositoryName = _extractRepositoryClassName(repositoryCode) ?? config.repositoryName;
    
    final generator = UseCaseGenerator(
      repositoryName: actualRepositoryName,
      featurePath: config.featurePath,
      repositoryFilePath: config.repositoryFile,
    );
    
    print('📁 Repository: $actualRepositoryName');
    print('📂 Feature path: ${config.featurePath}');
    print('📄 Source: ${config.repositoryFile}');
    print('🏷️  Project: ${generator.projectName}');
    print('-' * 50);
    
    await generator.generateUseCases(repositoryCode);
    
    print('=' * 50);
    print('✅ Use case generation completed successfully!');
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

void _printUsage() {
  print('''
🎯 Use Case Generator - Standard Pattern

Usage: dart use_case_generator.dart -r <repository_file> -p <feature_path> [options]

Required:
  -r, --repository <file>    Path to the repository Dart file
  -p, --path <path>          Feature path (e.g., "community/chat")

Options:
  -n, --name <name>          Repository class name (auto-detected if not provided)
  -h, --help                 Show this help message

Example:
  dart use_case_generator.dart -r test_repository.dart -p community/chat
''');
}

class CliConfig {
  final String repositoryFile;
  final String featurePath;
  final String repositoryName;

  CliConfig({
    required this.repositoryFile,
    required this.featurePath,
    required this.repositoryName,
  });
}

CliConfig _parseArguments(List<String> arguments) {
  String? repositoryFile;
  String? featurePath;
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
      
      case '-p':
      case '--path':
        if (i + 1 < arguments.length) {
          featurePath = arguments[++i];
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

  // Validate required arguments
  if (repositoryFile == null) {
    print('❌ Error: Repository file is required (-r)');
    _printUsage();
    exit(1);
  }

  if (featurePath == null) {
    print('❌ Error: Feature path is required (-p)');
    _printUsage();
    exit(1);
  }

  // Auto-detect repository name if not provided
  repositoryName ??= _extractRepositoryNameFromFile(repositoryFile);

  return CliConfig(
    repositoryFile: repositoryFile,
    featurePath: featurePath,
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

String? _extractRepositoryClassName(String code) {
  // Look for class definition in the repository file
  final classMatch = RegExp(r'class\s+(\w+Repository)\s*(?:<[^>]*>)?\s*(?:extends|implements|{)').firstMatch(code);
  return classMatch?.group(1);
}