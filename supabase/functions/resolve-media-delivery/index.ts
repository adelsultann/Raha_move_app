import { createClient } from "npm:@supabase/supabase-js@2";

const responseHeaders = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

function json(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: responseHeaders });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return json(405, { code: "method_not_allowed" });

  const authorization = request.headers.get("authorization");
  if (!authorization) return json(401, { code: "authentication_required" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return json(503, { code: "resolver_unavailable" });
  }

  let body: { delivery_reference?: unknown };
  try {
    body = await request.json();
  } catch {
    return json(400, { code: "invalid_request" });
  }
  if (
    typeof body.delivery_reference !== "string" ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
      body.delivery_reference,
    )
  ) {
    return json(400, { code: "invalid_reference" });
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser();
  if (userError || !userData.user) {
    return json(401, { code: "authentication_required" });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: media, error: mediaError } = await admin
    .from("media_assets")
    .select(
      "storage_bucket,storage_key,status,updated_at,exercises!inner(status,access_tier,safety_approved_at)",
    )
    .eq("delivery_reference", body.delivery_reference)
    .eq("status", "published")
    .single();

  const exercise = Array.isArray(media?.exercises)
    ? media?.exercises[0]
    : media?.exercises;
  if (
    mediaError ||
    !media ||
    !exercise ||
    exercise.status !== "published" ||
    !exercise.safety_approved_at ||
    media.storage_bucket !== "exercise-media"
  ) {
    return json(404, { code: "media_unavailable" });
  }

  if (exercise.access_tier !== "free") {
    const { data: entitlement, error: entitlementError } = await admin
      .from("user_entitlements")
      .select("is_active,expires_at")
      .eq("user_id", userData.user.id)
      .eq("entitlement_key", exercise.access_tier)
      .eq("is_active", true)
      .maybeSingle();
    const expired = entitlement?.expires_at &&
      new Date(entitlement.expires_at).getTime() <= Date.now();
    if (entitlementError || !entitlement || expired) {
      return json(403, { code: "entitlement_required" });
    }
  }

  const lifetimeSeconds = 300;
  const { data: signed, error: signedError } = await admin.storage
    .from(media.storage_bucket)
    .createSignedUrl(media.storage_key, lifetimeSeconds);
  if (signedError || !signed?.signedUrl) {
    return json(503, { code: "delivery_unavailable" });
  }

  return json(200, {
    signed_url: signed.signedUrl,
    expires_at: new Date(Date.now() + lifetimeSeconds * 1000).toISOString(),
  });
});
