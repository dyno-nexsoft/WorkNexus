import '../../../../core/error/result.dart';

typedef UpdateVersionSnapshot = ({
  String currentVersion,
  String latestVersion,
  String releaseUrl,
});

abstract class UpdateRepository {
  Future<Result<UpdateVersionSnapshot?>> fetchLatestStableRelease();
}
