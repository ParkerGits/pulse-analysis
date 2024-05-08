import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export function TypographyH2({
  children,
  className,
}: PropsWithChildren<{ className?: string }>) {
  return (
    <h2
      className={cn(
        "scroll-m-20 pb-2 text-3xl font-semibold tracking-tight first:mt-0 mt-4",
        className,
      )}
    >
      {children}
    </h2>
  );
}
