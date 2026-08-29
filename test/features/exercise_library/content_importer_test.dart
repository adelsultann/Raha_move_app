import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:raha_move/features/exercise_library/domain/content_validation.dart';

import '../../../tool/content_import/content_importer.dart';

const _checksum =
    'af630274a943ecca875e5538a074eb43e0f3d582553e306a781ddfc8e78cdbbd';
const _taxonomy = ContentTaxonomy(
  categories: {'mobility'},
  bodyAreas: {'shoulders'},
  equipment: {'body_weight'},
  positions: {'seated'},
  goals: {'ease_stiffness'},
  contexts: {'everyday_mobility'},
);

void main() {
  group('ContentImporter', () {
    test('matches the Free50 metadata fixture without publishing it', () async {
      final input = await _validInput();
      addTearDown(() => input.delete(recursive: true));

      final result = await ContentImporter(taxonomy: _taxonomy)
          .importDirectory(input);

      expect(
        result.isSuccess,
        isTrue,
        reason: result.issues
            .map((issue) => '${issue.code}:${issue.subject}')
            .join(', '),
      );
      expect(result.exercises.single.id, 'raha_ex_000001');
      expect(result.exercises.single.status.name, 'draft');
      expect(result.mediaAssets.single.sourceFileName, '0051.mp4');
      expect(
        result.mediaAssets.single.deliveryFileName,
        'raha_ex_000001_free50_v1_720.mp4',
      );
      expect(result.routines.single.id, 'raha_rt_000001');
    });

    test('writes byte-identical manifests for an unchanged import', () async {
      final input = await _validInput();
      final first = await Directory.systemTemp.createTemp(
        'raha-import-output-',
      );
      final second = await Directory.systemTemp.createTemp(
        'raha-import-output-',
      );
      addTearDown(() async {
        await input.delete(recursive: true);
        await first.delete(recursive: true);
        await second.delete(recursive: true);
      });
      const importer = ContentImporter(taxonomy: _taxonomy);

      await importer.write(first, await importer.importDirectory(input));
      await importer.write(second, await importer.importDirectory(input));

      for (final name in [
        'exercises.json',
        'media_assets.json',
        'routines.json',
        'import_report.json',
      ]) {
        expect(
          await File('${first.path}/$name').readAsBytes(),
          await File('${second.path}/$name').readAsBytes(),
        );
      }
    });

    test(
      'quarantines duplicate mappings and required access/license fields',
      () async {
        final input = await _validInput();
        addTearDown(() => input.delete(recursive: true));
        await File('${input.path}/mappings.csv')
            .writeAsString('''provider,source_exercise_id,raha_exercise_id
 free50,0051,raha_ex_000001
 free50,0051,raha_ex_999999
''');
        await File('${input.path}/exercises.csv').writeAsString('''raha_id,provider,source_exercise_id,name_en,name_ar,description_en,description_ar,category,body_areas,equipment,difficulty,positions,goals,contexts,safety_review_status,status
 raha_ex_000001,free50,0051,Test,اختبار,Description,وصف,strength,shoulders,body_weight,beginner,seated,ease_stiffness,everyday_mobility,approved,published
''');
        await File('${input.path}/media_assets.csv').writeAsString('''media_id,raha_exercise_id,provider,source_exercise_id,source_filename,type,delivery_file,mime_type,width,height,duration_ms,sha256,variant,preferred,license_reference,status
 raha_media_000001,raha_ex_000001,free50,0051,0051.mp4,video,raha_ex_000001_free50_v1_720.mp4,video/mp4,720,720,5000,bad,female,true,,published
''');

        final result = await ContentImporter(taxonomy: _taxonomy)
            .importDirectory(input);
        final codes = result.issues.map((issue) => issue.code);

        expect(result.isSuccess, isFalse);
        expect(result.exercises, isEmpty);
        expect(result.mediaAssets, isEmpty);
        expect(codes, contains('duplicate_mapping'));
        expect(codes, contains('missing_required_field'));
        expect(codes, contains('missing_license_reference'));
      },
    );

    test('quarantines invalid taxonomy and checksum mismatches', () async {
      final input = await _validInput();
      addTearDown(() => input.delete(recursive: true));
      await File('${input.path}/exercises.csv').writeAsString('''raha_id,provider,source_exercise_id,name_en,name_ar,description_en,description_ar,category,body_areas,equipment,difficulty,positions,goals,contexts,access_tier,safety_review_status,status
 raha_ex_000001,free50,0051,Test,اختبار,Description,وصف,strength,shoulders,body_weight,beginner,seated,ease_stiffness,everyday_mobility,free,approved,published
''');
      await File('${input.path}/media_assets.csv').writeAsString('''media_id,raha_exercise_id,provider,source_exercise_id,source_filename,type,delivery_file,mime_type,width,height,duration_ms,sha256,variant,preferred,license_reference,status
 raha_media_000001,raha_ex_000001,free50,0051,0051.mp4,video,raha_ex_000001_free50_v1_720.mp4,video/mp4,720,720,5000,bad,test,true,free50_fixture,published
''');

      final result = await ContentImporter(taxonomy: _taxonomy)
          .importDirectory(input);
      final codes = result.issues.map((issue) => issue.code);

      expect(codes, contains('invalidTaxonomyKey'));
      expect(codes, contains('checksum_mismatch'));
    });

    test(
      'quarantines corrupt delivery media and missing source files',
      () async {
        final input = await _validInput();
        addTearDown(() => input.delete(recursive: true));
        await File('${input.path}/media/raha_ex_000001_free50_v1_720.mp4')
            .writeAsBytes(<int>[1, 2, 3]);

        var result = await ContentImporter(taxonomy: _taxonomy)
            .importDirectory(input);
        expect(
          result.issues.map((issue) => issue.code),
          contains('corrupt_media'),
        );
        expect(result.mediaAssets, isEmpty);

        await File('${input.path}/media/raha_ex_000001_free50_v1_720.mp4')
            .writeAsBytes(_mediaBytes);
        await File('${input.path}/media/0051.mp4').delete();
        result = await ContentImporter(taxonomy: _taxonomy)
            .importDirectory(input);
        expect(
          result.issues.map((issue) => issue.code),
          contains('missing_media_file'),
        );
      },
    );

    test(
      'quarantines authoring rows missing Arabic translation fields',
      () async {
        final input = await _validInput();
        addTearDown(() => input.delete(recursive: true));
        await File('${input.path}/exercises.csv').writeAsString('''raha_id,provider,source_exercise_id,name_en,name_ar,description_en,description_ar,category,body_areas,equipment,difficulty,positions,goals,contexts,access_tier,safety_review_status,status
raha_ex_000001,free50,0051,Test shoulder movement,,Test description,وصف اختباري,mobility,shoulders,body_weight,beginner,seated,ease_stiffness,everyday_mobility,free,approved,draft
''');

        final result = await ContentImporter(taxonomy: _taxonomy)
            .importDirectory(input);

        expect(result.exercises, isEmpty);
        expect(
          result.issues.map((issue) => issue.code),
          contains('missing_required_field'),
        );
      },
    );
  });
}

