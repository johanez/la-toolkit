import 'dart:ui';

import 'package:flutter/material.dart';

/*
class ResultsColors {
  static final basicGraphPalette = const <Color>[
    Color.fromRGBO(75, 135, 185, 1),
    Color.fromRGBO(192, 108, 132, 1),
    Color.fromRGBO(246, 114, 128, 1),
    Color.fromRGBO(248, 177, 149, 1),
    Color.fromRGBO(116, 180, 155, 1),
    Color.fromRGBO(0, 168, 181, 1),
    Color.fromRGBO(73, 76, 162, 1),
    Color.fromRGBO(255, 205, 96, 1),
    Color.fromRGBO(255, 240, 219, 1),
    Color.fromRGBO(238, 238, 238, 1)
  ];

  static final Color ok = Colors.green;
  static final Color failure =
      Color.fromRGBO(246, 114, 128, 1); // Colors.redAccent
  static final Color skipped = Colors.grey;
  static final Color changed = Colors.brown;
  static final Color ignored = Colors.grey;
  static final Color rescued = Colors.blueGrey;
} */

enum ResultType {
  changed,
  failures,
  ignored,
  ok,
  rescued,
  skipped,
  unreachable
}

extension ParseToString on ResultType {
  String toS() {
    return this.toString().split('.').last;
  }

  Color get color {
    switch (this) {
      case ResultType.changed:
        return Colors.brown;
      case ResultType.failures:
        return Color.fromRGBO(246, 114, 128, 1);
      case ResultType.ignored:
        return Colors.grey;
      case ResultType.ok:
        return Colors.green;
      case ResultType.rescued:
        return Colors.blueGrey;
      case ResultType.skipped:
        return Colors.grey;
      case ResultType.unreachable:
        return Colors.deepOrange;
    }
  }
}

class ResultTypes {
  static List<String>? _list;

  static List<String> get list {
    if (_list == null)
      _list = ResultType.values.map((ResultType v) => v.toS()).toList();
    return _list!;
  }
}
