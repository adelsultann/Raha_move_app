import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'appearance_controller.g.dart';

enum AppAppearance { light, dark, night }

@Riverpod(keepAlive: true)
class AppearanceController extends _$AppearanceController {
  static const _key = 'raha_appearance';
  static const _storage = FlutterSecureStorage();

  @override
  Future<AppAppearance> build() async {
    final saved = await _storage.read(key: _key);
    return AppAppearance.values.firstWhere(
      (appearance) => appearance.name == saved,
      orElse: () => AppAppearance.dark,
    );
  }

  Future<void> select(AppAppearance appearance) async {
    final previous = state.value ?? AppAppearance.dark;
    state = AsyncData(appearance);
    try {
      await _storage.write(key: _key, value: appearance.name);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}
