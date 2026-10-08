import { login } from "@/app/login/actions";

export function LoginForm({ error }: { error?: string }) {
  return (
    <form className="auth-card" action={login}>
      <h2>Private sign in</h2>
      <p>Access is limited to accounts provisioned by the owner.</p>
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
      <button className="button">Sign in</button>
    </form>
  );
}
