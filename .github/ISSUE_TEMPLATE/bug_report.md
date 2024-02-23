---
name: Bug report
about: Create a report to help us improve
title: ""
labels: ""
assignees: Aniketkhote
---

**ATTENTION: DO NOT USE THIS FIELD TO ASK SUPPORT QUESTIONS. USE THE PLATFORM CHANNELS FOR THIS. THIS SPACE IS DEDICATED ONLY FOR BUGS DESCRIPTION.**
**Fill in the template. Issues that do not respect the model will be closed.**

**Describe the bug**
A clear and concise description of what the bug is.

**Reproduction code
NOTE: THIS IS MANDATORY, IF YOUR ISSUE DOES NOT CONTAIN IT, IT WILL BE CLOSED PRELIMINARY)**

example:

```dart
 // Create Object
  final vault = Vaultify();

  // Store data
  await vault.write(key: 'username', value: 'john_doe');

  // Read data
  String username = await vault.read(key: 'username');
  print('Username: $username');
```

**To Reproduce**
Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Flutter Version:**
Enter the version of the Flutter you are using

**Getx Version:**
Enter the version of the Getx you are using

**Describe on which device you found the bug:**
ex: Moto z2 - Android.

**Minimal reproduce code**
Provide a minimum reproduction code for the problem
