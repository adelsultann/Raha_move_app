import '../../gen/assets.gen.dart';

/// Central sample for type-safe generated asset access.
abstract final class AppAssetCatalog {
  static String get brandMarkPath => Assets.logo.path;

  /// Bundled artwork remains available even when a routine has no cover media.
  static String routineArtwork(Set<String> bodyAreas) {
    final icons = Assets.categoriesIcons;
    if (bodyAreas.length != 1) return icons.fULLBODYCategoryIcon.path;
    return switch (bodyAreas.single) {
      'neck' => icons.nECKCategoryIcon.path,
      'shoulders' => icons.sHOULDERSCategoryIcon.path,
      'upper_back' => icons.pOSTURECategoryIcon.path,
      'lower_back' => icons.lowerBackCategoryIcon.path,
      'hips' => icons.hIPSCategoryIcon.path,
      'knees' => icons.kNEESCategoryIcon.path,
      _ => icons.fULLBODYCategoryIcon.path,
    };
  }
}
