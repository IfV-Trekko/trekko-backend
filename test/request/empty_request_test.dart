import 'package:app_backend/controller/request/bodies/request/empty_request.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('EmptyRequest Tests', () {
    test('EmptyRequest toJson', () {
      final emptyRequest = EmptyRequest();
      final json = emptyRequest.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json, isEmpty);
    });

    test('EmptyRequest fromJson', () {
      final json = {};
      final emptyRequest = EmptyRequest.fromJson(json);

      expect(emptyRequest, isA<EmptyRequest>());
    });

  });
}
