import { useState } from "react";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";
import { Check, ChevronsUpDown } from "lucide-react";
import { Button } from "./ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "./ui/command";
import { WEEKLY_GEOGRAPHIES } from "@/lib/constants";
import { cn } from "@/lib/utils";

type GeographyComboBoxProps = {
  geography: string;
  onGeographySelect: (geography: string) => void;
};
export default function GeographyComboBox({
  geography,
  onGeographySelect,
}: GeographyComboBoxProps) {
  const [open, setOpen] = useState(false);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="w-[200px] justify-between"
        >
          {geography === ""
            ? "Select geography..."
            : WEEKLY_GEOGRAPHIES[geography as keyof typeof WEEKLY_GEOGRAPHIES]}
          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[200px] p-0">
        <Command className="rounded-lg border shadow-md">
          <CommandInput placeholder="Search geography..." />
          <CommandList>
            <CommandEmpty>No results found.</CommandEmpty>
            <CommandGroup>
              {Object.entries(WEEKLY_GEOGRAPHIES).map(([value, title]) => (
                <CommandItem
                  key={value}
                  value={title}
                  onSelect={() => {
                    onGeographySelect(value);
                    setOpen(false);
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      geography === value ? "opacity-100" : "opacity-0",
                    )}
                  />
                  <span>{title}</span>
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
}
