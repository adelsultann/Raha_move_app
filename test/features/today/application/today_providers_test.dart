import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/authentication/application/auth_controller.dart';
import 'package:raha_move/features/authentication/domain/auth_state.dart';
import 'package:raha_move/features/today/application/today_providers.dart';

void main() {
  test('stops loading when disposed while authentication is pending', () async {
    final authentication = Completer<AuthState>();
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(
          () => _DeferredAuthController(authentication.future),
        ),
      ],
    );
    final subscription = container.listen(todayDashboardProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);

    container.dispose();
    authentication.complete(
      const AuthState(activeUserId: 'guest-1', status: AuthStatus.guest),
    );
    await Future<void>.delayed(Duration.zero);

    subscription.close();
  });
}

final class _DeferredAuthController extends AuthController {
  _DeferredAuthController(this.authentication);

  final Future<AuthState> authentication;

  @override
  Future<AuthState> build() => authentication;
}
