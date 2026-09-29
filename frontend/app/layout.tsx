import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import AreaNavbar from "@/components/Navbar";
import ActivationPopup from "@/components/ActivationPopup";
import { GlobalProvider } from "@/components/GlobalContext";
import { Toaster } from "@/components/ui/toaster"

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  title: "Area - Automation Service",
  description: "Area is an automation service that allows you to connect your favorite apps and services together.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <GlobalProvider>
          <ActivationPopup />
          <AreaNavbar />
          {children}
        </GlobalProvider>
        <Toaster />
      </body>
    </html>
  );
}