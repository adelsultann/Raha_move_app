import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/theme/appearance_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appearance choice survives a new provider container', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final first = ProviderContainer();
    addTearDown(first.dispose);
    expect(
      await first.read(appearanceControllerProvider.future),
      AppAppearance.dark,
    );
    await first
        .read(appearanceControllerProvider.notifier)
        .select(AppAppearance.night);

    final second = ProviderContainer();
    addTearDown(second.dispose);
    expect(
      await second.read(appearanceControllerProvider.future),
      AppAppearance.night,
    );
  });
}
