import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:raha_move/features/exercise_library/domain/content_models.dart';
import 'package:raha_move/features/exercise_library/domain/content_validation.dart';

/// Imports editor-owned CSV/JSON sources into application-owned manifests.
///
/// Expected input files: `provider_metadata.csv`, `mappings.csv`,
/// `exercises.csv`, `media_assets.csv`, `routines.json`, and `media/`.
/// Media filenames in CSV are relative to `media/`; generated manifests are
/// intentionally the only files written by this tool.
final class ContentImporter {
  const ContentImporter({required this.taxonomy});

  final ContentTaxonomy taxonomy;

  Future<ImportResult> importDirectory(Directory input) async {
    final issues = <ImportIssue>[];
    final providerRows = await _readCsv(input, 'provider_metadata.csv', issues);
    final mappingRows = await _readCsv(input, 'mappings.csv', issues);
    final exerciseRows = await _readCsv(input, 'exercises.csv', issues);
    final mediaRows = await _readCsv(input, 'media_assets.csv', issues);
    final routineValues = await _readRoutines(input, issues);

    final providerFiles = <String, String>{};
    final ambiguousProviderKeys = <String>{};
    for (final row in providerRows) {
      final provider = row['provider'];
      final sourceId = row['source_exercise_id'];
      final sourceFile = row['source_filename'];
      if (_blank(provider) || _blank(sourceId) || _blank(sourceFile)) {
        issues.add(
          _issue(
            'invalid_provider_metadata',
            'provider_metadata.csv',
            'provider, source_exercise_id, and source_filename are required',
          ),
        );
        continue;
      }
      final key = '$provider\u0000$sourceId';
      if (providerFiles.containsKey(key)) {
        ambiguousProviderKeys.add(key);
        issues.add(
          _issue(
            'duplicate_provider_metadata',
            key,
            'Provider metadata maps one source exercise to multiple files',
          ),
        );
      } else {
        providerFiles[key] = sourceFile!;
      }
    }

    final mappings = <String, String>{};
    final ambiguousMappingKeys = <String>{};
    for (final row in mappingRows) {
      final provider = row['provider'];
      final sourceId = row['source_exercise_id'];
      final rahaId = row['raha_exercise_id'];
      if (_blank(provider) || _blank(sourceId) || _blank(rahaId)) {
        issues.add(
          _issue(
            'invalid_mapping',
            'mappings.csv',
            'provider, source_exercise_id, and raha_exercise_id are required',
          ),
        );
        continue;
      }
      final key = '$provider\u0000$sourceId';
      if (mappings.containsKey(key)) {
        ambiguousMappingKeys.add(key);
        issues.add(
          _issue(
            'duplicate_mapping',
            key,
            mappings[key] == rahaId
                ? 'A provider source exercise is mapped more than once'
                : 'A provider source exercise has conflicting Raha mappings',
          ),
        );
      } else {
        mappings[key] = rahaId!;
      }
    }
    for (final key in providerFiles.keys) {
      if (!mappings.containsKey(key)) {
        ambiguousMappingKeys.add(key);
        issues.add(
          _issue(
            'missing_mapping',
            key,
            'Provider metadata must have an explicit Raha mapping',
          ),
        );
      }
    }
    for (final key in mappings.keys) {
      if (!providerFiles.containsKey(key)) {
        ambiguousMappingKeys.add(key);
        issues.add(
          _issue(
            'missing_provider_metadata',
            key,
            'A mapping must be backed by provider metadata',
          ),
        );
      }
    }

    final exerciseById = <String, Exercise>{};
    final rejectedExercises = <String>{};
    for (var index = 0; index < exerciseRows.length; index++) {
      final row = exerciseRows[index];
      final location = 'exercises.csv:${index + 2}';
      final exercise = _exerciseFromRow(row, location, issues);
      if (exercise == null) continue;
      if (exerciseById.containsKey(exercise.id)) {
        rejectedExercises.add(exercise.id);
        issues.add(
          _issue(
            'duplicate_raha_exercise_id',
            exercise.id,
            'Exercise ID ${exercise.id} is repeated at $location',
          ),
        );
        continue;
      }
      for (final mapping in exercise.providerMappings) {
        final key = '${mapping.providerKey}\u0000${mapping.sourceExerciseId}';
        if (ambiguousProviderKeys.contains(key) ||
            ambiguousMappingKeys.contains(key) ||
            mappings[key] != exercise.id) {
          rejectedExercises.add(exercise.id);
          issues.add(
            _issue(
              'missing_or_conflicting_mapping',
              location,
              'Provider mapping $key must explicitly map to ${exercise.id}',
            ),
          );
        }
      }
      exerciseById[exercise.id] = exercise;
    }

    final mediaByExercise = <String, List<MediaAsset>>{};
    final rejectedMedia = <String>{};
    final mediaIds = <String>{};
    for (var index = 0; index < mediaRows.length; index++) {
      final row = mediaRows[index];
      final location = 'media_assets.csv:${index + 2}';
      final media = await _mediaFromRow(input, row, location, issues);
      if (media == null) continue;
      if (!mediaIds.add(media.id)) {
        rejectedMedia.add(media.id);
        issues.add(
          _issue(
            'duplicate_raha_media_id',
            location,
            'Media ID ${media.id} is repeated',
          ),
        );
        continue;
      }
      final key = '${media.providerKey}\u0000${media.sourceExerciseId}';
      if (media.providerKey == null ||
          media.sourceExerciseId == null ||
          ambiguousProviderKeys.contains(key) ||
          ambiguousMappingKeys.contains(key) ||
          mappings[key] != media.exerciseId ||
          providerFiles[key] != media.sourceFileName) {
        rejectedMedia.add(media.id);
        issues.add(
          _issue(
            'ambiguous_media_mapping',
            location,
            'Media must match explicit mapping and provider metadata exactly',
          ),
        );
      }
      mediaByExercise.putIfAbsent(media.exerciseId, () => []).add(media);
    }

    final validator = ContentValidator(taxonomy);
    final exercises = <Exercise>[];
    for (final id in exerciseById.keys.toList()..sort()) {
      final base = exerciseById[id]!;
      final media =
          (mediaByExercise[id] ?? [])
              .where((asset) => !rejectedMedia.contains(asset.id))
              .toList()
            ..sort((a, b) => a.id.compareTo(b.id));
      final exercise = base.copyWith(mediaAssets: media);
      final validation = validator.validateExercise(exercise);
      _addValidationIssues(validation, issues);
      if (!rejectedExercises.contains(id) && validation.isValid) {
        exercises.add(exercise);
      }
    }

    final routinesById = <String, Routine>{};
    final rejectedRoutineIds = <String>{};
    for (var index = 0; index < routineValues.length; index++) {
      final location = 'routines.json:${index + 1}';
      final routine = _routineFromJson(routineValues[index], location, issues);
      if (routine == null) continue;
      if (routinesById.containsKey(routine.id)) {
        rejectedRoutineIds.add(routine.id);
        issues.add(
          _issue(
            'duplicate_raha_routine_id',
            routine.id,
            'Routine ID ${routine.id} is repeated at $location',
          ),
        );
        continue;
      }
      routinesById[routine.id] = routine;
    }
    final routines = <Routine>[];
    for (final id in routinesById.keys.toList()..sort()) {
      final routine = routinesById[id]!;
      final validation = validator.validateRoutine(
        routine,
        exercises: exercises,
      );
      _addValidationIssues(validation, issues);
      if (!rejectedRoutineIds.contains(id) && validation.isValid) {
        routines.add(routine);
      }
    }
    exercises.sort((a, b) => a.id.compareTo(b.id));
    routines.sort((a, b) => a.id.compareTo(b.id));
    final allMedia =
        exercises.expand((exercise) => exercise.mediaAssets).toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return ImportResult(
      exercises: exercises,
      mediaAssets: allMedia,
      routines: routines,
      issues: issues..sort(ImportIssue.compare),
    );
  }

