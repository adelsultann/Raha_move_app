const jsonHeaders = { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" };
const alertTypes = new Set(["overdue_requests", "worker_failed", "worker_stale"]);

function response(status: number, code: string): Response {
  return new Response(JSON.stringify({ code }), { status, headers: jsonHeaders });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") return response(405, "method_not_allowed");
  const dispatchToken = Deno.env.get("ACCOUNT_DELETION_ALERT_DISPATCH_TOKEN");
  const webhookUrl = Deno.env.get("ACCOUNT_DELETION_ALERT_WEBHOOK_URL");
  const webhookToken = Deno.env.get("ACCOUNT_DELETION_ALERT_WEBHOOK_TOKEN");
  if (!dispatchToken || !webhookUrl || !webhookToken) return response(503, "alert_delivery_unavailable");
  if (request.headers.get("authorization") !== `Bearer ${dispatchToken}`) return response(401, "authentication_required");
  try {
    if (new URL(webhookUrl).protocol !== "https:") return response(503, "alert_delivery_unavailable");
  } catch { return response(503, "alert_delivery_unavailable"); }

  let body: { version?: unknown; observed_at?: unknown; alert_types?: unknown };
  try { body = await request.json(); } catch { return response(400, "invalid_request"); }
  if (
    body.version !== "raha_064_deletion_alert_v1" ||
    typeof body.observed_at !== "string" ||
    !Array.isArray(body.alert_types) || body.alert_types.length === 0 ||
    body.alert_types.some((value) => typeof value !== "string" || !alertTypes.has(value))
  ) return response(400, "invalid_alert_payload");

  // Construct a new allowlisted body. Never forward unknown input fields.
  const outbound = {
    event: "raha.account_deletion_deadline_alert",
    version: body.version,
    observed_at: body.observed_at,
    alert_types: body.alert_types,
  };
  try {
    const delivery = await fetch(webhookUrl, {
      method: "POST",
      headers: { "content-type": "application/json", "authorization": `Bearer ${webhookToken}` },
      body: JSON.stringify(outbound),
    });
    if (!delivery.ok) return response(502, "alert_delivery_failed");
  } catch { return response(502, "alert_delivery_failed"); }
  return response(202, "alert_dispatched");
});
