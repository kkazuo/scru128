<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

SCRU128 ID is yet another attempt to supersede UUID for the users
who need decentralized, globally unique time-ordered identifiers.

See [the spec](https://github.com/scru128/spec) for details.

## Features

- Generate SCRU128 ID.

## Getting started

```shell
$ dart pub add scru128
```

Then import it.

```dart
import 'package:scru128/scru128.dart';
```

## Usage

To generate single ID.

```dart
final scru128id = Scru128Id();
print(scru128id);
```

You can iterate id for generating many ids.

```dart
final scru128gen = Scru128Generator();
for (final id in scr128gen) {
  print(id);
}
```

## Additional information

See also

- https://github.com/kkazuo/scru128

## License

Licensed under the Apache License, Version 2.0.
