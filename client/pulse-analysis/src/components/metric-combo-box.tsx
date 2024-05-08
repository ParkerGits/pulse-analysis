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
import { WEEKLY_METRICS } from "@/lib/constants";
import { cn } from "@/lib/utils";

type MetricComboBoxProps = {
  metric: string;
  onMetricSelect: (metric: string) => void;
};
export default function MetricComboBox({
  metric,
  onMetricSelect,
}: MetricComboBoxProps) {
  const [open, setOpen] = useState(false);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          className="w-[300px] justify-between"
        >
          {metric === ""
            ? "Select metric..."
            : WEEKLY_METRICS[metric as keyof typeof WEEKLY_METRICS]}
          <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[300px] p-0">
        <Command className="rounded-lg border shadow-md">
          <CommandInput placeholder="Search metric..." />
          <CommandList>
            <CommandEmpty>No results found.</CommandEmpty>
            <CommandGroup>
              {Object.entries(WEEKLY_METRICS).map(([value, title]) => (
                <CommandItem
                  key={value}
                  value={title}
                  onSelect={() => {
                    onMetricSelect(value);
                    setOpen(false);
                  }}
                >
                  <Check
                    className={cn(
                      "mr-2 h-4 w-4",
                      metric === value ? "opacity-100" : "opacity-0",
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
