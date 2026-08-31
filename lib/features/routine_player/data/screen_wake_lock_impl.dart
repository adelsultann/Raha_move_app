import 'package:wakelock_plus/wakelock_plus.dart';

import '../domain/playback_support.dart';

/// [ScreenWakeLock] backed by the `wakelock_plus` plugin. The plugin stays
/// behind this interface so widget tests use a fake and the native plugin never
/// leaks into domain or presentation logic.
final class WakelockScreenWakeLock implements ScreenWakeLock {
  const WakelockScreenWakeLock();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
