# RAHA-022 database deployment gate

Run `supabase/tests/run_raha_022_local_gates.sh` locally or in CI. It resets
only the local Docker stack, checks the final ACL allowlist, runs authorization
fixtures, and proves the 00300--00600 upgrade against a disposable database.

For a new shared environment, an operator must first disable public API/network
access (maintenance mode or an allowlist containing only the migration runner),
apply the complete migration baseline in one transaction where the platform
permits it, run `raha_022_acl_gate.sql` as the database owner, and only then
enable API traffic. A failed gate means API traffic remains disabled. Never use
these reset, drop-database, or test commands with a project ref, remote URL, or
production credentials.
