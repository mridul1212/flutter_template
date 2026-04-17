import 'package:equatable/equatable.dart';

class VersionPolicy extends Equatable {
  const VersionPolicy({
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.forceIfBelowLatest,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    this.releaseNotesUrl,
  });

  final String minSupportedVersion;
  final String latestVersion;
  final bool forceIfBelowLatest;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final String? releaseNotesUrl;

  @override
  List<Object?> get props =>
      [minSupportedVersion, latestVersion, forceIfBelowLatest, androidStoreUrl, iosStoreUrl, releaseNotesUrl];
}
