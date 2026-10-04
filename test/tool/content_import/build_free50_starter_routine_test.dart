import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/content_import/bin/build_free50_starter_routine.dart'
    as starter_builder;

void main() {
  test(
    'routine authoring updates both locales and resolves exercise IDs',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'raha-routine-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final manifest = File('${directory.path}/catalog.json')
        ..writeAsBytesSync(
          File('assets/starter_content/manifests/starter_catalog.json')
              .readAsBytesSync(),
        );
      final routineGuidance = File('${directory.path}/routine_guidance.json')
        ..writeAsBytesSync(
          File('content/authoring/routine_guidance.json').readAsBytesSync(),
        );
      void build() => starter_builder.main([
        '--manifest=${manifest.path}',
        '--routine-guidance=${routineGuidance.path}',
      ]);

      final initialReleaseId = int.parse(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id']
            as String,
      );
      build();
      expect(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id'],
        '$initialReleaseId',
      );

      final authored = jsonDecode(
        routineGuidance.readAsStringSync(),
      ) as Map<String, dynamic>;
      final routine = authored['raha_rt_000001'] as Map<String, dynamic>;
      (routine['en'] as Map<String, dynamic>)['name'] = 'Gentle seated reset';
      (routine['ar'] as Map<String, dynamic>)['summary'] = 'حركات جلوس هادئة.';
      final steps = routine['steps'] as List;
      final first = steps.removeAt(0);
      steps.add(first);
      (steps[0] as Map<String, dynamic>)['duration_seconds'] = 45;
      routineGuidance.writeAsStringSync(jsonEncode(authored));

      build();
      final output =
          jsonDecode(manifest.readAsStringSync())['manifest']
              as Map<String, dynamic>;
      expect(output['release']['id'], '${initialReleaseId + 1}');
      final translations = (output['routine_translations'] as List)
          .cast<Map<String, dynamic>>()
          .where(
            (row) =>
                row['routine_id'] == '03000000-0000-0000-0000-000000000001',
          )
          .toList();
      expect(
        translations.singleWhere((row) => row['locale'] == 'en')['name'],
        'Gentle seated reset',
      );
      expect(
        translations.singleWhere((row) => row['locale'] == 'ar')['summary'],
        'حركات جلوس هادئة.',
      );
      final generatedSteps = (output['routine_steps'] as List)
          .cast<Map<String, dynamic>>()
          .where(
            (row) =>
                row['routine_id'] == '03000000-0000-0000-0000-000000000001',
          )
          .toList();
      expect(
        generatedSteps.first['exercise_id'],
        '01000000-0000-0000-0000-000000000002',
      );
      expect(
        generatedSteps.first['id'],
        '04000000-0000-0000-0000-000000000002',
      );
      expect(generatedSteps.first['duration_seconds'], 45);
      final generatedRoutine = (output['routines'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((row) => row['public_id'] == 'raha_rt_000001');
      expect(generatedRoutine['estimated_duration_seconds'], 75);

      build();
      expect(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id'],
        '${initialReleaseId + 1}',
      );

      (steps[0] as Map<String, dynamic>)['exercise_id'] = 'raha_ex_999999';
      routineGuidance.writeAsStringSync(jsonEncode(authored));
      final beforeRejectedBuild = manifest.readAsBytesSync();
      expect(build, throwsFormatException);
      expect(manifest.readAsBytesSync(), beforeRejectedBuild);
    },
  );

  test(
    'guidance builds both locales, advances once, and rejects partial steps',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'raha-guidance-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final manifest = File('${directory.path}/catalog.json')
        ..writeAsBytesSync(
          File('assets/starter_content/manifests/starter_catalog.json')
              .readAsBytesSync(),
        );
      final guidance = File('${directory.path}/guidance.json')
        ..writeAsBytesSync(
          File('content/authoring/exercise_guidance.json').readAsBytesSync(),
        );
      void build() => starter_builder.main([
        '--manifest=${manifest.path}',
        '--guidance=${guidance.path}',
      ]);
      final initialReleaseId = int.parse(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id']
            as String,
      );

      build();
      expect(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id'],
        '$initialReleaseId',
      );

      final authored =
          jsonDecode(guidance.readAsStringSync()) as Map<String, dynamic>;
      final exercise = authored['raha_ex_000101'] as Map<String, dynamic>;
      (exercise['en'] as Map<String, dynamic>)['instructions'] = [
        'Stand comfortably.',
        'Raise and lower your shoulders slowly.',
      ];
      (exercise['ar'] as Map<String, dynamic>)['instructions'] = [
        'اتخذ وضعية وقوف مريحة.',
        'ارفع كتفيك ببطء ثم أخفضهما.',
      ];
      guidance.writeAsStringSync(jsonEncode(authored));
      build();
      final output =
          jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
      final release = output['manifest'] as Map<String, dynamic>;
      expect(release['release']['id'], '${initialReleaseId + 1}');
      final translations = (release['exercise_translations'] as List)
          .cast<Map<String, dynamic>>()
          .where(
            (row) =>
                row['exercise_id'] == '01000000-0000-0000-0000-000000000101',
          );
      for (final row in translations) {
        expect(
          row['instructions'],
          (exercise[row['locale']] as Map<String, dynamic>)['instructions'],
        );
      }

      build();
      expect(
        jsonDecode(manifest.readAsStringSync())['manifest']['release']['id'],
        '${initialReleaseId + 1}',
      );

      (exercise['ar'] as Map<String, dynamic>)['instructions'] = <String>[];
      guidance.writeAsStringSync(jsonEncode(authored));
      final beforeRejectedBuild = manifest.readAsBytesSync();
      expect(build, throwsFormatException);
      expect(manifest.readAsBytesSync(), beforeRejectedBuild);
    },
  );
}
