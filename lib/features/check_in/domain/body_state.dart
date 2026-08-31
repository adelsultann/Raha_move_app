/// The closed MVP body-state vocabulary for the daily check-in.
///
/// Keys are stable, language-neutral, and match the `body_state` values accepted
/// by the local record and the Supabase `check_ins` constraint. See the RAHA-040
/// decision note: the design's "a little stiff / very stiff" gradation is
/// deferred, so stiffness is a single `stiff` value.
enum BodyState {
  comfortable('comfortable'),
  stiff('stiff'),
  tired('tired'),
  tense('tense');

  const BodyState(this.key);

  /// The stable key persisted and emitted on the wire, never a localized label.
  final String key;

  static BodyState fromKey(String key) =>
      values.firstWhere((state) => state.key == key);
}
