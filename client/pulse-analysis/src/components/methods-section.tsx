import { WEEKLY_METRICS } from "@/lib/constants";
import { TypographyAnchor } from "./typography-anchor";
import TypographyCode from "./typography-code";
import { TypographyH2 } from "./typography-h2";
import { TypographyP } from "./typography-p";
import TypographyUL from "./typography-ul";
import DataDictionaryCollapsible from "./data-dictionary-collapsible";

export default function MethodsSection() {
  return (
    <div>
      <TypographyH2>Methods</TypographyH2>
      <div>
        <TypographyP>
          The data considered in this work originates in the Public Use Data
          Files published by the Household Pulse Survey. All public use files,
          associated data dictionaries, and replicate weight files are available
          on the{" "}
          <TypographyAnchor href="https://www.census.gov/programs-surveys/household-pulse-survey/data/datasets.2024.html">
            US Census Bureau website
          </TypographyAnchor>
          . The survey reports data for all 50 states, the District of Columbia,
          and the 15 largest metropolitan statistical areas. The results
          presented here consider only national and state-level rates.
        </TypographyP>
        <TypographyP>
          The collection and dissemination of public use files occurs in
          periodic phases. Our analysis considers data published between the
          start of Phase 2 (August 19, 2020) and the end of Phase 4.1 Cycle 4
          (April 29, 2024). The dates for all relevant phases of the Household
          Pulse Survey are as follows.
        </TypographyP>
        <TypographyUL>
          <li>
            <strong>Phase 2</strong>: August 19, 2020 – October 26, 2020
          </li>
          <li>
            <strong>Phase 3</strong>: October 28, 2020 – March 29, 2021
          </li>
          <li>
            <strong>Phase 3.1</strong>: April 14, 2021 – July 5, 2021
          </li>
          <li>
            <strong>Phase 3.2</strong>: July 21, 2021 – October 11, 2021
          </li>
          <li>
            <strong>Phase 3.3</strong>: December 1, 2021 – February 7, 2022
          </li>
          <li>
            <strong>Phase 3.4</strong>: March 2, 2022 – May 9, 2022
          </li>
          <li>
            <strong>Phase 3.5</strong>: June 1, 2022 – August 8, 2022
          </li>
          <li>
            <strong>Phase 3.6</strong>: September 14, 2022 – November 14, 2022
          </li>
          <li>
            <strong>Phase 3.7</strong>: December 9, 2022 – February 13, 2023
          </li>
          <li>
            <strong>Phase 3.8</strong>: March 1, 2023 – May 8, 2023
          </li>
          <li>
            <strong>Phase 3.9</strong>: June 7, 2023 – August 7, 2023
          </li>
          <li>
            <strong>Phase 3.10</strong>: August 23, 2023 – October 30, 2023
          </li>
          <li>
            <strong>Phase 4.0</strong>: January 9, 2024 – April 1, 2024
          </li>
          <li>
            <strong>Phase 4.1</strong>: April 2, 2024 - April 29, 2024 (Cycle 4)
          </li>
        </TypographyUL>
        <TypographyP>
          From Phase 2 to Phase 3.10, data collection and dissemination occurred
          in two-week cycles. Starting in Phase 4.0, the Household Pulse Survey
          commenced with a four-week approach.
        </TypographyP>
        <TypographyP>
          The race and ethnicity categories considered in this report mirror
          those created by the UrbanInstitute and used in the{" "}
          <TypographyAnchor href="https://www.census.gov/programs-surveys/household-pulse-survey/data/tables.html">
            Household Pulse Survey Data Tables
          </TypographyAnchor>
          : White, Black, Asian, Hispanic, and Other. These categories are
          computed from two variables: <TypographyCode>rrace</TypographyCode>,
          which has four levels, namely Asian alone, Black alone, white alone,
          and any other race alone or races in combination; and{" "}
          <TypographyCode>rhispanic</TypographyCode>, which is 2 for respondents
          of Hispanic, Latino, or Spanish origin and 1 otherwise. Additionally,
          the Total group represents the aggregate of respondents.
        </TypographyP>
        <TypographyP>
          The metrics considered in this analysis are drawn from those featured
          in the{" "}
          <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-two">
            UrbanInstitute Questionnaire Two analysis
          </TypographyAnchor>{" "}
          and are as follows.
        </TypographyP>
        <TypographyUL>
          {Object.values(WEEKLY_METRICS).map((metric) => (
            <li>{metric}</li>
          ))}
        </TypographyUL>
        <TypographyP>
          To create the data visualization tools, we computed metric means for
          each survey period, geography, and racial or ethnic group. Moreover,
          we computed standard errors using the 80 replicate weights associated
          with each respondent in the public use files. We represent each metric
          mean in the Weekly Metrics visualization as a point, and the bands
          surrounding those points represent 95% confidence intervals computed
          from the standard errors. The UrbanInstitute notes that while two
          statistics with non-overlapping confidence intervals are necessarily
          significantly different, the converse is not true, and two estimates
          with overlapping confidence intervals may be significantly different.
          In the National Metrics visualization, metric means are represented by
          the color fill of each state. As the UrbanInstitute warns, these
          numbers are estimates and may not equal the totals in each geography.
          As such, we interpret these results as representing the disparate
          impacts of COVID-19 by race and ethnicity.
        </TypographyP>
        <TypographyP>
          The UrbanInstitute developed and made available the original methods
          for computing each metric statistic in{" "}
          <TypographyAnchor href="https://github.com/UrbanInstitute/pulse_covid_feature_phase2">
            the associated UrbanInstitute GitHub repository
          </TypographyAnchor>
          . We have forked, modified, and extended this original code to support
          data in later phases and create our data visualization tool. This new
          code is available in{" "}
          <TypographyAnchor href="https://github.com/ParkerGits/pulse-analysis">
            the pulse-analysis GitHub repository
          </TypographyAnchor>{" "}
          alongside the code for this site and scripts for exploratory data
          analysis.
        </TypographyP>
        <TypographyP>
          The UrbanInstitute cites significant changes in Household Pulse Survey
          collection periods and questionnaires as reasons to omit Phase 1 data
          from an analysis of Phase 2 through Phase 3.5 data. We have followed
          suit and do not consider Phase 1 data in our results. However, despite
          the four-week collection and dissemination cycle introduced in Phase
          4.0, our analysis includes data from Phase 4.1, as relevant aspects of
          the questionnaire have remained mostly unchanged.
        </TypographyP>
        <TypographyP>
          Still, several minor yet relevant tweaks to the Household Pulse Survey
          questionnaire have occurred throughout the phases considered in this
          analysis. These changes are documented in the data dictionary below
          alongside detailed documentation about each metric.
        </TypographyP>
      </div>
      <DataDictionaryCollapsible />
    </div>
  );
}
