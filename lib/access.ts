import "server-only";

const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type UserIdListName = "PLANAR_ALLOWED_USER_IDS" | "PLANAR_BLOCKED_USER_IDS";

function userIds(name: UserIdListName) {
  const ids = (process.env[name] ?? "")
    .split(",")
    .map((id) => id.trim())
    .filter(Boolean);

  const invalid = ids.find((id) => !uuidPattern.test(id));
  if (invalid) throw new Error(`${name} contains an invalid UUID.`);
  return new Set(ids);
}

export function accessPolicy() {
  const allowed = userIds("PLANAR_ALLOWED_USER_IDS");
  const blocked = userIds("PLANAR_BLOCKED_USER_IDS");
  const overlap = [...allowed].find((id) => blocked.has(id));

  if (overlap) {
    throw new Error(
      "A user cannot appear in both PLANAR_ALLOWED_USER_IDS and PLANAR_BLOCKED_USER_IDS.",
    );
  }

  return {
    signupEnabled: process.env.PLANAR_SIGNUP_ENABLED === "true",
    restricted: allowed.size > 0 || blocked.size > 0,
    allows(userId: string) {
      return !blocked.has(userId) && (allowed.size === 0 || allowed.has(userId));
    },
  };
}

export function siteUrl() {
  const configured = process.env.NEXT_PUBLIC_SITE_URL?.trim();
  return (configured || "http://localhost:3000").replace(/\/$/, "");
}