final _mediaBytes = Uint8List.fromList(<int>[
  0,
  0,
  0,
  0,
  102,
  116,
  121,
  112,
  105,
  115,
  111,
  109,
]);

Future<Directory> _validInput() async {
  final directory = await Directory.systemTemp.createTemp('raha-import-input-');
  await Directory('${directory.path}/media').create();
  await File('${directory.path}/media/0051.mp4').writeAsBytes(_mediaBytes);
  await File('${directory.path}/media/raha_ex_000001_free50_v1_720.mp4')
      .writeAsBytes(_mediaBytes);
  await File('${directory.path}/provider_metadata.csv').writeAsString(
    await File('test/fixtures/content/free50_metadata_subset.csv')
        .readAsString(),
  );
  await File('${directory.path}/mappings.csv')
      .writeAsString('''provider,source_exercise_id,raha_exercise_id
 free50,0051,raha_ex_000001
''');
  await File('${directory.path}/exercises.csv').writeAsString('''raha_id,provider,source_exercise_id,name_en,name_ar,description_en,description_ar,category,body_areas,equipment,difficulty,positions,goals,contexts,access_tier,safety_review_status,status
 raha_ex_000001,free50,0051,Test shoulder movement,حركة اختبار للكتف,Test description,وصف اختباري,mobility,shoulders,body_weight,beginner,seated,ease_stiffness,everyday_mobility,free,approved,draft
''');
  await File('${directory.path}/media_assets.csv').writeAsString(
    '''media_id,raha_exercise_id,provider,source_exercise_id,source_filename,type,delivery_file,mime_type,width,height,duration_ms,sha256,variant,preferred,license_reference,status
 raha_media_000001,raha_ex_000001,free50,0051,0051.mp4,video,raha_ex_000001_free50_v1_720.mp4,video/mp4,720,720,5000,$_checksum,test,true,free50_fixture,draft
''',
  );
  await File('${directory.path}/routines.json').writeAsString('''[
  {
    "id": "raha_rt_000001", "status": "draft", "accessTier": "free",
    "difficulty": "beginner", "estimatedDurationSeconds": 60, "version": 1,
    "translations": {
      "en": {"name": "Fixture routine", "summary": "A test routine."},
      "ar": {"name": "روتين تجريبي", "summary": "روتين للاختبار."}
    },
    "classification": {
      "bodyAreas": ["shoulders"], "goals": ["ease_stiffness"],
      "positions": ["seated"], "equipment": ["body_weight"],
      "contexts": ["everyday_mobility"]
    },
    "steps": [{"id": "raha_step_000001", "exerciseId": "raha_ex_000001", "position": 1, "durationSeconds": 60, "restAfterSeconds": 0, "isOptional": false}]
  }
]''');
  return directory;
}
