# #!/bin/bash

# # Stop script on error
# set -e

# APP_NAME="frontend"

# echo "🚀 Setting up Next.js frontend..."

# # 1. Create Next.js app with App Router, TS, Tailwind
# npx create-next-app@latest $APP_NAME --typescript --tailwind --eslint --app --src-dir --no-import-alias --use-npm

# cd $APP_NAME

# # 2. Install frontend dependencies
# echo "📦 Installing dependencies..."
# npm install js-cookie react-hook-form zod @hookform/resolvers @headlessui/react @heroicons/react clsx @tanstack/react-query

# # 3. Create utils for API calls
# mkdir -p src/utils
# cat <<EOF > src/utils/fetchClient.ts
# import Cookies from "js-cookie";

# export async function fetchWithAuth(path: string, options: RequestInit = {}) {
#   const token = Cookies.get("token");
#   const headers = {
#     ...options.headers,
#     Authorization: token ? \`Bearer \${token}\` : "",
#     "Content-Type": "application/json"
#   };

#   const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}\${path}\`, {
#     ...options,
#     headers,
#   });

#   if (!res.ok) throw new Error("API error");
#   return res.json();
# }
# EOF

# # 4. Create Header component
# mkdir -p src/components
# cat <<EOF > src/components/Header.tsx
# "use client";
# import Link from "next/link";

# export default function Header() {
#   return (
#     <header className="p-4 bg-gray-200 flex justify-end gap-4">
#       <Link href="/auth/login" className="text-blue-600">Login</Link>
#       <Link href="/auth/register" className="text-green-600">Register</Link>
#       <Link href="/dashboard" className="text-purple-600">Dashboard</Link>
#     </header>
#   );
# }
# EOF

# # 5. Update Root Layout
# cat <<EOF > src/app/layout.tsx
# import Header from "@/components/Header";

# export default function RootLayout({ children }: { children: React.ReactNode }) {
#   return (
#     <html lang="en">
#       <body>
#         <Header />
#         <main>{children}</main>
#       </body>
#     </html>
#   );
# }
# EOF

# # 6. Create Login page
# mkdir -p src/app/auth/login
# cat <<EOF > src/app/auth/login/page.tsx
# "use client";
# import { useForm } from "react-hook-form";
# import { z } from "zod";
# import { zodResolver } from "@hookform/resolvers/zod";
# import Cookies from "js-cookie";
# import { useState } from "react";

# const schema = z.object({
#   email: z.string().email(),
#   password: z.string().min(6),
# });

# export default function LoginPage() {
#   const { register, handleSubmit, formState: { errors } } = useForm({ resolver: zodResolver(schema) });
#   const [loading, setLoading] = useState(false);

#   const onSubmit = async (data: any) => {
#     setLoading(true);
#     try {
#       const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}/auth/login\`, {
#         method: "POST",
#         headers: { "Content-Type": "application/json" },
#         body: JSON.stringify(data),
#       });
#       const result = await res.json();
#       if (res.ok) {
#         Cookies.set("token", result.token || "dummy-token");
#         alert("Login successful!");
#       } else {
#         alert(result.message || "Login failed");
#       }
#     } catch (err) {
#       console.error(err);
#       alert("Something went wrong");
#     } finally {
#       setLoading(false);
#     }
#   };

#   return (
#     <div className="flex justify-center items-center h-screen bg-gray-100">
#       <form onSubmit={handleSubmit(onSubmit)} className="bg-white p-6 rounded shadow-md w-96">
#         <h2 className="text-xl font-bold mb-4">Login</h2>
#         <input {...register("email")} placeholder="Email" className="border p-2 w-full mb-2 rounded"/>
#         {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
#         <input type="password" {...register("password")} placeholder="Password" className="border p-2 w-full mb-2 rounded"/>
#         {errors.password && <p className="text-red-500 text-sm">{errors.password.message}</p>}
#         <button disabled={loading} className="bg-blue-600 text-white px-4 py-2 rounded w-full">
#           {loading ? "Logging in..." : "Login"}
#         </button>
#       </form>
#     </div>
#   );
# }
# EOF

