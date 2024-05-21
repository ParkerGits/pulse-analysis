import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export function TypographyAnchor({
  children,
  className,
  href,
}: PropsWithChildren<{ className?: string; href?: string }>) {
  return (
    <a
      className={cn(
        "font-semibold text-blue-400 hover:underline hover:text-blue-600",
        className,
      )}
      href={href}
      target="_blank"
    >
      {children}
    </a>
  );
}
