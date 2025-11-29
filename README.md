# Use Case Generator 🚀

A powerful Dart CLI tool that automatically generates Clean Architecture use cases from repository interfaces. Supports both simple and professional implementation patterns.

## Features

- ✅ **Automatic Generation** - Creates use cases from repository methods
- ✅ **Two Modes** - Simple mode (basic) and Pro mode (with params classes)
- ✅ **Smart Parsing** - Handles both `Future<T>` and `Future<Either<Failure, T>>` patterns
- ✅ **Custom Paths** - Generate use cases anywhere in your project
- ✅ **Project Detection** - Automatically reads project name from `pubspec.yaml`

## Installation

### Global Installation (Recommended)
```bash
dart pub global activate use_case_generator