import 'package:app_backend/controller/query/filter_comparator.dart';
import 'package:app_backend/controller/query/query_option.dart';
import 'package:app_backend/controller/query/trip_attribute.dart';

class AttributeFilter implements QueryOption {

  final TripAttribute attribute;
  final String value;
  final FilterComparator? comparator;

  AttributeFilter(this.attribute, this.value) : comparator = null;

  AttributeFilter.withComparator(this.attribute, this.value, this.comparator);

  @override
  String build() {
    // TODO: implement build
    throw UnimplementedError();
  }

}