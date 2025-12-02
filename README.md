Here's the **perfect professional README** that clearly shows it's a CLI tool and uses generic examples:

```markdown
# Auto Use Case Generator 🚀

[![Pub Version](https://img.shields.io/pub/v/auto_use_case)](https://pub.dev/packages/auto_use_case)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart CI](https://img.shields.io/github/actions/workflow/status/yourusername/auto_use_case/dart.yml)](https://github.com/yourusername/auto_use_case/actions)
[![Style: Effective Dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://dart.dev/effective-dart)

**A CLI tool that automatically generates Clean Architecture use cases from your repository interfaces. Save hours of manual coding!**

---

## ⚡ What is This?

### **A Command Line Interface (CLI) Tool** 🔧

This is **not** a library you import in your code. It's a **command-line tool** that runs in your terminal:

```bash
# Install the CLI tool globally
dart pub global activate auto_use_case

# Use it from any terminal
auto_use_case -r lib/repository.dart -p lib/usecases
```

### **Before vs After**

#### 🔴 BEFORE: Manual Work (10+ minutes)
```dart
// You manually create each use case...
class GetUserUseCase {
  final UserRepository repository;
  GetUserUseCase(this.repository);
  
  Future<User> call(int id) {
    return repository.getUser(id);
  }
}
// Repeat for each repository method... 😫
```

#### 🟢 AFTER: One Command (2 seconds!)
```bash
auto_use_case -r lib/repository.dart -p lib/usecases
```
✅ **Generates all use cases automatically**  
✅ **Zero copy-paste errors**  
✅ **Follows your project structure**  
✅ **Works with Either/Failure pattern**

---

## 🚀 Quick Start

### Step 1: Install the CLI Tool
```bash
# Install globally (like npm install -g)
dart pub global activate auto_use_case
```

### Step 2: Verify Installation
```bash
# Check it works
auto_use_case --version
# Shows: auto_use_case 1.4.0

# See all commands
auto_use_case --help
```

### Step 3: Generate Your First Use Cases
```bash
# Example: Generate use cases for auth repository
auto_use_case \
  -r lib/features/auth/repositories/auth_repository.dart \
  -p lib/features/auth/domain/usecases

# Check the generated files
ls lib/features/auth/domain/usecases/
# get_user_use_case.dart
# update_user_use_case.dart
# delete_user_use_case.dart
# ...and more!
```

---

## 📚 How It Works

### Your Repository File:
```dart
// user_repository.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';

class UserRepository {
  Future<Either<Failure, User>> getUser(int id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, void>> deleteUser(String userId);
}
```

### Generated Use Cases:
```dart
// get_user_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repositories/user_repository.dart';

class GetUserUseCase extends UseCase<User, GetUserUseCaseParams> {
  final UserRepository repository;
  GetUserUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(GetUserUseCaseParams params) {
    return repository.getUser(params.id);
  }
}

class GetUserUseCaseParams extends Equatable {
  final int id;
  const GetUserUseCaseParams(this.id);
  
