import '../context.dart';
import '../markup.dart';
import '../utils.dart';

export '../context.dart';
export '../utils.dart';

abstract class Node {
  void accept(StringSink outSink, Context context);

  String toDebugString([int level = 0]);
}

abstract class Statement extends Node {}

abstract class Expression extends Node {
  Object resolve(Context context) => null;

  @override
  void accept(StringSink outSink, Context context) {
    var value = resolve(context);

    if (value is Node) {
      value.accept(outSink, context);
    } else {
      value = context.environment.finalize(value);

      if (context.environment.autoEscape) {
        value = Markup.escape(value.toString());
      }

      outSink.write(value);
    }
  }
}

abstract class UnaryExpression extends Expression {
  Expression get expr;
  String get symbol;

  @override
  String toDebugString([int level = 0]) => ' ' * level + '$symbol${expr.toDebugString()}';
}

abstract class BinaryExpression extends Expression {
  Expression get left;
  Expression get right;
  String get symbol;

  @override
  String toDebugString([int level = 0]) {
    final StringBuffer buffer = StringBuffer(' ' * level);
    buffer.write('${left.toDebugString()} $symbol ${right.toDebugString()}');
    return '$buffer';
  }
}

abstract class CanAssign {
  List<String> get keys;
  bool get canAssign => false;
}

class Name extends Expression implements CanAssign {
  Name(this.name);

  final String name;

  @override
  dynamic resolve(Context context) => context[name];

  @override
  bool get canAssign => true;

  @override
  List<String> get keys => <String>[name];

  @override
  String toDebugString([int level = 0]) => ' ' * level + name;

  @override
  String toString() => 'Name($name)';
}

class Literal<T> extends Expression {
  Literal(this.value);

  final T value;

  @override
  T resolve(Context context) => value;

  @override
  String toDebugString([int level = 0]) => ' ' * level + repr(value);

  @override
  String toString() => 'Literal($value)';
}
