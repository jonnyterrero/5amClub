import Sidebar from "@/components/layout/Sidebar";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className="flex h-screen overflow-hidden bg-slate-50 dark:bg-darkBg text-slate-900 dark:text-slate-100">
        <Sidebar />
        <main className="flex-1 overflow-y-auto md:ml-64 p-4 md:p-8">
            {children}
        </main>
      </body>
    </html>
  );
}
