"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useCartStore } from "@/store/cartStore";
import { siteConfig, navLinks } from "@/config/site";
import Container from "@/components/ui/Container";
import { cn } from "@/lib/utils";

export default function Navbar() {
  const pathname = usePathname();
  const totalItems = useCartStore((s) => s.totalItems());

  return (
    <header className="sticky top-0 z-50 border-b border-emerald-100 bg-white/90 backdrop-blur-md shadow-sm">
      <Container>
        <nav
          className="flex h-16 items-center justify-between gap-6"
          aria-label="Navigation principale"
        >
          {/* Logo */}
          <Link
            href="/"
            className="flex items-center gap-2 text-base font-extrabold text-emerald-700 transition-colors hover:text-emerald-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500 rounded"
          >
            <span className="text-xl" aria-hidden="true">
              🛍️
            </span>
            <span className="hidden sm:inline">{siteConfig.name}</span>
            <span className="sm:hidden">{siteConfig.shortName}</span>
          </Link>

          {/* Nav links */}
          <ul className="hidden md:flex items-center gap-1" role="list">
            {navLinks.map((link) => {
              const isActive = pathname === link.href;
              return (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    aria-current={isActive ? "page" : undefined}
                    className={cn(
                      "rounded-full px-4 py-2 text-sm font-medium transition-colors",
                      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500",
                      isActive
                        ? "bg-emerald-50 text-emerald-700 font-semibold"
                        : "text-gray-600 hover:text-emerald-700 hover:bg-emerald-50"
                    )}
                  >
                    {link.label}
                  </Link>
                </li>
              );
            })}
          </ul>

          {/* Cart */}
          <Link
            href="/panier"
            aria-label={`Panier — ${totalItems} article${totalItems !== 1 ? "s" : ""}`}
            className={cn(
              "relative flex items-center gap-2 rounded-full px-4 py-2",
              "text-sm font-semibold text-emerald-700",
              "bg-emerald-50 transition-colors hover:bg-emerald-100",
              "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
            )}
          >
            <span aria-hidden="true">🛒</span>
            <span className="hidden sm:inline">Panier</span>
            {totalItems > 0 && (
              <span
                aria-hidden="true"
                className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-emerald-600 text-xs font-bold text-white"
              >
                {totalItems > 99 ? "99+" : totalItems}
              </span>
            )}
          </Link>
        </nav>
      </Container>
    </header>
  );
}