  @override
  List<Object?> get props => [id];
}
```

### What's Included:
✅ **Imports preserved** - `dartz`, `equatable`, your `failures.dart` and `usecase.dart`  
✅ **Project structure maintained** - Uses your package name from `pubspec.yaml`  
✅ **Params classes** (in Pro mode) for clean parameter handling  
✅ **Error handling** - Works with `Either<Failure, T>` pattern  

---

## 🛠️ Installation Methods

### 🟢 **Method 1: Global CLI (Recommended)**
```bash
# Install as global command-line tool
dart pub global activate auto_use_case

# Now use 'auto_use_case' anywhere:
auto_use_case -r lib/repo.dart -p lib/usecases
```

**Perfect for:** Daily development, quick generation

### 🟡 **Method 2: Project Dependency**
```yaml
# Add to your pubspec.yaml
dev_dependencies:
  auto_use_case: ^1.4.0
```

```bash
# Use within project
dart run auto_use_case -r lib/repo.dart -p lib/usecases
```

**Perfect for:** CI/CD pipelines, team projects with version locking

---

## 📖 Complete Examples

### Example 1: Basic Repository
```dart
// product_repository.dart
class ProductRepository {
  Future<Product> getProduct(String id);
  Future<List<Product>> getAllProducts();
  Future<void> updateProduct(Product product);
}
```

**Command:**
```bash
auto_use_case -r lib/repositories/product_repository.dart -p lib/domain/usecases
```

### Example 2: Advanced Either Pattern
```dart
// order_repository.dart
import 'package:dartz/dartz.dart';
import 'package:myapp/core/errors/failures.dart';

class OrderRepository {
  Future<Either<Failure, Order>> getOrder(String orderId);
  Future<Either<Failure, List<Order>>> getOrdersByUser(String userId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
```

**Command (Pro Mode):**
```bash
auto_use_case -r lib/repositories/order_repository.dart -p lib/domain/usecases --pro
```

**Generates use cases with:**
- `UseCase` base class extension
- `Params` classes for clean parameters
- Proper `Either<Failure, T>` return types
- Your project's import paths

### Example 3: Mixed Patterns
```dart
// analytics_repository.dart
class AnalyticsRepository {
  // Either pattern
  Future<Either<Failure, AnalyticsData>> getAnalytics(DateTime date);
  
  // Simple pattern
  Future<int> getTotalUsers();
  
  // Void with Either
  Future<Either<Failure, void>> clearAnalyticsCache();
}
```

**Auto-detects and handles both patterns!**

---

## ⚙️ CLI Command Reference

### Basic Syntax
```bash
auto_use_case -r REPOSITORY_FILE -p OUTPUT_DIRECTORY [OPTIONS]
```

### Required Options
| Option | Description | Example |
|--------|-------------|---------|
| `-r, --repository` | Path to your repository file | `-r lib/repo.dart` |
| `-p, --path` | Where to save generated use cases | `-p lib/domain/usecases` |

### Optional Flags
| Flag | Description | Example |
|------|-------------|---------|
| `--pro` | Professional mode (with params classes) | `--pro` |
| `--simple` | Simple mode (direct parameters) | `--simple` |
| `-n, --name` | Custom repository class name | `-n ApiClient` |
| `--version` | Show CLI version | `--version` |
| `-h, --help` | Show help message | `-h` |

### Quick Commands Cheat Sheet
```bash
# Basic generation
auto_use_case -r lib/repo.dart -p lib/usecases

# Pro mode for Either/Failure
auto_use_case -r lib/repo.dart -p lib/usecases --pro

# Custom class name
auto_use_case -r lib/api.dart -p lib/usecases -n ApiClient

# Check CLI version
auto_use_case --version
```

---

## 🎯 Advanced Usage

### Complex Parameter Support
Handles all Dart parameter types:

```dart
// Repository method
Future<Report> generateReport({
  required DateTime startDate,
  required DateTime endDate,
  ReportType type = ReportType.detailed,
  bool includeCharts = true,
  List<String>? filters,
});

// Generated use case handles all parameters correctly
```

### Multiple Project Structures
```bash
# Feature-based structure
auto_use_case -r lib/features/auth/repositories/auth_repo.dart -p lib/features/auth/domain/usecases

# Layer-based structure
auto_use_case -r lib/data/repositories/user_repo.dart -p lib/domain/usecases

# Simple structure
auto_use_case -r lib/repository.dart -p lib/usecases

# Custom structure
auto_use_case -r packages/domain/lib/repositories/product_repo.dart -p packages/domain/lib/usecases
```

### CI/CD Integration
```yaml
# .github/workflows/generate_usecases.yml
name: Generate Use Cases

on: [push, pull_request]

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      
      - name: Install CLI tool
        run: dart pub global activate auto_use_case
      
      - name: Generate use cases
        run: |
          auto_use_case -r lib/repositories/user_repository.dart -p lib/domain/usecases --pro
          auto_use_case -r lib/repositories/product_repository.dart -p lib/domain/usecases --pro
      
      - name: Commit generated files
        run: |
          git config --global user.name "GitHub Actions"
          git config --global user.email "actions@github.com"
          git add lib/domain/usecases/
          git commit -m "chore: regenerate use cases" || echo "No changes to commit"
          git push
```

---

## ❓ Frequently Asked Questions

### ❔ "Is this a library or a CLI tool?"
**It's a CLI tool!** You install it globally and run commands in your terminal, just like `git`, `npm`, or `docker`.

### ❔ "Why use global install vs project dependency?"
| Use Case | Recommended Method |
|----------|-------------------|
| **Daily development** | 🟢 Global CLI (`dart pub global activate`) |
| **CI/CD pipelines** | 🟡 Project dependency (`dart pub add --dev`) |
| **Team projects** | 🟢 Global (each dev installs) |
| **Version locking** | 🟡 Project (specify version in pubspec) |

### ❔ "Command not found after global install"
Add Dart to your PATH:
```bash
# macOS/Linux
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# Windows: Add to PATH
# %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

### ❔ "How does it handle imports like dartz and equatable?"
The CLI reads your repository file and **preserves all imports**. If your repo imports `dartz`, `equatable`, `failures.dart`, and `usecase.dart`, the generated use cases will include them too.

### ❔ "Can I use it with my existing use cases?"
Yes! The CLI **only creates new files**. It never modifies existing files. Delete old ones and regenerate if needed.

---

## 🏗️ Supported Patterns

### Return Types
✅ `Future<T>` - Simple return  
✅ `Future<Either<Failure, T>>` - Either pattern  
✅ `Future<void>` - Void return  
✅ `Future<Either<Failure, void>>` - Void with Either

### Parameter Types
✅ Required: `String id`  
✅ Optional: `String? optional`  
✅ Named: `{required String name}`  
✅ Default values: `int count = 1`  
✅ Lists/Maps: `List<User>`, `Map<String, dynamic>`

### Import Patterns
✅ `import 'package:dartz/dartz.dart';`  
✅ `import 'package:equatable/equatable.dart';`  
✅ Your custom: `import 'package:myapp/core/errors/failures.dart';`  
✅ Your base: `import 'package:myapp/core/usecases/usecase.dart';`

---

## 📊 Real-World Example

### Your Project Structure:
```
my_flutter_app/
├── pubspec.yaml            # Package: "myapp"
├── lib/
│   ├── core/
│   │   ├── errors/
│   │   │   └── failures.dart
│   │   └── usecases/
│   │       └── usecase.dart
│   └── features/
│       └── auth/
│           ├── repositories/
│           │   └── auth_repository.dart
│           └── domain/
│               └── usecases/   # ← Generated here
```

### Repository File:
```dart
// lib/features/auth/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/errors/failures.dart';

class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
```

### CLI Command:
```bash
auto_use_case \
  -r lib/features/auth/repositories/auth_repository.dart \
  -p lib/features/auth/domain/usecases \
  --pro
```

### Generated File:
```dart
// lib/features/auth/domain/usecases/login_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/errors/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase extends UseCase<User, LoginUseCaseParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  
  @override
  Future<Either<Failure, User>> call(LoginUseCaseParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginUseCaseParams extends Equatable {
  final String email;
  final String password;
  
  const LoginUseCaseParams({
    required this.email,
    required this.password,
  });
  
  @override
  List<Object?> get props => [email, password];
}
```

**Perfect import paths! Perfect project structure! Zero manual work!**

---

## 🔧 Troubleshooting

### "No public methods found"
Make sure your repository class is public:
```dart
// ✅ Public class
class UserRepository { ... }

// ❌ Private class (won't work)
class _UserRepository { ... }
```

### "File not found"
Use absolute paths from project root:
```bash
# ❌ Wrong
auto_use_case -r repository.dart -p usecases

# ✅ Right
auto_use_case -r lib/repository.dart -p lib/usecases
```

### "Wrong imports in generated files"
The CLI auto-detects imports from your repository file. If wrong, you can:
1. Manually fix imports once
2. Ensure your repository has correct imports
3. The generated files will mirror your repository's imports

### Update the CLI
```bash
# Global install
dart pub global activate auto_use_case

# Project dependency
dart pub upgrade auto_use_case
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🎯 Ready to Save Hours?

```bash
# 🟢 INSTALL AS CLI TOOL (Recommended)
dart pub global activate auto_use_case

# 🚀 GENERATE USE CASES
auto_use_case \
  -r lib/features/auth/repositories/auth_repository.dart \
  -p lib/features/auth/domain/usecases \
  --pro

# Watch use cases appear instantly! ✨
```

**A CLI tool for Flutter developers who value their time**

---

## 🤝 Need Help?

- **Issues**: [GitHub Issues](https://github.com/Atefaf/auto_use_case/issues)
- **Questions**: Check FAQ section above
- **Feature Requests**: Open a GitHub discussion

**⭐ Star the repo if this saves you time!**
```

## Key Improvements: 🔥

1. **Clearly states it's a CLI tool** - Multiple mentions
2. **Shows terminal usage** - Emphasizes command-line nature
3. **Generic examples** - Uses `myapp` instead of specific names
4. **Import preservation** - Shows how `dartz`, `equatable`, `failures.dart`, `usecase.dart` are preserved
5. **Real-world structure** - Shows complete project example
6. **Comparison table** - Global CLI vs project dependency

This makes it **crystal clear** that it's a CLI tool, not a library! 🚀