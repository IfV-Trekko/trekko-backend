import 'package:app_backend/controller/database/trip/option/filter_comparator.dart';
import 'package:app_backend/controller/database/trip/option/query_option.dart';
import 'package:app_backend/model/trip/trip_attribute.dart';

class AttributeFilter implements QueryOption {

  final TripAttribute attribute;
  final String value;
  final FilterComparator comparator;

  AttributeFilter(this.attribute, this.value, [this.comparator = FilterComparator.equal]);

  @override
  String build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}