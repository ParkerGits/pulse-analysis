import NationalPlotSection from "./national-plot-section";
import { TypographyH2 } from "./typography-h2";
import WeeklyPlotSection from "./weekly-plot-section";

export default function ResultsSection() {
  return (
    <div>
      <TypographyH2>Results</TypographyH2>
      <div className="flex flex-col space-y-4">
        <WeeklyPlotSection />
        <hr />
        <NationalPlotSection />
      </div>
    </div>
  );
}
