import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export function TypographyBlockquote({
  children,
  className,
}: PropsWithChildren<{ className?: string; href?: string }>) {
  return (
    <blockquote className={cn("mt-6 border-l-2 pl-6 italic", className)}>
      {children}
    </blockquote>
  );
}
