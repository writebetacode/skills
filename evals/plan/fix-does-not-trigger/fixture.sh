#!/bin/sh
set -e
mkdir -p src/forms
cat > package.json <<'X'
{ "name": "shop", "private": true, "dependencies": { "zod": "3.22.4" } }
X
cat > src/forms/signup.ts <<'X'
import { z } from "zod";

export const SignupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(12),
});

export function parseSignup(input: unknown) {
  return SignupSchema.safeParse(input);
}
X
cat > src/forms/login.ts <<'X'
import { z } from "zod";

export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export function parseLogin(input: unknown) {
  return LoginSchema.safeParse(input);
}
X
