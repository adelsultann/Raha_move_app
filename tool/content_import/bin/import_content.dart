import 'dart:io';

import '../content_importer.dart';

import 'package:raha_move/features/exercise_library/domain/content_validation.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length != 2) {
    stderr.writeln(
      'Usage: dart run tool/content_import/bin/import_content.dart <input-dir> <output-dir>',
    );
    exitCode = 64;
    return;
  }
  const taxonomy = ContentTaxonomy(
    categories: {'mobility'},
    bodyAreas: {
      'neck',
      'shoulders',
      'upper_back',
      'lower_back',
      'hips',
      'knees',
      'full_body',
    },
    equipment: {'body_weight'},
    positions: {'seated', 'standing', 'floor'},
    goals: {'ease_stiffness', 'move_more_freely'},
    contexts: {'everyday_mobility'},
  );
  final result = await ContentImporter(taxonomy: taxonomy)
      .importDirectory(Directory(arguments[0]));
  await ContentImporter(taxonomy: taxonomy)
      .write(Directory(arguments[1]), result);
  if (!result.isSuccess) exitCode = 1;
}
