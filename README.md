# Vaultify

# Vaultify

Vaultify is a versatile local storage solution designed for Flutter applications, providing efficient data persistence and seamless integration.

## Features

- **Efficient Storage**: Vaultify ensures fast and reliable data storage with optimized read and write operations.
- **Customizable**: Tailor Vaultify to your application's needs by easily configuring storage directory and settings.
- **Structured Data Support**: Seamlessly manage complex data structures for versatile storage solutions.
- **Comprehensive Documentation**: Explore well-documented APIs, complete with examples and usage guidelines for effortless integration.

Vaultify simplifies local data storage, empowering Flutter developers to build robust applications with ease.

## Getting Started

To use Vaultify in your Flutter project, simply add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  vaultify: ^1.0.0
```

```dart
import 'package:vaultify/vaultify.dart';
```

## Example

```dart
import 'package:flutter/material.dart';
import 'package:vaultify/vaultify.dart';

void main() async {
  // Initialize Vaultify
  await Vaultify.init();

 // Create Object
  final vault = Vaultify();

  // Store data
  await vault.write(key: 'username', value: 'john_doe');

  // Read data
  String username = await vault.read(key: 'username');
  print('Username: $username');
}
```
