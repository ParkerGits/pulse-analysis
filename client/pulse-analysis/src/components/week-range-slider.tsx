import { WEEK_NUM_MAX, WEEK_NUM_MIN } from "@/lib/constants";
import { SliderRange } from "./ui/slider";

type WeekRangeSliderProps = {
  value: number[];
  onValueChange?: (value: number[]) => void;
};

export default function WeekRangeSlider({
  value,
  onValueChange,
}: WeekRangeSliderProps) {
  return (
    <div className="flex flex-row space-x-4 w-full flex-1">
      <div className="flex-1">
        Weeks {value[0]}-{value[1]}
      </div>
      <SliderRange
        className="relative flex w-full touch-none select-none items-center"
        defaultValue={[WEEK_NUM_MIN, WEEK_NUM_MAX]}
        min={WEEK_NUM_MIN}
        max={WEEK_NUM_MAX}
        onValueChange={onValueChange}
      />
    </div>
  );
}
