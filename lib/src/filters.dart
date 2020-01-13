import 'dart:math' show Random, pow;

import 'environment.dart';
import 'markup.dart';
import 'runtime.dart';
import 'utils.dart';

final Expando<FilterType> _filterTypes = Expando<FilterType>();

enum FilterType {
  context,
  environment,
}

extension FilterFunction on Function {
  FilterType get filterType {
    return _filterTypes[this];
  }

  set filterType(FilterType type) {
    _filterTypes[this] = type;
  }
}

final Map<String, Function> filters = <String, Function>{
  'attr': doAttr..filterType = FilterType.environment,
  'join': doJoin..filterType = FilterType.environment,
  'sum': doSum..filterType = FilterType.environment,

  'abs': doAbs,
  'batch': doBatch,
  'capitalize': doCapitalize,
  'center': doCenter,
  'count': doCount,
  'd': doDefault,
  'default': doDefault,
  'e': doEscape,
  'escape': doEscape,
  'filesizeformat': doFileSizeFormat,
  'first': doFirst,
  'float': doFloat,
  'forceescape': doForceEscape,
  'int': doInt,
  'last': doLast,
  'length': doCount,
  'list': doList,
  'lower': doLower,
  'random': doRandom,
  'string': doString,
  'trim': doTrim,
  'upper': doUpper,

  // 'dictsort': doDictSort,
  // 'format': doFormat,
  // 'groupby': doGroupBy,
  // 'indent': doIndent,
  // 'map': doMap,
  // 'max': doMax,
  // 'min': doMin,
  // 'pprint': doPPrint,
  // 'reject': doReject,
  // 'rejectattr': doRejectAttr,
  // 'replace': doReplace,
  // 'reverse': doReverse,
  // 'round': doRound,
  // 'safe': doMarkSafe,
  // 'select': doSelect,
  // 'selectattr': doSelectAttr,
  // 'slice': doSlice,
  // 'sort': doSort,
  // 'striptags': doStripTags,
  // 'title': doTitle,
  // 'tojson': doToJson,
  // 'truncate': doTruncate,
  // 'unique': doUnique,
  // 'urlencode': doURLEncode,
  // 'urlize': doURLize,
  // 'wordcount': doWordCount,
  // 'wordwrap': doWordwrap,
  // 'xmlattr': doXMLAttr,
};

num doAbs(num n) => n.abs();

Object doAttr(Environment env, Object value, String attribute) {
  return env.getItem(value, attribute) ?? env.getField(value, attribute);
}

Iterable<List<Object>> doBatch(Iterable<Object> values, int lineCount,
    [Object fillWith]) sync* {
  List<Object> tmp = <Object>[];

  for (Object item in values) {
    if (tmp.length == lineCount) {
      yield tmp;
      tmp = <Object>[];
    }

    tmp.add(item);
  }

  if (tmp.isNotEmpty) {
    if (fillWith != null) {
      tmp.addAll(List<Object>.filled(lineCount - tmp.length, fillWith));
    }

    yield tmp;
  }
}

String doCapitalize(String value) {
  return value.substring(0, 1).toUpperCase() + value.substring(1).toLowerCase();
}

String doCenter(String value, int width) {
  if (value.length >= width) {
    return value;
  }

  final int padLength = (width - value.length) ~/ 2;
  final String pad = ' ' * padLength;
  return pad + value + pad;
}

int doCount(Object value) {
  if (value is String) {
    return value.length;
  }

  if (value is Iterable) {
    return value.length;
  }

  if (value is Map) {
    return value.length;
  }

  return null;
}

Object doDefault(Object value, [Object $default = '', bool boolean = false]) {
  if (boolean) {
    return toBool(value) ? value : $default;
  }

  return value is! Undefined ? value : $default;
}

Markup doEscape(Object value) {
  return value is Markup ? value : Markup.escape(value.toString());
}

// TODO: проверить: текст ошибки
String doFileSizeFormat(Object value, [bool binary = false]) {
  final double bytes =
      value is num ? value.toDouble() : double.parse(value.toString());
  final int base = binary ? 1024 : 1000;

  const List<List<String>> prefixes = <List<String>>[
    <String>['KiB', 'kB'],
    <String>['MiB', 'MB'],
    <String>['GiB', 'GB'],
    <String>['TiB', 'TB'],
    <String>['PiB', 'PB'],
    <String>['EiB', 'EB'],
    <String>['ZiB', 'ZB'],
    <String>['YiB', 'YB'],
  ];

  if (bytes == 1.0) {
    return '1 Byte';
  } else if (bytes < base) {
    final String size = bytes.toStringAsFixed(1);
    return '${size.endsWith('.0') ? size.substring(0, size.length - 2) : size} Bytes';
  } else {
    final int k = binary ? 0 : 1;
    num unit;

    for (int i = 0; i < prefixes.length; i++) {
      unit = pow(base, i + 2);

      if (bytes < unit) {
        return '${(base * bytes / unit).toStringAsFixed(1)} ${prefixes[i][k]}';
      }
    }

    return '${(base * bytes / unit).toStringAsFixed(1)} ${prefixes.last[k]}';
  }
}

Object doFirst(Iterable<Object> values) {
  return values.first;
}

double doFloat(Object value, [double $default = 0.0]) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString()) ?? $default;
}

Markup doForceEscape(Object value) {
  return Markup.escape(value.toString());
}

int doInt(Object value, [int $default = 0, int base = 10]) {
  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value.toString(), radix: base) ?? $default;
}

String doJoin(Environment env, Iterable<Object> values,
    [String d = '', String attribute]) {
  if (attribute != null) {
    return values
        .map<Object>((Object value) => doAttr(env, value, attribute))
        .join(d);
  }

  return values.join(d);
}

Object doLast(Iterable<Object> values) {
  return values.last;
}

List<Object> doList(Object value) {
  if (value is Iterable) {
    return value.toList();
  }

  if (value is String) {
    return value.split('');
  }

  return <Object>[value];
}

String doLower(Object value) {
  return repr(value, false).toLowerCase();
}

final Random _rnd = Random();
Object doRandom(List<Object> values) {
  final int length = values.length;
  return values[_rnd.nextInt(length)];
}

String doString(Object value) {
  return repr(value, false);
}

num doSum(Environment env, Iterable<Object> values,
    {String attribute, num start = 0}) {
  if (attribute != null) {
    values = values.map<Object>((Object val) => doAttr(env, val, attribute));
  }

  return values.cast<num>().fold<num>(start, (num s, num n) => s + n);
}

String doTrim(Object value) {
  return repr(value, false).trim();
}

String doUpper(Object value) {
  return repr(value, false).toUpperCase();
}