  Future<void> write(Directory output, ImportResult result) async {
    await output.create(recursive: true);
    await _writeJson(File('${output.path}/exercises.json'), {
      'exercises': result.exercises.map((value) => value.toJson()).toList(),
    });
    await _writeJson(File('${output.path}/media_assets.json'), {
      'mediaAssets': result.mediaAssets.map((value) => value.toJson()).toList(),
    });
    await _writeJson(File('${output.path}/routines.json'), {
      'routines': result.routines.map((value) => value.toJson()).toList(),
    });
    await _writeJson(
      File('${output.path}/import_report.json'),
      result.toJson(),
    );
  }

  Future<List<Map<String, String>>> _readCsv(
    Directory input,
    String name,
    List<ImportIssue> issues,
  ) async {
    final file = File('${input.path}/$name');
    if (!await file.exists()) {
      issues.add(
        _issue('missing_input_file', name, 'Required source file is absent'),
      );
      return [];
    }
    final lines = const LineSplitter().convert(await file.readAsString());
    if (lines.isEmpty) return [];
    final headers = _csvLine(lines.first).map((value) => value.trim()).toList();
    final rows = <Map<String, String>>[];
    for (var index = 1; index < lines.length; index++) {
      final line = lines[index];
      if (line.isEmpty) continue;
      final values = _csvLine(line).map((value) => value.trim()).toList();
      if (values.length != headers.length) {
        issues.add(
          _issue(
            'invalid_csv_row',
            '$name:${index + 1}',
            'Expected ${headers.length} columns, found ${values.length}',
          ),
        );
        continue;
      }
      rows.add(Map<String, String>.fromIterables(headers, values));
    }
    return rows;
  }

