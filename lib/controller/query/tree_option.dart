import 'package:app_backend/controller/query/query_option.dart';

abstract class TreeOption extends QueryOption {
  TreeOption append([List<QueryOption> children=const []]);
}
