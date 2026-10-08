import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
import { PlanarApp } from "@/components/planar-app";

export default async function Home() {
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) return <Setup />;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  return <PlanarApp userId={user.id} email={user.email ?? "Owner"} />;
}
function Setup() { return <main className="setup"><div className="brand-mark">P</div><p className="eyebrow">Planar setup</p><h1>Your calm place to plan what matters.</h1><p>Connect a Supabase project to begin. Copy <code>.env.example</code> to <code>.env.local</code>, add the project URL and anon key, then apply the migration.</p><a className="button" href="https://supabase.com/dashboard" rel="noreferrer">Open Supabase</a></main> }
