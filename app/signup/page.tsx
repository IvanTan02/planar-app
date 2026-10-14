import { redirect } from "next/navigation";
import { signup } from "./actions";
import { accessPolicy } from "@/lib/access";

export default async function SignupPage({ searchParams }: { searchParams: Promise<{ error?: string }> }) {
  if (!accessPolicy().signupEnabled) redirect("/login?error=" + encodeURIComponent("Signup is disabled for this deployment."));
  const { error } = await searchParams;
  return <main className="auth-page"><section className="auth-copy"><div className="brand-mark">P</div><p className="eyebrow">Join Planar</p><h1>Make tomorrow feel lighter.</h1><p>Your boards, tasks, goals, and plans remain private to your account.</p></section><form className="auth-card" action={signup}><h2>Create account</h2><p>Start with a private workspace of your own.</p><label>Email<input name="email" type="email" autoComplete="email" required/></label><label>Password<input name="password" type="password" autoComplete="new-password" minLength={8} required/></label>{error&&<p className="error" role="alert">{error}</p>}<button className="button">Create account</button><a className="auth-link" href="/login">Already have an account? Sign in</a></form></main>
}
