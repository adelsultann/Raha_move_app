import 'package:flutter/material.dart';
import 'package:raha_move/app/localization/l10n/app_localizations.dart';
import 'package:raha_move/app/router/app_routes.dart';
import 'package:raha_move/features/today/domain/today_repository.dart';

import 'home_date_heading.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.recommendationsEnabled,
    required this.onBrowse,
    this.resume,
  });

  final bool recommendationsEnabled;
  final VoidCallback onBrowse;
  final TodayResumableRoutine? resume;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeDateHeading(date: DateTime.now()),
          const SizedBox(height: 12),
          Text(
            s.homeHeadline,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            s.homeSubtitle,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: Key(
              recommendationsEnabled ? 'start_check_in' : 'browse_routines',
            ),
            onPressed: recommendationsEnabled
                ? () => const CheckInRoute().push(context)
                : () => onBrowse(),
            icon: Icon(
              recommendationsEnabled
                  ? Icons.bolt_rounded
                  : Icons.search_rounded,
            ),
            label: Text(
              recommendationsEnabled
                  ? s.checkInStartTitle
                  : s.homeBrowseRoutines,
            ),
          ),
          if (resume case final resume?) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.play_circle_outline, color: colors.primary),
                title: Text(s.homeResume),
                subtitle: Text(resume.name ?? s.navigationHome),
                onTap: () => RoutinePlayerRoute(
                  routineId: resume.routineId,
                  sessionId: resume.sessionId,
                ).push(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
