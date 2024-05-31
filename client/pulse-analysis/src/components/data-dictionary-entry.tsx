import { TypographyH4 } from "./typography-h4";
import { PropsWithChildren } from "react";

type DataDictionaryEntryProps = {
  title: string;
};
export default function DataDictionaryEntry({
  title,
  children,
}: PropsWithChildren<DataDictionaryEntryProps>) {
  return (
    <div className="flex flex-col items-start mt-4">
      <TypographyH4>{title}</TypographyH4>
      {children}
    </div>
  );
}
