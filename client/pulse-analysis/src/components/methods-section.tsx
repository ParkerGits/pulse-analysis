import { WEEKLY_METRICS } from "@/lib/constants";
import { TypographyAnchor } from "./typography-anchor";
import TypographyCode from "./typography-code";
import { TypographyH2 } from "./typography-h2";
import { TypographyP } from "./typography-p";
import TypographyUL from "./typography-ul";
import DataDictionaryCollapsible from "./data-dictionary-collapsible";
import standardError from "../assets/methods/standard_error.png";
import thetaHat from "../assets/methods/theta_hat.png";
import thetaI from "../assets/methods/theta_i.png";
import { TypographyH3 } from "./typography-h3";

export default function MethodsSection() {
  return (
    <div>
      <TypographyH2>Methods</TypographyH2>
      <div>
        <TypographyP>
          <TypographyH3>Data Source and Collection</TypographyH3>
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
          The US Census Bureau randomly selects a limited number of home
          addresses across the United States to participate in the Household
          Pulse Survey. These addresses are selected to represent the entire
          population and mitigate bias and undercoverage. Invited participants
          are sent an email or text message with a link to complete the survey.
          For information about the limitations of this approach, see the Data
          Processing and Limitations section below.
        </TypographyP>
        <TypographyP>
          <TypographyH3>Variables</TypographyH3>
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
          Each metric is derived from various survey responses and conditions.
          For more information about the computation of each metric, please
          consult the data dictionary below.
        </TypographyP>
        <TypographyP>
          The UrbanInstitute cites significant changes in Household Pulse Survey
          collection periods and questionnaires as reasons to omit Phase 1 data
          from their analysis of Phase 2 through Phase 3.5 data. We have
          followed suit and do not consider Phase 1 data in our results.
          However, despite the four-week collection and dissemination cycle
          introduced in Phase 4.0, our analysis includes data from Phase 4.0 and
          Phase 4.1, as relevant aspects of the questionnaire have remained
          mostly unchanged.
        </TypographyP>
        <TypographyP>
          Still, several minor yet relevant tweaks to the Household Pulse Survey
          questionnaire have occurred throughout the phases considered in this
          analysis. These changes are documented in the data dictionary below
          alongside detailed documentation about each metric.
        </TypographyP>
        <DataDictionaryCollapsible />
        <TypographyP>
          <TypographyH3>Data Processing and Limitations</TypographyH3>
          To create the data visualization tools, we computed metric means for
          each survey period, geography, and racial or ethnic group. Moreover,
          we computed standard errors using the 80 replicate weights associated
          with each respondent in the public use files. We represent each metric
          mean in the Weekly Metrics visualization as a point, and the bands
          surrounding those points represent 95% confidence intervals computed
          from the standard errors. In the National Metrics visualization,
          metric means are represented by the color fill of each state.
        </TypographyP>
        <TypographyP>
          Note that the numbers displayed in our results are estimates drawn
          from samples and thus subject to sampling error. Although these
          results may not equal the actual totals in each geography, we
          interpret these results as representing the relative and disparate
          impacts of COVID-19 by race and ethnicity. Moreover, estimates from
          the Household Pulse Survey are also subject to nonsampling error, the
          extent and impact of which is unknown by the US Census Bureau. Some
          possible sources of nonsampling error include
          <TypographyUL>
            <li>
              <strong>Measurement error</strong>: When a response is inaccurate
              due to the interviewer or the choice, estimate, or
              misunderstanding of the respondent.
            </li>
            <li>
              <strong>Undercoverage</strong>: When the survey frame misses
              housing units or people who should have been included.
            </li>
            <li>
              <strong>Nonresponse Bias</strong>: When responses are not
              collected from the entire sample or a respondent is unwilling or
              unable to provide information about a question. Note that survey
              responses comprise complete interviews and sufficiently completed
              partial interviews. In the case of partial interviews, some
              remaining questions may have been edited or imputed to fill in
              missing values. Insufficient partial interviews are considered
              nonrespondents.
            </li>
            <li>
              <strong>Imputation Error</strong>: When values are estimated
              imprecisely for missing data.
            </li>
          </TypographyUL>
          Because the full extent of this nonsampling error is unknown, the US
          Census Bureau warns against analyzing small differences between
          estimates and interpreting results based on relatively few cases.
          Caution should also be used when comparing Household Pulse Survey
          results with those from other sources due to differences in data
          collection and editing procedures. For more information, see the{" "}
          <TypographyAnchor href="https://www2.census.gov/programs-surveys/demo/technical-documentation/hhp/Phase4-1_Source_and_Accuracy_Cycle04.pdf">
            Household Pulse Survey Source And Accuracy Statement
          </TypographyAnchor>
          .
        </TypographyP>
        <TypographyP>
          To account for nonresponse, adults per household, and coverage, we
          calculate the standard errors of estimates according to the US Census
          Bureau's specification using the 80 replicate weights they created.
          Specifically, we use the following formula to calculate the variance
          of a statistic.
          <img src={standardError} className="h-20 mx-auto" />
          where
          <TypographyUL>
            <li>
              <img src={thetaHat} className="h-5 p-0 m-0 inline-block mb-1" />{" "}
              is the estimate of the statistic of interest calculated using the
              population weights created by the US Census Bureau.
            </li>
            <li>
              <img src={thetaI} className="h-5 p-0 m-0 inline-block" /> is the
              replicate estimate of the same statistic calculated using one of
              the 80 replicate weights.
            </li>
            <li>
              4 is derived from 1/[(1− <em>f</em>)]^2 where <em>f</em> is Fay’s
              adjustment. As such, we use a Fay’s adjustment of 0.5 to achieve a
              value of 4.
            </li>
            <li>80 is the number of replicate weights.</li>
          </TypographyUL>
          This computation is carried out by the{" "}
          <TypographyCode>survey</TypographyCode> and{" "}
          <TypographyCode>srvyr</TypographyCode> packages in R. The{" "}
          <TypographyCode>as_survey_rep()</TypographyCode> function from the{" "}
          <TypographyCode>srvyr</TypographyCode> package converts the response
          data according to the replicate weights. The{" "}
          <TypographyCode>svyby</TypographyCode> and{" "}
          <TypographyCode>svymean</TypographyCode> functions from the{" "}
          <TypographyCode>survey</TypographyCode> package calculate means and
          standard errors. Finally, the{" "}
          <TypographyCode>svycontrast</TypographyCode> function from the{" "}
          <TypographyCode>survey</TypographyCode> package calculates the mean
          and standard error of each difference between a race/ethnicity group
          mean and the mean for all other race/ethnicity groups in that
          geography.
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
          analysis. For more information about the methods used to compute
          metric means and standard errors, see the{" "}
          <TypographyAnchor href="https://www.urban.org/sites/default/files/2022-08/Tracking%20COVID-19s%20Effects%20by%20Race%20and%20Ethnicity_appendix_Phase%203-5.pdf">
            Urban Institute's Technical Appendix
          </TypographyAnchor>
        </TypographyP>
      </div>
    </div>
  );
}
