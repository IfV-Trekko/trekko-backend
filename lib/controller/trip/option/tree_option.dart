import 'package:app_backend/controller/trip/option/query_option.dart';

abstract class TreeOption extends QueryOption {
  TreeOption append([List<QueryOption> children=const []]);
}