# # 7. Create Register page
# mkdir -p src/app/auth/register
# cat <<EOF > src/app/auth/register/page.tsx
# "use client";
# import { useForm } from "react-hook-form";
# import { z } from "zod";
# import { zodResolver } from "@hookform/resolvers/zod";
# import { useState } from "react";

# const schema = z.object({
#   name: z.string().min(2),
#   email: z.string().email(),
#   password: z.string().min(6),
# });

# export default function RegisterPage() {
#   const { register, handleSubmit, formState: { errors } } = useForm({ resolver: zodResolver(schema) });
#   const [loading, setLoading] = useState(false);

#   const onSubmit = async (data: any) => {
#     setLoading(true);
#     try {
#       const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}/auth/register\`, {
#         method: "POST",
#         headers: { "Content-Type": "application/json" },
#         body: JSON.stringify(data),
#       });
#       const result = await res.json();
#       if (res.ok) {
#         alert("Registration successful!");
#       } else {
#         alert(result.message || "Registration failed");
#       }
#     } catch (err) {
#       console.error(err);
#       alert("Something went wrong");
#     } finally {
#       setLoading(false);
#     }
#   };

#   return (
#     <div className="flex justify-center items-center h-screen bg-gray-100">
#       <form onSubmit={handleSubmit(onSubmit)} className="bg-white p-6 rounded shadow-md w-96">
#         <h2 className="text-xl font-bold mb-4">Register</h2>
#         <input {...register("name")} placeholder="Name" className="border p-2 w-full mb-2 rounded"/>
#         {errors.name && <p className="text-red-500 text-sm">{errors.name.message}</p>}
#         <input {...register("email")} placeholder="Email" className="border p-2 w-full mb-2 rounded"/>
#         {errors.email && <p className="text-red-500 text-sm">{errors.email.message}</p>}
#         <input type="password" {...register("password")} placeholder="Password" className="border p-2 w-full mb-2 rounded"/>
#         {errors.password && <p className="text-red-500 text-sm">{errors.password.message}</p>}
#         <button disabled={loading} className="bg-green-600 text-white px-4 py-2 rounded w-full">
#           {loading ? "Registering..." : "Register"}
#         </button>
#       </form>
#     </div>
#   );
# }
# EOF

# # 8. Create protected Dashboard page
# mkdir -p src/app/dashboard
# cat <<EOF > src/app/dashboard/page.tsx
# "use client";
# import { useEffect, useState } from "react";
# import Cookies from "js-cookie";
# import { useRouter } from "next/navigation";

# export default function DashboardPage() {
#   const router = useRouter();
#   const [loading, setLoading] = useState(true);

#   useEffect(() => {
#     const token = Cookies.get("token");
#     if (!token) {
#       alert("You must login first!");
#       router.push("/auth/login");
#     } else {
#       setLoading(false);
#     }
#   }, [router]);

#   if (loading) return <p className="p-4">Checking authentication...</p>;

#   return (
#     <div className="p-6">
#       <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
#       <p>Welcome! You are successfully logged in.</p>
#       <button
#         className="mt-4 bg-red-600 text-white px-4 py-2 rounded"
#         onClick={() => {
#           Cookies.remove("token");
#           router.push("/auth/login");
#         }}
#       >
#         Logout
#       </button>
#     </div>
#   );
# }
# EOF

# echo "✅ Frontend setup complete!"
# echo "Run the frontend: cd $APP_NAME && npm run dev"
# echo "Access pages:"
# echo "- Login: http://localhost:3000/auth/login"
# echo "- Register: http://localhost:3000/auth/register"
# echo "- Dashboard (protected): http://localhost:3000/dashboard"


# npm run dev

#!/bin/bash
set -e

echo "==== Setting up Next.js Frontend ===="

FRONTEND_DIR="frontend"

# 1. Create Next.js app
npx create-next-app@latest $FRONTEND_DIR --typescript --tailwind --eslint --app --src-dir --no-import-alias --use-npm
cd $FRONTEND_DIR

# 2. Install dependencies
npm install js-cookie react-hook-form zod @hookform/resolvers @headlessui/react @heroicons/react clsx @tanstack/react-query

