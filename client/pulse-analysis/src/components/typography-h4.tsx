import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export function TypographyH4({
  children,
  className,
}: PropsWithChildren<{ className?: string }>) {
  return (
    <h2
      className={cn(
        "scroll-m-20 text-xl font-semibold tracking-tight",
        className,
      )}
    >
      {children}
    </h2>
  );
}
