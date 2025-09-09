#!/bin/bash

# Stop script on error
set -e

# Project name
APP_NAME="frontend"

echo "🚀 Setting up Next.js frontend..."

# 1. Create Next.js app with App Router, TS, Tailwind
npx create-next-app@latest $APP_NAME --typescript --tailwind --eslint --app --src-dir --no-import-alias --use-npm

cd $APP_NAME

# 2. Install frontend dependencies
echo "📦 Installing dependencies..."
npm install js-cookie react-hook-form zod @headlessui/react @heroicons/react clsx @tanstack/react-query

# 3. Create utils for API calls
mkdir -p src/utils
cat <<EOF > src/utils/fetchClient.ts
import Cookies from "js-cookie";

export async function fetchWithAuth(path: string, options: RequestInit = {}) {
  const token = Cookies.get("token");
  const headers = {
    ...options.headers,
    Authorization: token ? \`Bearer \${token}\` : "",
    "Content-Type": "application/json"
  };

  const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}\${path}\`, {
    ...options,
    headers,
  });

  if (!res.ok) throw new Error("API error");
  return res.json();
}
EOF

# 4. Add Login and Register pages
mkdir -p src/app/auth/login src/app/auth/register

# Login page
cat <<'EOF' > src/app/auth/login/page.tsx
"use client";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import Cookies from "js-cookie";
import { useState } from "react";

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export default function LoginPage() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  });
  const [loading, setLoading] = useState(false);

  const onSubmit = async (data: any) => {
    setLoading(true);
    try {
      const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}/auth/login\`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      if (res.ok) {
        Cookies.set("token", result.token);
        alert("Login successful!");
      } else {
        alert(result.message || "Login failed");
      }
    } catch (err) {
      console.error(err);
      alert("Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex justify-center items-center h-screen bg-gray-100">
      <form onSubmit={handleSubmit(onSubmit)} className="bg-white p-6 rounded shadow-md w-96">
        <h2 className="text-xl font-bold mb-4">Login</h2>
        <input {...register("email")} placeholder="Email" className="border p-2 w-full mb-2 rounded"/>
        {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
        <input type="password" {...register("password")} placeholder="Password" className="border p-2 w-full mb-2 rounded"/>
        {errors.password && <p className="text-red-500 text-sm">{errors.password.message}</p>}
        <button disabled={loading} className="bg-blue-600 text-white px-4 py-2 rounded w-full">
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>
    </div>
  );
}
EOF

# Register page
cat <<'EOF' > src/app/auth/register/page.tsx
"use client";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";

const schema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
});

export default function RegisterPage() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema),
  });
  const [loading, setLoading] = useState(false);

  const onSubmit = async (data: any) => {
    setLoading(true);
    try {
      const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}/auth/register\`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      if (res.ok) {
        alert("Registration successful!");
      } else {
        alert(result.message || "Registration failed");
      }
    } catch (err) {
      console.error(err);
      alert("Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex justify-center items-center h-screen bg-gray-100">
      <form onSubmit={handleSubmit(onSubmit)} className="bg-white p-6 rounded shadow-md w-96">
        <h2 className="text-xl font-bold mb-4">Register</h2>
        <input {...register("name")} placeholder="Name" className="border p-2 w-full mb-2 rounded"/>
        {errors.name && <p className="text-red-500 text-sm">{errors.name.message}</p>}
        <input {...register("email")} placeholder="Email" className="border p-2 w-full mb-2 rounded"/>
        {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
        <input type="password" {...register("password")} placeholder="Password" className="border p-2 w-full mb-2 rounded"/>
        {errors.password && <p className="text-red-500 text-sm">{errors.password.message}</p>}
        <button disabled={loading} className="bg-green-600 text-white px-4 py-2 rounded w-full">
          {loading ? "Registering..." : "Register"}
        </button>
      </form>
    </div>
  );
}
EOF

echo "✅ Frontend setup complete!"