# 3. Create utils/fetchClient.ts
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

  const res = await fetch(\`\${process.env.NEXT_PUBLIC_API_URL}\${path}\`, { ...options, headers });
  if (!res.ok) throw new Error("API error");
  return res.json();
}
EOF

# 4. Header component
mkdir -p src/components
cat <<EOF > src/components/Header.tsx
"use client";
import Link from "next/link";
import Cookies from "js-cookie";
import { useState, useEffect } from "react";

export default function Header() {
  const [loggedIn, setLoggedIn] = useState(false);

  useEffect(() => setLoggedIn(!!Cookies.get("token")), []);

  return (
    <header className="p-4 bg-gray-200 flex justify-end gap-4">
      {!loggedIn && <Link href="/auth/login" className="text-blue-600">Login</Link>}
      {!loggedIn && <Link href="/auth/register" className="text-green-600">Register</Link>}
      {loggedIn && <Link href="/dashboard" className="text-purple-600">Dashboard</Link>}
    </header>
  );
}
EOF

# 5. Root Layout
cat <<EOF > src/app/layout.tsx
import Header from "@/components/Header";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Header />
        <main>{children}</main>
      </body>
    </html>
  );
}
EOF

# 6. Login page
mkdir -p src/app/auth/login
cat <<'EOF' > src/app/auth/login/page.tsx
"use client";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useState } from "react";

const schema = z.object({ email: z.string().email(), password: z.string().min(6) });

export default function LoginPage() {
  const { register, handleSubmit, formState: { errors } } = useForm({ resolver: zodResolver(schema) });
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const onSubmit = async (data: any) => {
    setLoading(true);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      if (res.ok) {
        Cookies.set("token", result.token);
        alert("Login successful!");
        router.push("/dashboard");
      } else alert(result.message || "Login failed");
    } catch (err) { console.error(err); alert("Something went wrong"); }
    finally { setLoading(false); }
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

# 7. Register page
mkdir -p src/app/auth/register
cat <<'EOF' > src/app/auth/register/page.tsx
"use client";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useState } from "react";

const schema = z.object({ name: z.string().min(2), email: z.string().email(), password: z.string().min(6) });

export default function RegisterPage() {
  const { register, handleSubmit, formState: { errors } } = useForm({ resolver: zodResolver(schema) });
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const onSubmit = async (data: any) => {
    setLoading(true);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/auth/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const result = await res.json();
      if (res.ok) { alert("Registration successful!"); router.push("/auth/login"); }
      else alert(result.message || "Registration failed");
    } catch (err) { console.error(err); alert("Something went wrong"); }
    finally { setLoading(false); }
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

# 8. Dashboard page
mkdir -p src/app/dashboard
cat <<'EOF' > src/app/dashboard/page.tsx
"use client";
import { useEffect, useState } from "react";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { fetchWithAuth } from "@/utils/fetchClient";

export default function DashboardPage() {
  const router = useRouter();
  const [user, setUser] = useState<{name: string; email: string} | null>(null);

  useEffect(() => {
    const token = Cookies.get("token");
    if (!token) return router.push("/auth/login");

    fetchWithAuth("/auth/me")
      .then(setUser)
      .catch(() => { Cookies.remove("token"); router.push("/auth/login"); });
  }, [router]);

  if (!user) return <p className="p-4">Loading...</p>;

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Dashboard</h1>
      <p>Welcome, {user.name} ({user.email})</p>
      <button className="mt-4 bg-red-600 text-white px-4 py-2 rounded" onClick={() => { Cookies.remove("token"); router.push("/auth/login"); }}>
        Logout
      </button>
    </div>
  );
}
EOF


# Create .env file
cat <<EOL > .env
NEXT_PUBLIC_API_URL=http://127.0.0.1:5000
EOL

echo ".env file created in frontend with API URL"


echo "==== Frontend Setup Complete ===="
echo "Run frontend: cd frontend && npm run dev"
echo "Pages:"
echo "- Login: http://localhost:3000/auth/login"
echo "- Register: http://localhost:3000/auth/register"
echo "- Dashboard: http://localhost:3000/dashboard (requires login)"
npm run dev
