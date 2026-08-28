import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/config/build_config.dart';
import '../domain/foundation_status.dart';

part 'foundation_status_provider.g.dart';

@riverpod
FoundationStatus foundationStatus(Ref ref) {
  final config = BuildConfig.fromDartDefine();
  return FoundationStatus(isReady: true, environment: config.environment.name);
}
