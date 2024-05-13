import { WEEK_NUM_MAX } from "@/lib/constants";
import { useState } from "react";
import RaceToggleGroupSingle from "./race-toggle-group-single";
import buildNationalPlotUrl from "@/lib/buildNationalPlotUrl";
import { Button } from "./ui/button";
import MetricComboBox from "./metric-combo-box";
import WeekSlider from "./week-slider";
import { TypographyH3 } from "./typography-h3";

export default function NationalPlotSection() {
  const [metric, setMetric] = useState<string>("food_insufficient");
  const [week, setWeek] = useState<number[]>([WEEK_NUM_MAX]);
  const [race, setRace] = useState<string>("white");

  const [plotUrl, setPlotUrl] = useState<string>(
    buildNationalPlotUrl(week[0], race, metric),
  );

  return (
    <div className="flex flex-col space-y-4">
      <TypographyH3>National Metrics</TypographyH3>
      <div className="flex flex-col items-center space-y-4">
        <RaceToggleGroupSingle onValueChange={setRace} />
        <WeekSlider onValueChange={setWeek} value={week} />
        <div className="flex flex-row items-center space-x-4">
          <MetricComboBox metric={metric} onMetricSelect={setMetric} />
          <Button
            onClick={() =>
              setPlotUrl(buildNationalPlotUrl(week[0], race, metric))
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
