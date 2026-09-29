import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_gate.dart';
import 'package:raha_move/app/bootstrap/catalog_bootstrap_providers.dart';
import 'package:raha_move/core/database/app_database.dart';
import 'package:raha_move/features/exercise_library/data/bundled_content_release_source.dart';
import 'package:raha_move/features/exercise_library/data/canonical_json.dart';
import 'package:raha_move/features/exercise_library/data/content_release_source.dart';

import '../../features/exercise_library/data/release_fixture.dart';

void main() {
  testWidgets('shows the localized splash while the catalog loads', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final pendingRelease = Completer<String>();
    final container = _container(
      database,
      loadString: (_) => pendingRelease.future,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CatalogBootstrapGate(child: _Child()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('splash_breathing_arc')), findsOneWidget);
    expect(find.byKey(const Key('catalog_bootstrap_progress')), findsOneWidget);
    expect(find.text('Raha Move'), findsOneWidget);
    expect(find.text('Preparing your movement catalog…'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the splash in Arabic RTL at compact 200% scale', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('ar')];
    tester.binding.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() {
      tester.binding.platformDispatcher.clearLocalesTestValue();
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
      return tester.binding.setSurfaceSize(null);
    });

    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final pendingRelease = Completer<String>();
    final container = _container(
      database,
      loadString: (_) => pendingRelease.future,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CatalogBootstrapGate(child: _Child()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('راحة موف'), findsOneWidget);
    expect(find.text('نحضّر قائمة الحركات الخاصة بك…'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('راحة موف'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the child once the catalog is ready', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = _container(database, loadString: (_) async => _wire());
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CatalogBootstrapGate(child: _Child()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(_Child), findsOneWidget);
  });

  testWidgets('shows a retry action and recovers after a failure', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    var calls = 0;
    final container = _container(
      database,
      loadString: (_) async {
        calls++;
        if (calls == 1) throw Exception('corrupt asset');
        return _wire();
      },
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CatalogBootstrapGate(child: _Child()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('catalog_bootstrap_retry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('catalog_bootstrap_retry')));
    await tester.pumpAndSettle();

    expect(find.byType(_Child), findsOneWidget);
  });
}

String _wire() {
  final manifest = minimalValidManifest(
    releaseId: '0',
    releaseVersion: 'starter-1',
  );
  return jsonEncode({
    'manifest_checksum': canonicalManifestChecksum(
      CanonicalJson.encodeBytes(manifest),
    ),
    'manifest': manifest,
  });
}

ProviderContainer _container(
  AppDatabase database, {
  required Future<String> Function(String) loadString,
}) => ProviderContainer(
  overrides: [
    appDatabaseProvider.overrideWithValue(database),
    contentReleaseSourceProvider.overrideWithValue(
      const NoopContentReleaseSource(),
    ),
    bundledStarterContentProvider.overrideWithValue(
      BundledStarterContent(loadString: loadString),
    ),
    appVersionProvider.overrideWithValue('1.0.0'),
  ],
);

class _Child extends StatelessWidget {
  const _Child();

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: Text('ready')));
}
