Here's the **complete README.md** with all examples and usage in one beautiful file:

```markdown
# Use Case Generator 🚀

<div align="center">

[![Pub Version](https://img.shields.io/pub/v/auto_use_case)](https://pub.dev/packages/auto_use_case)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Automatically generate Clean Architecture use cases from your repository interfaces in seconds!**

</div>

## ✨ Features

- ✅ **Automatic Generation** - Create use cases from repository methods instantly
- ✅ **Two Modes** - Simple mode (basic) and Pro mode (with params classes)
- ✅ **Smart Parsing** - Handles both `Future<T>` and `Future<Either<Failure, T>>` patterns
- ✅ **Custom Paths** - Generate use cases anywhere in your project
- ✅ **Project Detection** - Automatically reads project name from `pubspec.yaml`

## 🚀 Installation

### Global Installation (Recommended)
```bash
dart pub global activate auto_use_case
```

### Project Dependency
```bash
dart pub add auto_use_case --dev
```

## 📖 Quick Start

### Basic Command
```bash
auto_use_case -r <repository_file> -p <output_path> [options]
```

### Simple Example
```bash
auto_use_case -r lib/features/auth/repositories/user_repository.dart -p lib/features/auth/domain/usecases
```

## 🎯 Complete Usage Examples

### 1. Professional Mode (With Params Classes)
```bash
auto_use_case -r lib/features/auth/repositories/user_repository.dart -p lib/features/auth/domain/usecases --pro
```

**Input Repository:**
```dart
class UserRepository {
  Future<Either<Failure, User>> getUser(int id);
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, User>> updateUser(User user);
}
```

**Generated Use Cases (Pro Mode):**
```dart
// getUser_use_case.dart
class GetUserUseCase extends UseCase<User, GetUserUseCaseParams> {
  final UserRepository userRepository;
  GetUserUseCase(this.userRepository);
  
  @override
  Future<Either<Failure, User>> call(GetUserUseCaseParams params) {
    return userRepository.getUser(params.id);
  }
}

class GetUserUseCaseParams extends Equatable {
  final int id;
  const GetUserUseCaseParams(this.id);
  
  @override
  List<Object?> get props => [id];
}

// delete_user_use_case.dart  
class DeleteUserUseCase extends UseCase<void, DeleteUserUseCaseParams> {
  final UserRepository userRepository;
  DeleteUserUseCase(this.userRepository);
  
  @override
  Future<Either<Failure, void>> call(DeleteUserUseCaseParams params) {
    return userRepository.deleteUser(params.userId);
  }
}

class DeleteUserUseCaseParams extends Equatable {
  final String userId;
  const DeleteUserUseCaseParams(this.userId);
  
  @override
  List<Object?> get props => [userId];
}
```

### 2. Simple Mode (Direct Parameters)
```bash
auto_use_case -r lib/features/chat/repositories/chat_repository.dart -p lib/features/chat/domain/usecases --simple
```

**Input Repository:**
```dart
class ChatRepository {
  Future<Either<Failure, List<Message>>> getMessages(String chatId);
  Future<Either<Failure, void>> sendMessage(String chatId, String content);
  Future<String> getChatName(String chatId);
}
```

**Generated Use Cases (Simple Mode):**
```dart
// get_messages_use_case.dart
class GetMessagesUseCase {
  final ChatRepository chatRepository;
  GetMessagesUseCase(this.chatRepository);
  
  Future<Either<Failure, List<Message>>> call(String chatId) {
    return chatRepository.getMessages(chatId);
  }
}

// send_message_use_case.dart
class SendMessageUseCase {
  final ChatRepository chatRepository;
  SendMessageUseCase(this.chatRepository);
  
  Future<Either<Failure, void>> call(String chatId, String content) {
    return chatRepository.sendMessage(chatId, content);
  }
}

// get_chat_name_use_case.dart
class GetChatNameUseCase {
  final ChatRepository chatRepository;
  GetChatNameUseCase(this.chatRepository);
  
  Future<String> call(String chatId) {
    return chatRepository.getChatName(chatId);
  }
}
```

### 3. Mixed Repository Patterns
```bash
auto_use_case -r lib/features/profile/repositories/profile_repository.dart -p lib/features/profile/domain/usecases --pro
```

**Input Repository (Mixed Patterns):**
```dart
class ProfileRepository {
  // Either/Failure pattern
  Future<Either<Failure, Profile>> getProfile(int userId);
  Future<Either<Failure, void>> updateProfile(Profile profile);
  
  // Simple Future pattern  
  Future<String> getProfileBio(int userId);
  Future<int> getProfileViews(int userId);
}
```

**Generated Use Cases:**
```dart
// Either/Failure methods use Either return type
class GetProfileUseCase extends UseCase<Profile, GetProfileUseCaseParams> {
  final ProfileRepository profileRepository;
  GetProfileUseCase(this.profileRepository);
  
  @override
  Future<Either<Failure, Profile>> call(GetProfileUseCaseParams params) {
    return profileRepository.getProfile(params.userId);
  }
}

