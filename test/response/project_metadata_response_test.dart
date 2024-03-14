import 'package:app_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectMetadataResponse', () {
    test('fromJson should map json to ProjectMetadataResponse correctly', () {
      final json = {
        "name": "Test Project",
        "terms": "Test Terms"
      };

      final result = ProjectMetadataResponse.fromJson(json);

      expect(result.name, "Test Project");
      expect(result.terms, "Test Terms");
    });

    test('toJson should map ProjectMetadataResponse to json correctly', () {
      final response = ProjectMetadataResponse("Test Project", "Test Terms");

      final result = response.toJson();

      expect(result["name"], "Test Project");
      expect(result["terms"], "Test Terms");
    });
  });
}