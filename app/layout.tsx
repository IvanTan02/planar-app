import type { Metadata, Viewport } from "next";
import "./globals.css";
import { ServiceWorker } from "@/components/service-worker";

export const metadata: Metadata = { title: "Planar", description: "Plan tomorrow with intention.", manifest: "/manifest.webmanifest", appleWebApp: { capable: true, title: "Planar" } };
export const viewport: Viewport = { themeColor: [ { media: "(prefers-color-scheme: light)", color: "#f5f8ff" }, { media: "(prefers-color-scheme: dark)", color: "#071120" } ] };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en" suppressHydrationWarning><head><script dangerouslySetInnerHTML={{__html:`try{const t=localStorage.getItem('planar-theme')||'system';document.documentElement.dataset.theme=t}catch{}`}} /></head><body>{children}<ServiceWorker/></body></html>;
}
