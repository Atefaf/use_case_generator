# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0] - 2025-01-01

### 🚀 Added
- Initial release of Use Case Generator
- Support for both Simple and Professional modes
- Automatic project name detection from `pubspec.yaml`
- Smart parsing of repository functions with both `Future<T>` and `Future<Either<Failure, T>>` patterns
- Flexible output path configuration
- Comprehensive CLI interface with help system

### ✨ Features
- **Simple Mode**: Generate basic use cases with direct parameters
- **Professional Mode**: Generate use cases with params classes extending `Equatable`
- **Smart Detection**: Auto-detect repository class names from file content
- **Import Handling**: Proper import path generation with `.dart` extension
- **Error Handling**: Comprehensive error messages and validation