  Future<List<Object?>> _readRoutines(
    Directory input,
    List<ImportIssue> issues,
  ) async {
    final file = File('${input.path}/routines.json');
    if (!await file.exists()) {
      issues.add(
        _issue(
          'missing_input_file',
          'routines.json',
          'Required source file is absent',
        ),
      );
      return [];
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is List) {
        return decoded;
      }
      if (decoded is Map && decoded['routines'] is List) {
        return decoded['routines'] as List<Object?>;
      }
    } on FormatException {
      // Report the source file below without leaking parser internals.
    }
    issues.add(
      _issue(
        'invalid_routines_json',
        'routines.json',
        'Expected a list or a routines list',
      ),
    );
    return [];
  }

  Exercise? _exerciseFromRow(
    Map<String, String> row,
    String location,
    List<ImportIssue> issues,
  ) {
    const required = [
      'raha_id',
      'provider',
      'source_exercise_id',
      'name_en',
      'name_ar',
      'description_en',
      'description_ar',
      'category',
      'body_areas',
      'difficulty',
      'positions',
      'goals',
      'contexts',
      'access_tier',
      'safety_review_status',
      'status',
    ];
    if (!_required(row, required, location, issues)) return null;
    try {
      return Exercise(
        id: row['raha_id']!,
        status: _status(row['status']!),
        accessTier: _accessTier(row['access_tier']!),
        difficulty: _difficulty(row['difficulty']!),
        safetyReviewStatus: _safety(row['safety_review_status']!),
        translations: {
          'en': LocalizedExerciseContent(
            name: row['name_en']!,
            description: row['description_en'],
          ),
          'ar': LocalizedExerciseContent(
            name: row['name_ar']!,
            description: row['description_ar'],
          ),
        },
        classification: ExerciseClassification(
          category: row['category']!,
          bodyAreas: _keys(row['body_areas']),
          equipment: _keys(row['equipment']),
          positions: _keys(row['positions']),
          goals: _keys(row['goals']),
          contexts: _keys(row['contexts']),
        ),
        providerMappings: [
          ProviderExerciseMapping(
            providerKey: row['provider']!,
            sourceExerciseId: row['source_exercise_id']!,
          ),
        ],
      );
    } on ArgumentError {
      issues.add(
        _issue(
          'invalid_exercise_value',
          location,
          'An enum or CSV value is invalid',
        ),
      );
      return null;
    }
  }

  Future<MediaAsset?> _mediaFromRow(
    Directory input,
    Map<String, String> row,
    String location,
    List<ImportIssue> issues,
  ) async {
    const required = [
      'media_id',
      'raha_exercise_id',
      'provider',
      'source_exercise_id',
      'source_filename',
      'type',
      'delivery_file',
      'mime_type',
      'sha256',
      'preferred',
      'status',
    ];
    if (!_required(row, required, location, issues)) return null;
    if (_blank(row['license_reference'])) {
      issues.add(
        _issue(
          'missing_license_reference',
          location,
          'Every media asset needs an internal license reference',
        ),
      );
      return null;
    }
    final delivery = File('${input.path}/media/${row['delivery_file']}');
    final source = File('${input.path}/media/${row['source_filename']}');
    if (!await delivery.exists() || !await source.exists()) {
      issues.add(
        _issue(
          'missing_media_file',
          location,
          'Source and delivery media files must exist',
        ),
      );
      return null;
    }
    final bytes = await delivery.readAsBytes();
    if (!_looksLikeMedia(bytes, row['type']!)) {
      issues.add(
        _issue(
          'corrupt_media',
          location,
          'Media header or GIF trailer is invalid',
        ),
      );
      return null;
    }
    if (_sha256(bytes) != row['sha256']) {
      issues.add(
        _issue(
          'checksum_mismatch',
          location,
          'Delivery file SHA-256 differs from authoring metadata',
        ),
      );
      return null;
    }
    try {
      return MediaAsset(
        id: row['media_id']!,
        exerciseId: row['raha_exercise_id']!,
        type: _mediaType(row['type']!),
        mimeType: row['mime_type']!,
        deliveryFileName: row['delivery_file']!,
        checksumSha256: row['sha256']!,
        status: _status(row['status']!),
        isPreferred: row['preferred'] == 'true',
        providerKey: row['provider'],
        sourceExerciseId: row['source_exercise_id'],
        sourceFileName: row['source_filename'],
        variant: row['variant'],
        width: _integer(row['width']),
        height: _integer(row['height']),
        durationMs: _integer(row['duration_ms']),
      );
    } on ArgumentError {
      issues.add(
        _issue(
          'invalid_media_value',
          location,
          'An enum or numeric CSV value is invalid',
        ),
      );
      return null;
    } on FormatException {
      issues.add(
        _issue(
          'invalid_media_value',
          location,
          'An enum or numeric CSV value is invalid',
        ),
      );
      return null;
    }
  }

  Routine? _routineFromJson(
    Object? value,
    String location,
    List<ImportIssue> issues,
  ) {
    if (value is! Map) {
      issues.add(
        _issue('invalid_routine', location, 'Routine must be an object'),
      );
      return null;
    }
    try {
      return Routine.fromJson(Map<String, Object?>.from(value));
    } on Object {
      issues.add(
        _issue(
          'invalid_routine',
          location,
          'Routine does not match the authored schema',
        ),
      );
      return null;
    }
  }

  void _addValidationIssues(
    ContentValidationResult result,
    List<ImportIssue> issues,
  ) {
    for (final error in result.errors) {
      issues.add(
        _issue(error.code.name, error.subject, 'Rejected by ContentValidator'),
      );
    }
  }
}

