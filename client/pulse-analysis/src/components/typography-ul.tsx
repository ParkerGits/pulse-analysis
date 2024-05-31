import { cn } from "@/lib/utils";
import { PropsWithChildren } from "react";

export default function TypographyUL({
  children,
  className,
}: PropsWithChildren<{ className?: string }>) {
  return (
    <ul className={cn("my-6 ml-6 list-disc [&>li]:mt-2", className)}>
      {children}
    </ul>
  );
}