// Simple Future methods use direct Future return type  
class GetProfileBioUseCase extends UseCase<String, GetProfileBioUseCaseParams> {
  final ProfileRepository profileRepository;
  GetProfileBioUseCase(this.profileRepository);
  
  @override
  Future<String> call(GetProfileBioUseCaseParams params) {
    return profileRepository.getProfileBio(params.userId);
  }
}
```

## 🛠️ Advanced Usage

### Custom Repository Name
```bash
auto_use_case -r lib/data/repositories.dart -p lib/domain/usecases -n MyCustomRepository --pro
```

### Different Project Structures
```bash
# Feature-based structure
auto_use_case -r lib/features/auth/data/repositories/auth_repository.dart -p lib/features/auth/domain/usecases --pro

# Layer-based structure  
auto_use_case -r lib/data/repositories/user_repository.dart -p lib/domain/usecases --simple

# Root level structure
auto_use_case -r lib/repository.dart -p lib/usecases --pro
```

### With Required/Optional Parameters
**Input Repository:**
```dart
class OrderRepository {
  Future<Either<Failure, Order>> createOrder({
    required String productId,
    required int quantity,
    String? couponCode,
    bool rushDelivery = false,
  });
}
```

**Generated Use Case (Pro Mode):**
```dart
class CreateOrderUseCase extends UseCase<Order, CreateOrderUseCaseParams> {
  final OrderRepository orderRepository;
  CreateOrderUseCase(this.orderRepository);
  
  @override
  Future<Either<Failure, Order>> call(CreateOrderUseCaseParams params) {
    return orderRepository.createOrder(
      productId: params.productId,
      quantity: params.quantity,
      couponCode: params.couponCode,
      rushDelivery: params.rushDelivery,
    );
  }
}

class CreateOrderUseCaseParams extends Equatable {
  final String productId;
  final int quantity;
  final String? couponCode;
  final bool rushDelivery;
  
  const CreateOrderUseCaseParams({
    required this.productId,
    required this.quantity,
    this.couponCode,
    this.rushDelivery = false,
  });
  
  @override
  List<Object?> get props => [productId, quantity, couponCode, rushDelivery];
}
```

## ⚙️ Complete Command Reference

### Required Parameters
| Parameter | Description | Example |
|-----------|-------------|---------|
| `-r, --repository` | Path to repository Dart file | `-r lib/features/auth/repository.dart` |
| `-p, --path` | Output path for generated use cases | `-p lib/features/auth/domain/usecases` |

### Optional Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `--pro` | Use professional mode (with params classes) | |
| `--simple` | Use simple mode (direct parameters) | ✅ Default |
| `-n, --name` | Custom repository class name | Auto-detected |
| `-h, --help` | Show help message | |

### All Examples in One Place
```bash
# Professional mode examples
auto_use_case -r lib/features/auth/repositories/auth_repository.dart -p lib/features/auth/domain/usecases --pro
auto_use_case -r lib/features/user/repositories/user_repository.dart -p lib/features/user/domain/usecases --pro
auto_use_case -r lib/features/order/repositories/order_repository.dart -p lib/features/order/domain/usecases --pro

# Simple mode examples
auto_use_case -r lib/features/chat/repositories/chat_repository.dart -p lib/features/chat/domain/usecases --simple
auto_use_case -r lib/features/notification/repositories/notification_repository.dart -p lib/features/notification/domain/usecases --simple

# Custom names
auto_use_case -r lib/data/repos.dart -p lib/domain/usecases -n MyRepository --pro
auto_use_case -r lib/api/client.dart -p lib/domain/usecases -n ApiClient --simple
```

## 🏗️ Requirements

Your repository interface should follow one of these patterns:

### Pattern 1: Either/Failure (Recommended)
```dart
Future<Either<Failure, ReturnType>> methodName(Parameters);
```

### Pattern 2: Simple Future
```dart
Future<ReturnType> methodName(Parameters);
```

### Supported Parameter Types
- **Required parameters**: `String userId`
- **Optional parameters**: `String? optionalParam`
- **Named parameters**: `{required String name, int? age}`
- **Generic types**: `List<User>`, `Map<String, dynamic>`, etc.

## ❓ Troubleshooting

### Common Issues
1. **File not found**: Double-check your repository file path
2. **No methods found**: Ensure your methods follow the supported patterns
3. **Import errors**: The generator automatically handles import paths

### Debug Mode
Run with verbose output to see what's happening:
```bash
dart run auto_use_case -r your_repository.dart -p output_path --pro
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Start generating use cases in seconds!** 🎉

```bash
dart pub global activate auto_use_case
auto_use_case -r your_repository.dart -p your_output_path --pro
```

</div>
```

This README has **everything users need** in one place:
- ✅ Installation commands
- ✅ Complete usage examples  
- ✅ Both Simple and Pro mode outputs
- ✅ Advanced scenarios
- ✅ Command reference
- ✅ Troubleshooting guide

Users can just **copy-paste** and start using immediately! 🚀