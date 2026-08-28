/// Public, non-secret values that may vary between build environments.
final class EnvironmentSettings {
  const EnvironmentSettings({required this.name});

  final String name;
}
