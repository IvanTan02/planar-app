"use server";

import { redirect } from "next/navigation";
import { accessPolicy, siteUrl } from "@/lib/access";
import { createClient } from "@/lib/supabase/server";

export async function signup(formData: FormData) {
  if (!accessPolicy().signupEnabled) {
    redirect("/login?error=" + encodeURIComponent("Signup is disabled for this deployment."));
  }

  const email = formData.get("email");
  const password = formData.get("password");
  if (typeof email !== "string" || typeof password !== "string") {
    redirect("/signup?error=" + encodeURIComponent("Email and password are required."));
  }
  if (password.length < 8) {
    redirect("/signup?error=" + encodeURIComponent("Use at least 8 characters for your password."));
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: { emailRedirectTo: siteUrl() + "/auth/callback" },
  });

  if (error) redirect("/signup?error=" + encodeURIComponent(error.message));
  if (data.session) redirect("/");
  redirect("/login?message=" + encodeURIComponent("Check your email to confirm your account."));
}