final class ImportResult {
  const ImportResult({
    required this.exercises,
    required this.mediaAssets,
    required this.routines,
    required this.issues,
  });
  final List<Exercise> exercises;
  final List<MediaAsset> mediaAssets;
  final List<Routine> routines;
  final List<ImportIssue> issues;
  bool get isSuccess => issues.isEmpty;
  Map<String, Object?> toJson() => {
    'status': isSuccess ? 'valid' : 'quarantined',
    'exerciseCount': exercises.length,
    'mediaAssetCount': mediaAssets.length,
    'routineCount': routines.length,
    'quarantine': issues.map((issue) => issue.toJson()).toList(),
  };
}

final class ImportIssue {
  const ImportIssue(this.code, this.subject, this.message);
  final String code;
  final String subject;
  final String message;
  Map<String, String> toJson() => {
    'code': code,
    'subject': subject,
    'message': message,
  };
  static int compare(ImportIssue a, ImportIssue b) =>
      '${a.code}\u0000${a.subject}'.compareTo('${b.code}\u0000${b.subject}');
}

ImportIssue _issue(String code, String subject, String message) =>
    ImportIssue(code, subject, message);
bool _blank(String? value) => value == null || value.trim().isEmpty;
bool _required(
  Map<String, String> row,
  List<String> fields,
  String location,
  List<ImportIssue> issues,
) {
  final missing = fields.where((field) => _blank(row[field])).toList();
  if (missing.isEmpty) return true;
  issues.add(
    _issue(
      'missing_required_field',
      location,
      'Missing: ${missing.join(', ')}',
    ),
  );
  return false;
}

