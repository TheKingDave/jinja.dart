# HOTFIX

This is only a hotfix for a small bug in version `0.3.4`.

bug:
`toBool` asserts that input is not null, what should actually be a 'falsy' value and return `Undefined`/nothing

# Jinja for Dart

[![Pub](https://img.shields.io/pub/v/jinja.svg)](https://pub.dev/packages/jinja)

[Jinja](https://www.palletsprojects.com/p/jinja/) server-side template engine port for Dart 2. Variables, expressions, control structures and template inheritance.

Breaking changes
----------------
Before `object.field` or `object.method()` expressions uses `dart:mirrors` methods.

```dart
import 'package:jinja/jinja.dart';

// ...

final environment = Environment( /* ... */ );
final template = environment.fromString('{{ users[0].name }}');

// ...

outStringSink.write(template.render(users: listOfUsers));
// outStringSink.write(template.renderMap({'users': listOfUsers}));
```

Now to access the fields and methods of the object, (except `namespase`, `loop`, `self` fields and methods), you need to write your own method or import the `get_field` method from the `package:jinja/get_field.dart` file and pass it to the `Environment` constructor.<br>
Or write and pass your method, like [here][jinja_reflectable_example].
```dart
import 'package:jinja/jinja.dart';
import 'package:jinja/get_field.dart' show getField;

// ...

final environment = Environment(getField: getField, /* ... */ );
final template = env.fromString('{{ users[0].name }}');

// ...

outStringSink.write(template.render(users: listOfUsers));
// outStringSink.write(template.renderMap({'users': listOfUsers}));
```

Done
----
- Loaders
  - FileSystemLoader
  - MapLoader (DictLoader)
- Comments
- Variables
- Expressions: variables, literals, subscription, math, comparison, logic, tests, filters, calls
- Filters (not all, see [here][filters])
- Tests
- Statements
  - Filter
  - For (without recursive)
  - If
  - Set
  - Raw
  - Inlcude
  - Extends
  - Block

Example
-------
Add package to your `pubspec.yaml` as a dependency

```yaml
dependencies:
  jinja: ^0.2.0
```

Import library and use it:

```dart
import 'package:jinja/jinja.dart';

// code ...

final environment = Environment(blockStart: '...');
final template = env.fromString('...source...');

outStringSink.write(template.render(key: value));
// outStringSink.write(template.renderMap({'key': value}));
```

Note
----
Why is this [hack][hack] used?

In the final version, templates will be generated by antotation or pub binary and the render function will have named parameters that are used in the template. Working and testing [here][renderable].

Example:
```html
<!-- user.html -->
<p>hello {{ name }}!</p>
```
will transformed to:

```dart
import 'package:renderable/renderable.dart';

class UserTemplate implements Template {
  const UserTemplate();

  @override
  String render({Object name}) {
    final buffer = StringBuffer();
    buffer.write(_t0);
    buffer.write(name);
    buffer.write(_t1);
    return buffer.toString();
  }

  // or with optimizations to

  @override
  String render({Object name}) {
   return '<p>hello $name!</p>';
  }

  static const String _t0 = '<p>hello ';

  static const String _t1 = '!</p>';
}
```

Contributing
------------
If you found a bug, just create a [new issue][new_issue] or even better fork and issue a pull request with your fix.

[jinja_reflectable_example]: https://github.com/ykmnkmi/jinja_reflectable_example/blob/master/bin/main.dart
[filters]: https://github.com/ykmnkmi/dart-jinja/blob/master/lib/src/filters.dart
[hack]: https://github.com/ykmnkmi/jinja.dart/blob/master/lib/src/environment.dart#L299
[renderable]: https://github.com/ykmnkmi/renderable.dart
[new_issue]: https://github.com/ykmnkmi/dart-jinja/issues/new