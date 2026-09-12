import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';

import '../application/gamification_providers.dart';
import '../domain/achievement_progress.dart';

/// Read-only server-achievement catalog. Locked badges invite comfortable,
/// personal exploration; they never compare the user with anyone else.
class AchievementProgressSection extends ConsumerWidget {
  const AchievementProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProgressProvider);
    final strings = AppLocalizations.of(context);
    return achievements.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(strings.achievementUnavailable, textAlign: TextAlign.center),
          TextButton(
            onPressed: () => ref.invalidate(achievementProgressProvider),
            child: Text(strings.retry),
          ),
        ],
      ),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                strings.achievementsTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            for (final achievement in items) ...[
              _AchievementTile(achievement: achievement),
              const SizedBox(height: 8),
            ],
            Text(
              strings.achievementsLockedInvitation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final AchievementProgress achievement;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final translation = achievement.translationFor(
      Localizations.localeOf(context).languageCode,
    );
    if (translation == null) return const SizedBox.shrink();
    final earned = achievement.isEarned;
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: earned
          ? strings.achievementEarnedSemantics(translation.title)
          : strings.achievementLockedSemantics(translation.title),
      child: Card(
        color: earned ? theme.colorScheme.primaryContainer : null,
        child: ListTile(
          leading: Icon(
            achievementIcon(achievement.iconKey),
            color: earned
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(translation.title),
          subtitle: Text(translation.description),
          trailing: Text(
            earned ? strings.achievementEarned : strings.achievementLocked,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

/// The server owns an app-independent key; presentation maps it to an
/// application-owned icon rather than accepting a remote URL or provider asset.
IconData achievementIcon(String key) => switch (key) {
  'first_step' => Icons.directions_walk_outlined,
  'gentle_habit' => Icons.spa_outlined,
  _ => Icons.workspace_premium_outlined,
};
