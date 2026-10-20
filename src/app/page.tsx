import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = { title: "Akorva", description: "Business · Inventory · Financial Clarity" };
export const viewport: Viewport = { width: "device-width", initialScale: 1, themeColor: "#2B3A33" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
