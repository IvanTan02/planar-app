import { login } from "@/app/login/actions";

export function LoginForm({ error, message, signupEnabled }: { error?: string; message?: string; signupEnabled: boolean }) {
  return (
    <form className="auth-card" action={login}>
      <h2>Private sign in</h2>
      <p>{signupEnabled ? "Sign in to your private workspace." : "Access is limited to approved accounts."}</p>
      <label>
        Email
        <input name="email" type="email" autoComplete="email" required />
      </label>
      <label>
        Password
        <input
          name="password"
          type="password"
          autoComplete="current-password"
          required
        />
      </label>
      {error && (
        <p className="error" role="alert">
          {error}
        </p>
      )}
      {message && <p className="auth-message" role="status">{message}</p>}
      <button className="button">Sign in</button>
      {signupEnabled && <a className="auth-link" href="/signup">New to Planar? Create an account</a>}
    </form>
  );
}
