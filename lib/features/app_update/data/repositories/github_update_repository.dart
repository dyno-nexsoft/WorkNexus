import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/debug/app_talker.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/update_repository.dart';
import '../datasources/github_release_datasource.dart';

class GitHubUpdateRepository implements UpdateRepository {
  const GitHubUpdateRepository(this._releaseDatasource);

  final GitHubReleaseDatasource _releaseDatasource;

  @override
  Future<Result<UpdateVersionSnapshot?>> fetchLatestStableRelease() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final release = await _releaseDatasource.fetchLatestStableRelease();
      if (release == null) return const Ok(null);

      return Ok((
        currentVersion: packageInfo.version,
        latestVersion: release.tagName,
        releaseUrl: release.htmlUrl,
      ));
    } on DioException catch (error, stackTrace) {
      if (error.response?.statusCode == 404) return const Ok(null);
      appTalker.handle(error, stackTrace, 'Update check failed');
      return Err(NetworkFailure('Could not check for updates', cause: error));
    } on FormatException catch (error, stackTrace) {
      appTalker.handle(error, stackTrace, 'Update check response was invalid');
      return Err(
        ParseFailure('Could not read the latest release', cause: error),
      );
    } on PlatformException catch (error, stackTrace) {
      appTalker.handle(error, stackTrace, 'Could not read app version');
      return Err(UnexpectedFailure('Could not read app version', cause: error));
    } catch (error, stackTrace) {
      appTalker.handle(error, stackTrace, 'Update check failed unexpectedly');
      return Err(
        UnexpectedFailure('Could not check for updates', cause: error),
      );
    }
  }
}
