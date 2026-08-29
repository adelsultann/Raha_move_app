#!/usr/bin/env bash
set -euo pipefail

# Local/disposable only. Do not provide a remote project ref or production URL.
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
db_container="supabase_db_Raha_move_app"
postgres_image="supabase/postgres:15.8.1.060"
psql_local=(docker run --rm -v "$root:/workspace:ro" --network "container:$db_container" "$postgres_image" psql "postgresql://postgres:postgres@127.0.0.1:5432/postgres" -v ON_ERROR_STOP=1)

npx --yes supabase db reset
"${psql_local[@]}" -f /workspace/supabase/tests/raha_022_acl_gate.sql
"${psql_local[@]}" -f /workspace/supabase/tests/raha_022_authorization.sql

upgrade_db="raha_022_upgrade_gate"
docker exec "$db_container" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "drop database if exists ${upgrade_db};"
docker exec "$db_container" psql -U postgres -d postgres -v ON_ERROR_STOP=1 -c "create database ${upgrade_db} template template0;"
trap 'docker exec "$db_container" psql -U postgres -d postgres -c "drop database if exists raha_022_upgrade_gate;" >/dev/null' EXIT
docker run --rm -v "$root:/workspace:ro" --network "container:$db_container" "$postgres_image" psql "postgresql://postgres:postgres@127.0.0.1:5432/${upgrade_db}" -v ON_ERROR_STOP=1 -f /workspace/supabase/tests/raha_022_upgrade.sql
