import { WEEK_NUM_MAX, WEEK_NUM_MIN } from "@/lib/constants";
import { Slider } from "./ui/slider";

type WeekSliderProps = {
  value: number[];
  onValueChange?: (value: number[]) => void;
};

export default function WeekSlider({ value, onValueChange }: WeekSliderProps) {
  return (
    <div className="flex flex-row space-x-4 w-full flex-1">
      <div className="flex-1">Week {value[0]}</div>
      <Slider
        className="relative flex w-full touch-none select-none items-center"
        defaultValue={[WEEK_NUM_MAX]}
        min={WEEK_NUM_MIN}
        max={WEEK_NUM_MAX}
        onValueChange={onValueChange}
      />
    </div>
  );
}
