"use server";

import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export async function login(formData: FormData) {
  const email = formData.get("email");
  const password = formData.get("password");

  if (typeof email !== "string" || typeof password !== "string") {
    redirect("/login?error=Email%20and%20password%20are%20required");
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    redirect("/login?error=" + encodeURIComponent(error.message));
  }

  if (!data.session) {
    redirect(
      "/login?error=" +
        encodeURIComponent("Supabase accepted the login but returned no session."),
    );
  }

  const cookieStore = await cookies();
  const hasSessionCookie = cookieStore
    .getAll()
    .some(
      ({ name }) => name.startsWith("sb-") && name.includes("-auth-token"),
    );

  if (!hasSessionCookie) {
    redirect(
      "/login?error=" +
        encodeURIComponent(
          "Sign-in succeeded, but the session cookie was not written.",
        ),
    );
  }

  revalidatePath("/", "layout");
  redirect("/");
}
