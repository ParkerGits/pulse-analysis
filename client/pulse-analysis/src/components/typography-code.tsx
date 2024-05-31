import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export default function TypographyCode({
  children,
  className,
}: PropsWithChildren<{ className?: string }>) {
  return (
    <code
      className={cn(
        "relative rounded bg-muted px-[0.3rem] py-[0.2rem] font-mono text-sm font-semibold",
        className,
      )}
    >
      {children}
    </code>
  );
}