Set<String> _keys(String? value) =>
    (value ?? '').split('|').where((value) => value.isNotEmpty).toSet();
int? _integer(String? value) => _blank(value) ? null : int.parse(value!);
ContentStatus _status(String value) => ContentStatus.values.byName(value);
AccessTier _accessTier(String value) => AccessTier.values.byName(value);
DifficultyLevel _difficulty(String value) =>
    DifficultyLevel.values.byName(value);
SafetyReviewStatus _safety(String value) =>
    SafetyReviewStatus.values.byName(value);
MediaType _mediaType(String value) => MediaType.values.byName(value);

List<String> _csvLine(String line) {
  final values = <String>[];
  var value = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        value.write(char);
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (char == ',' && !quoted) {
      values.add(value.toString());
      value = StringBuffer();
    } else {
      value.write(char);
    }
  }
  values.add(value.toString());
  return values;
}

bool _looksLikeMedia(Uint8List bytes, String type) {
  if (type == 'video') {
    return bytes.length >= 12 &&
        ascii.decode(bytes.sublist(4, 8), allowInvalid: true) == 'ftyp';
  }
  if (type == 'animation') {
    return bytes.length >= 7 &&
        (ascii.decode(bytes.sublist(0, 6), allowInvalid: true) == 'GIF87a' ||
            ascii.decode(bytes.sublist(0, 6), allowInvalid: true) ==
                'GIF89a') &&
        bytes.last == 0x3b;
  }
  return bytes.isNotEmpty;
}

Future<void> _writeJson(File file, Object? value) async => file.writeAsString(
  '${const JsonEncoder.withIndent('  ').convert(_sortJson(value))}\n',
);
Object? _sortJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _sortJson(value[key])};
  }
  if (value is Iterable) return value.map(_sortJson).toList();
  return value;
}

// Small dependency-free SHA-256 implementation for content integrity checks.
String _sha256(Uint8List input) {
  const k = [
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];
  final data = BytesBuilder()
    ..add(input)
    ..addByte(0x80);
  while (data.length % 64 != 56) {
    data.addByte(0);
  }
  final bits = input.length * 8;
  for (var i = 7; i >= 0; i--) {
    data.addByte((bits >> (i * 8)) & 255);
  }
  var h0 = 0x6a09e667,
      h1 = 0xbb67ae85,
      h2 = 0x3c6ef372,
      h3 = 0xa54ff53a,
      h4 = 0x510e527f,
      h5 = 0x9b05688c,
      h6 = 0x1f83d9ab,
      h7 = 0x5be0cd19;
  final bytes = data.toBytes();
  int rotr(int x, int n) => (x >>> n) | (x << (32 - n));
  for (var offset = 0; offset < bytes.length; offset += 64) {
    final w = List<int>.filled(64, 0);
    for (var i = 0; i < 16; i++) {
      w[i] =
          (bytes[offset + i * 4] << 24) |
          (bytes[offset + i * 4 + 1] << 16) |
          (bytes[offset + i * 4 + 2] << 8) |
          bytes[offset + i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3),
          s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }
    var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
    for (var i = 0; i < 64; i++) {
      final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25),
          ch = (e & f) ^ ((~e) & g),
          t1 = (h + s1 + ch + k[i] + w[i]) & 0xffffffff,
          s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22),
          maj = (a & b) ^ (a & c) ^ (b & c),
          t2 = (s0 + maj) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + t1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & 0xffffffff;
    }
    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + h) & 0xffffffff;
  }
  return [
    h0,
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    h7,
  ].map((v) => v.toUnsigned(32).toRadixString(16).padLeft(8, '0')).join();
}
