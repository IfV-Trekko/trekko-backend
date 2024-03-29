import 'package:trekko_backend/controller/request/bodies/request/empty_request.dart';
import 'package:trekko_backend/controller/request/bodies/response/empty_response.dart';
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

  group('EmptyResponse', () {
    test('fromJson returns an instance of EmptyResponse', () {
      var json = {};
      var result = EmptyResponse.fromJson(json);
      expect(result, isA<EmptyResponse>());
    });

    test('toJson returns an empty map', () {
      var response = EmptyResponse();
      var result = response.toJson();
      expect(result, {});
    });
  });
}
