import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { PlanarApp } from "@/components/planar-app";

export const dynamic = "force-dynamic";

export default async function Home() {
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY) return <Setup />;
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getClaims();
  const claims = data?.claims;
  if (!claims?.sub) {
    const reason = error?.message ?? "Your session could not be verified.";
    redirect("/login?error=" + encodeURIComponent(reason));
  }
  const email = typeof claims.email === "string" ? claims.email : "Owner";
  return <PlanarApp userId={claims.sub} email={email} />;
}
function Setup() { return <main className="setup"><div className="brand-mark">P</div><p className="eyebrow">Planar setup</p><h1>Your calm place to plan what matters.</h1><p>Connect a Supabase project to begin. Copy <code>.env.example</code> to <code>.env.local</code>, add the project URL and publishable key, then apply the migration.</p><a className="button" href="https://supabase.com/dashboard" rel="noreferrer">Open Supabase</a></main> }
