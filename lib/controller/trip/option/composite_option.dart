import 'package:app_backend/controller/trip/option/composite_type.dart';
import 'package:app_backend/controller/trip/option/query_option.dart';
import 'package:app_backend/controller/trip/option/tree_option.dart';
import 'package:app_backend/controller/trip/trip_repository.dart';
import 'package:drift/drift.dart';

class CompositeOption implements TreeOption {
  final CompositeType _type;
  final List<QueryOption> _children;

  CompositeOption(this._type) : _children = [];

  @override
  TreeOption append([List<QueryOption> children = const []]) {
    _children.addAll(children);
    return this;
  }

  @override
  String build() {
    String result = "(";
    for (int i = 0; i < _children.length; i++) {
      result += _children[i].build();
      if (i < _children.length - 1) {
        result += " ${_type.value} ";
      }
    }
    result += ")";
    return result;
  }
}
