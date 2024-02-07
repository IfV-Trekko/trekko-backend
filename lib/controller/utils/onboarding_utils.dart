import 'package:app_backend/controller/request/bodies/response/project_metadata_response.dart';
import 'package:app_backend/controller/request/trekko_server.dart';
import 'package:app_backend/controller/request/url_trekko_server.dart';

class OnboardingUtils {
  Future<ProjectMetadataResponse> loadProjectMetadata(
      final String projectUrl) async {
    final TrekkoServer _server = new UrlTrekkoServer(projectUrl);

    final ProjectMetadataResponse? metadata =
        await _server.getProjectMetadata();
    if (metadata == null) throw Exception("Could not load project metadata");

    return metadata;
  }
}
