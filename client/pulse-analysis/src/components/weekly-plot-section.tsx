import { useState } from "react";
import { WEEK_NUM_MAX, WEEK_NUM_MIN } from "@/lib/constants";
import RaceToggleGroup from "./race-toggle-group-multiple";
import WeekRangeSlider from "./week-range-slider";
import MetricComboBox from "./metric-combo-box";
import GeographyComboBox from "./geography-combo-box";
import { Button } from "./ui/button";
import buildWeeklyPlotUrl from "@/lib/buildWeeklyPlotUrl";
import { TypographyH3 } from "./typography-h3";

export default function WeeklyPlotSection() {
  const [geography, setGeography] = useState<string>("US");
  const [metric, setMetric] = useState<string>("food_insufficient");
  const [weeks, setWeeks] = useState<number[]>([WEEK_NUM_MIN, WEEK_NUM_MAX]);
  const [races, setRaces] = useState<string[]>();

  const [plotUrl, setPlotUrl] = useState<string>(
    buildWeeklyPlotUrl(geography, weeks, races, metric),
  );

  return (
    <div className="flex flex-col space-y-4">
      <TypographyH3>Weekly Metrics</TypographyH3>
      <div className="flex flex-col items-center space-y-4">
        <RaceToggleGroup onValueChange={setRaces} />
        <WeekRangeSlider onValueChange={setWeeks} value={weeks} />
        <div className="flex flex-row items-center space-x-4">
          <MetricComboBox metric={metric} onMetricSelect={setMetric} />
          <GeographyComboBox
            geography={geography}
            onGeographySelect={setGeography}
          />
          <Button
            onClick={() =>
              setPlotUrl(buildWeeklyPlotUrl(geography, weeks, races, metric))
            }
          >
            Plot
          </Button>
        </div>
        <img src={plotUrl} />
      </div>
    </div>
  );
}
