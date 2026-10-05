import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../home_providers.dart';
import 'exercise_artwork.dart';

class HomeBodyAreas extends StatelessWidget {
  const HomeBodyAreas({
    super.key,
    required this.scale,
    required this.onAreaSelected,
  });

  final double scale;
  final ValueChanged<String> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 146 + 36 * (scale - 1),
      child: ListView.separated(
        key: const Key('home_areas'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: areaAssets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final area = areaAssets.keys.elementAt(index);
          return SizedBox(
            width: 112,
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                key: Key('home_area_$area'),
                borderRadius: BorderRadius.circular(22),
                onTap: () => onAreaSelected(area),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ExerciseArtwork(area: area, size: 82),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Text(
                          areaLabel(s, area),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String areaLabel(AppLocalizations s, String area) => switch (area) {
  'neck' => s.checkInAreaNeck,
  'shoulders' => s.checkInAreaShoulders,
  'upper_back' => s.checkInAreaUpperBack,
  'lower_back' => s.checkInAreaLowerBack,
  'hips' => s.checkInAreaHips,
  'knees' => s.checkInAreaKnees,
  _ => s.checkInAreaFullBody,
};
