import { TypographyH2 } from "./typography-h2";
import { TypographyP } from "./typography-p";

export default function AbstractSection() {
  return (
    <div>
      <TypographyH2>Abstract</TypographyH2>
      <div>
        <TypographyP>
          The United States has struggled to withstand and recover from the
          economic downturn produced by the COVID-19 pandemic since its initial
          impact in early 2020. Black and brown communities disproportionately
          shouldered the original effects of the pandemic, exacerbating the
          already-existing inequities present in this nation. Now, four years
          after the pandemic's beginning, communities across the United States
          continue to feel its lasting effects. Drawing from Household Pulse
          Survey data produced by the U.S. Census Bureau, we consider how
          households in various communities throughout the United States are
          still impacted by and recovering from the pandemic. We introduce an
          interactive data visualization tool that illustrates changes in
          condition-indicating metrics like food insufficiency, spending,
          insurance, and income across various times, geographies, races, and
          ethnicities. Using this tool, we demonstrate the nation's uneven
          recovery, showing that social and economic disparities between racial,
          ethnic, and geographic communities remain steady. Across nearly all
          metrics, white communities consistently fare better than average,
          while recovery among Black, Hispanic, and nonwhite, non-Asian
          communities seldom closes the gap. Moreover, while some metrics
          demonstrate improvements for the entire nation, others indicate how
          conditions have worsened for everybody.
        </TypographyP>
      </div>
    </div>
  );
}
