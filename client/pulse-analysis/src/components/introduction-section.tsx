import { TypographyAnchor } from "./typography-anchor";
import { TypographyH2 } from "./typography-h2";
import { TypographyP } from "./typography-p";

export default function IntroductionSection() {
  return (
    <div>
      <TypographyH2>Introduction</TypographyH2>
      <div>
        <TypographyP>
          The Household Pulse Survey is an online survey established by the US
          Census Bureau to identify emergent economic and social issues facing
          households in America. The survey aims to deploy quickly and
          efficiently, providing near real-time insights to inform meaningful
          action. Survey questions concern household demographics alongside
          economic and social well-being indicators like employment, food
          sufficiency, and housing security. The survey's initial phases began
          on April 23, 2020, shortly after the descent of the COVID-19 pandemic
          in the United States, and has served as a vital measure of its effects
          throughout.
        </TypographyP>
        <TypographyP>
          By considering data from{" "}
          <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-one">
            Phase 1 (April 23, 2020 - July 21, 2020)
          </TypographyAnchor>{" "}
          and{" "}
          <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-two">
            Phases 2 through 3.5 (August 19, 2020 - July 11, 2022)
          </TypographyAnchor>{" "}
          of the Household Pulse Survey, the{" "}
          <TypographyAnchor href="https://www.urban.org/">
            UrbanInstitute
          </TypographyAnchor>{" "}
          has demonstrated the impact of COVID-19 on economic disparities
          between racial and ethnic groups. Still, two years later, these
          disparities are persisting and deepening, with non-white groups
          shouldering much of the burden. This work extends the UrbanInstitute
          analyses with an interactive tool summarizing data through Phase 4.1
          (April 29, 2024) of the{" "}
          <TypographyAnchor href="https://www.census.gov/data/experimental-data-products/household-pulse-survey.html">
            Household Pulse Survey
          </TypographyAnchor>
          , illustrating our nation's uneven recovery from the pandemic and how
          its effects continue to disproportionately impact particular racial,
          ethnic, and geographic communities today. We analyze several of the
          variables considered in the UrbanInstitute analyses and measured since
          the beginning of Phase 2 of the Household Pulse Survey in August 2020
          as we seek to answer the question,{" "}
          <strong>
            How are households in various communities throughout the United
            States still impacted by and recovering from the COVID-19 pandemic?
          </strong>
        </TypographyP>
      </div>
    </div>
  );
}
