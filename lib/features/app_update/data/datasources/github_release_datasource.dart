import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';

class GitHubReleaseDatasource {
  GitHubReleaseDatasource(this._dio);

  static const _latestReleaseUrl =
      'https://api.github.com/repos/${AppConfig.githubOwner}/${AppConfig.githubRepo}/releases/latest';

  final Dio _dio;

  Future<({String tagName, String htmlUrl})?> fetchLatestStableRelease() async {
    final response = await _dio.get<Object?>(
      _latestReleaseUrl,
      options: Options(
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'WorkNexus',
        },
      ),
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Invalid GitHub release response');
    }

    final tagName = body['tag_name'];
    final htmlUrl = body['html_url'];
    if (tagName is! String ||
        htmlUrl is! String ||
        body['draft'] != false ||
        body['prerelease'] != false) {
      throw const FormatException('GitHub did not return a stable release');
    }
    return (tagName: tagName, htmlUrl: htmlUrl);
  }
}
