#!/usr/bin/env dart

import 'dart:io';
import 'package:auto_use_case/src/cli/cli_config.dart';
import 'package:auto_use_case/src/auto_use_case_base.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.contains('-h') ||
      arguments.contains('--help')) {
    _printUsage();
    return;
  }

  try {
    final config = _parseArguments(arguments);

    print('🚀 Use Case Generator');
    print('=' * 50);

    final repositoryFile = File(config.repositoryFile);
    if (!await repositoryFile.exists()) {
      print('❌ Repository file not found: ${config.repositoryFile}');
      exit(1);
    }

    final repositoryCode = await repositoryFile.readAsString();
    final actualRepositoryName =
        _extractRepositoryClassName(repositoryCode) ?? config.repositoryName;

    final generator = UseCaseGenerator(
      repositoryName: actualRepositoryName,
      featurePath: config.featurePath,
      repositoryFilePath: config.repositoryFile,
      isProMode: config.isProMode,
    );

    print('📁 Repository: $actualRepositoryName');
    print('📂 Feature path: ${config.featurePath}');
    print('📄 Source: ${config.repositoryFile}');
    print('🏷️  Project: ${generator.projectName}');
    print('🎯 Mode: ${config.isProMode ? 'PRO' : 'SIMPLE'}');
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
🎯 Use Case Generator

Usage: dart auto_use_case.dart -r <repository_file> -p <feature_path> [options]

Required:
  -r, --repository <file>    Path to the repository Dart file
  -p, --path <path>          Feature path (e.g., "community/chat")

Options:
  -n, --name <name>          Repository class name (auto-detected if not provided)
  --pro                      Use PRO mode (extends UseCase with params class)
  --simple                   Use SIMPLE mode (basic implementation) [default]
  -h, --help                 Show this help message

Examples:
  # Simple mode (default)
  dart auto_use_case.dart -r test_repository.dart -p lib/usecases

  # Pro mode
  dart auto_use_case.dart -r test_repository.dart -p lib/usecases --pro
''');
}

CliConfig _parseArguments(List<String> arguments) {
  String? repositoryFile;
  String? featurePath;
  String? repositoryName;
  bool isProMode = false;

  for (int i = 0; i < arguments.length; i++) {
    final arg = arguments[i];

    switch (arg) {
      case '-r':
      case '--repository':
        if (i + 1 < arguments.length) repositoryFile = arguments[++i];
        break;
      case '-p':
      case '--path':
        if (i + 1 < arguments.length) featurePath = arguments[++i];
        break;
      case '-n':
      case '--name':
        if (i + 1 < arguments.length) repositoryName = arguments[++i];
        break;
      case '--pro':
        isProMode = true;
        break;
      case '--simple':
        isProMode = false;
        break;
      case '-h':
      case '--help':
        _printUsage();
        exit(0);
    }
  }

  if (repositoryFile == null || featurePath == null) {
    print('❌ Error: Repository file and feature path are required');
    _printUsage();
    exit(1);
  }

  repositoryName ??= _extractRepositoryNameFromFile(repositoryFile);

  return CliConfig(
    repositoryFile: repositoryFile,
    featurePath: featurePath,
    repositoryName: repositoryName,
    isProMode: isProMode,
  );
}

String _extractRepositoryNameFromFile(String filePath) {
  final filename = filePath.split(Platform.pathSeparator).last;
  final nameWithoutExtension = filename.replaceAll('.dart', '');
  final parts = nameWithoutExtension.split('_');
  return parts
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join('');
}

String? _extractRepositoryClassName(String code) {
  final classMatch = RegExp(
          r'class\s+(\w+Repository)\s*(?:<[^>]*>)?\s*(?:extends|implements|{)')
      .firstMatch(code);
  return classMatch?.group(1);
}
