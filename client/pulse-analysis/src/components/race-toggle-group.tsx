import { ToggleGroupItem } from "@radix-ui/react-toggle-group";
import { ToggleGroup } from "./ui/toggle-group";
import { WEEKLY_RACE_VARS } from "@/lib/constants";

type RaceToggleGroupProps = {
  onValueChange?: (value: string[]) => void;
};

export default function RaceToggleGroup({
  onValueChange,
}: RaceToggleGroupProps) {
  return (
    <ToggleGroup type="multiple" onValueChange={onValueChange}>
      {Object.entries(WEEKLY_RACE_VARS).map(([value, title]) => (
        <ToggleGroupItem key={value} value={value} className="group">
          <div className="border border-input bg-transparent hover:bg-accent hover:text-accent-foreground px-2 rounded-sm group-data-[state=on]:bg-zinc-200">
            {title}
          </div>
        </ToggleGroupItem>
      ))}
    </ToggleGroup>
  );
}
