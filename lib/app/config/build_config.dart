import 'environments/development_environment.dart';
import 'environment_settings.dart';
import 'environments/production_environment.dart';
import 'environments/staging_environment.dart';
import 'environments/test_environment.dart';

enum AppEnvironment { development, staging, test, production }

/// Non-secret, compile-time environment selection.
final class BuildConfig {
  const BuildConfig._(this.environment, this.settings);

  factory BuildConfig.fromDartDefine() {
    const value = String.fromEnvironment(
      'RAHA_ENV',
      defaultValue: 'development',
    );
    return switch (value) {
      'development' => const BuildConfig._(
        AppEnvironment.development,
        developmentEnvironment,
      ),
      'staging' => const BuildConfig._(
        AppEnvironment.staging,
        stagingEnvironment,
      ),
      'test' => const BuildConfig._(AppEnvironment.test, testEnvironment),
      'production' => const BuildConfig._(
        AppEnvironment.production,
        productionEnvironment,
      ),
      _ => throw ArgumentError.value(
        value,
        'RAHA_ENV',
        'Unsupported environment',
      ),
    };
  }

  final AppEnvironment environment;
  final EnvironmentSettings settings;
}
