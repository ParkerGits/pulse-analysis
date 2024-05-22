import { TypographyH2 } from "./components/typography-h2";
import WeeklyPlotSection from "./components/weekly-plot-section";
import NationalPlotSection from "./components/national-plot-section";
import { TypographyAnchor } from "./components/typography-anchor";
import DiscussionSection from "./components/discussion-section";

export default function Component() {
  return (
    <div className="bg-white px-4 py-8 md:px-6 md:py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-3xl space-y-8">
        <div className="space-y-2">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl text-center">
            Economic Disparity Throughout and Beyond the COVID-19 Pandemic
          </h1>
          <div className="flex items-center space-x-4 text-gray-500 justify-center">
            <span>Parker Landon, Jack Goode</span>
            <div className="h-4 w-px bg-gray-300" />
            <span>DAT4500 Data and Society</span>
            <div className="h-4 w-px bg-gray-300" />
            <span>Seattle Pacific University</span>
          </div>
          <div className="flex items-center justify-center">
            <span className="text-sm text-gray-500 text-center">
              <em>Last updated June 4th, 2024</em>
            </span>
          </div>
        </div>
        <div className="prose prose-gray max-w-none">
          <TypographyH2>Abstract</TypographyH2>
          <p>
            The United States has struggled to withstand and recover from the
            economic downturn produced by the COVID-19 pandemic since its
            initial impact in early 2020. Black and brown communities
            disproportionately shouldered the original effects of the pandemic,
            exacerbating the already-existing inequities present in this nation.
            Now, four years after the pandemic's beginning, communities across
            the United States continue to feel its lasting effects. Drawing from
            Household Pulse Survey data produced by the U.S. Census Bureau, we
            consider how households in various communities throughout the United
            States are still impacted by or recovering from the pandemic. We
            introduce an interactive data visualization tool that illustrates
            changes in condition-indicating metrics like food insufficiency,
            spending, insurance, and income across various times, geographies,
            and ethnicities. Using this tool, we demonstrate the nation's uneven
            recovery, showing that social and economic disparities between
            racial, ethnic, and geographic communities remain steady. Across
            nearly all metrics, white communities consistently fare better than
            average, while recovery among black and brown communities seldom
            closes the gap. Moreover, while some metrics demonstrate
            improvements for the entire nation, others indicate how conditions
            have worsened for everybody. In response, we recommend that these
            results inform policies and decisions that focus on improving
            particular worsening conditions for specific communities that have
            undergone disproportionate impact and struggle to recover.
          </p>
          <TypographyH2>Introduction</TypographyH2>
          <p>
            The{" "}
            <TypographyAnchor href="https://www.urban.org/">
              UrbanInstitute
            </TypographyAnchor>{" "}
            has demonstrated the impact of COVID-19 on economic disparities
            between racial and ethnic groups by considering data from{" "}
            <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-one">
              Phase 1 (April 23, 2020 - July 21, 2020)
            </TypographyAnchor>{" "}
            and{" "}
            <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-two">
              Phases 2 through 3.5 (August 19, 2020 - July 11, 2022)
            </TypographyAnchor>{" "}
            of the Household Pulse Survey. Still, two years later, these
            disparities are persisting and deepening, with non-white groups
            shouldering much of the burden. This work extends the UrbanInstitute
            analyses with an interactive tool summarizing data through Phase 4.1
            (April 29, 2024) of the{" "}
            <TypographyAnchor href="https://www.census.gov/data/experimental-data-products/household-pulse-survey.html">
              Household Pulse Survey
            </TypographyAnchor>
            , illustrating our nation's uneven recovery from the pandemic and
            how its effects continue to disproportionately impact particular
            racial, ethnic, and geographic communities today.
          </p>
          <TypographyH2>Methods</TypographyH2>
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed gravida
            nibh pretium, iaculis lorem quis, vestibulum leo. Quisque vel turpis
            mollis, lacinia elit eget, lobortis lacus. Suspendisse pretium nisl
            risus, quis ultricies lorem suscipit et. Donec ornare nibh libero,
            sit amet commodo turpis fringilla id. Fusce in leo sit amet elit
            ullamcorper volutpat vitae sit amet leo. Integer ullamcorper maximus
            eros ut consectetur. Integer lobortis lectus ac tincidunt ultrices.
            Nunc tristique lacinia est eget dapibus. Aliquam commodo turpis
            vestibulum ex lobortis, in hendrerit sem facilisis. Vestibulum ante
            ipsum primis in faucibus orci luctus et ultrices posuere cubilia
            curae; Vestibulum ante ipsum primis in faucibus orci luctus et
            ultrices posuere cubilia curae; Vivamus cursus blandit enim quis
            auctor.
          </p>
          <TypographyH2>Results</TypographyH2>
          <div className="flex flex-col space-y-4">
            <WeeklyPlotSection />
            <hr />
            <NationalPlotSection />
          </div>
          <DiscussionSection />
        </div>
      </div>
    </div>
  );
}
