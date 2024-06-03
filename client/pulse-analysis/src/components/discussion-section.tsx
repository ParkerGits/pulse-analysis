import { TypographyH2 } from "./typography-h2";
import buildWeeklyPlotUrl from "@/lib/buildWeeklyPlotUrl";
import { TypographyP } from "./typography-p";
import { TypographyAnchor } from "./typography-anchor";
import { TypographyH3 } from "./typography-h3";
import buildNationalPlotUrl from "@/lib/buildNationalPlotUrl";
import politicalAffiliation from "../assets/discussion/political_affiliation.png";

export default function DiscussionSection() {
  return (
    <div>
      <TypographyP>
        <TypographyH2>Discussion</TypographyH2>
        In the following sections, we consider specific results from the data
        visualization tool to analyze disparate social and economic conditions
        between racial, ethnic, and geographic groups. Note that this discussion
        represents an observational study in which we cannot draw any firm
        conclusions about causation. As we examine the fallout of the COVID-19
        pandemic, we only speculate about possible causes as we recognize
        patterns and associations.
      </TypographyP>
      <div className="mt-6">
        <TypographyP>
          <TypographyH3>Racial and Ethnic Disparities</TypographyH3>
          The Weekly Metrics interactive data tool demonstrates stark and
          sustained disparities between racial and ethnic groups across several
          critical social and economic well-being indicators. These disparities
          are most pronounced in the plots of food insufficiency and household
          expense difficulty, where the rates among white and Asian households
          consistently indicate significantly better circumstances than the
          aggregate, and the rates among Black, Hispanic, and other groups
          illustrate disproportionate hardship.
        </TypographyP>
        <div className="flex flex-row items-center justify-between">
          <img
            src={buildWeeklyPlotUrl(
              "US",
              [13, 67],
              undefined,
              "food_insufficient",
            )}
            className="flex-shrink min-w-0"
          />
          <img
            src={buildWeeklyPlotUrl("US", [13, 67], undefined, "expense_dif")}
            className="flex-shrink min-w-0"
          />
        </div>
        <TypographyP>
          This pattern of white and Asian adults faring better than average
          while Black, Hispanic, and other nonwhite, non-Asian adults remain
          worse off manifests regularly for other metrics, too. Plots of the
          income loss variable, for example, reveal consistently higher rates of
          income loss among Black, Hispanic, and other nonwhite households than
          white and Asian households. The plot below illustrates income loss by
          group for weeks following the Phase 3.1 question change until Phase
          4.1.
        </TypographyP>
        <img
          src={buildWeeklyPlotUrl("US", [28, 67], undefined, "inc_loss_rv")}
          className="flex-shrink min-w-0"
        />
        <TypographyP>
          <TypographyH3>Sweeping Signs of Recovery</TypographyH3>
          Despite these revealed disparities, the moderate drops among lines in
          the right plot indicate that rates of income loss have steadily
          decreased since 2021. Indeed, several metrics indicate improving
          conditions for all communities since the onset of the COVID-19
          pandemic. Plots of mortgage and rent payment statuses, for example,
          suggest that households in all communities are steadily catching up on
          these expenses. Yet, these metrics exemplify striking disparities
          between communities once more, as white adults demonstrate
          significantly stronger financial footing with household expenses than
          adults among all other communities.
        </TypographyP>
        <div className="flex flex-row items-center justify-between">
          <img
            src={buildWeeklyPlotUrl(
              "US",
              [13, 67],
              undefined,
              "mortgage_caughtup",
            )}
            className="flex-shrink min-w-0"
          />
          <img
            src={buildWeeklyPlotUrl("US", [13, 67], undefined, "rent_caughtup")}
            className="flex-shrink min-w-0"
          />
        </div>
        <TypographyP>
          The plot of health insurance rates over time suggests improving
          conditions, too. Since the beginning of Phase 2 of the Household Pulse
          Survey in August 2020, the percentage of uninsured households has
          steadily decreased among all communities. However, white and Asian
          adults are again consistently faring better than average,
          demonstrating significantly lower uninsured rates than other groups.
          Meanwhile, the uninsured rates among Black and Hispanic adults, as
          well as among adults of other races or a combination of races, are no
          better or worse than average. Notably, Hispanic adults face
          significantly higher uninsured rates than all other groups across all
          weeks.
        </TypographyP>
        <img src={buildWeeklyPlotUrl("US", [13, 67], undefined, "uninsured")} />
        <TypographyP>
          <TypographyH3>Widespread Decline</TypographyH3>
          In contrast to the ostensibly improving conditions associated with
          decreased rates of uninsured adults over the last four years, the
          percentage of adults with public health insurance has risen
          considerably. The UrbanInstitute attributes this increase to the
          economic fallout associated with COVID-19, which has reduced the
          availability of employer-based health insurance and thus raised the
          need for public options like Medicare, Medicaid, and VA Health
          Insurance. Consequently, the UrbanInstitute asserts, more people risk
          losing health insurance coverage. The sustained climb in public health
          insurance dependence among all communities suggests that these
          conditions are <em>still</em> worsening and that the effects of
          COVID-19 are still widely felt. Once again, adults among Black,
          Hispanic, and other nonwhite communities are disproportionately
          affected as they lean on public insurance services more than white and
          Asian adults. Moreover, despite enduring the highest uninsured rates,
          Hispanic communities lean the least on public health insurance among
          nonwhite, non-Asian communities, indicating their relatively limited
          and unequal access to these services.
        </TypographyP>
        <img
          src={buildWeeklyPlotUrl("US", [13, 67], undefined, "insured_public")}
        />
        <TypographyP>
          Spending metrics also indicate worsening conditions across the nation,
          with savings, credit card, and loan spending rising steadily among
          adults in all communities over the last three years. These increases
          parallel the steady decreases in employment income loss, indicating
          that households are increasingly dependent on resources beyond wages
          despite stabilizing incomes.
        </TypographyP>
        <div className="flex flex-row items-center justify-between">
          <img
            src={buildWeeklyPlotUrl("US", [28, 63], undefined, "spend_savings")}
            className="flex-shrink min-w-0"
          />
          <img
            src={buildWeeklyPlotUrl("US", [28, 63], undefined, "spend_credit")}
            className="flex-shrink min-w-0"
          />
        </div>
        <TypographyP>
          <TypographyH3>
            Trends in Mental Health and Economic Well-Being
          </TypographyH3>
          Despite indicators of worsening conditions, rates of depression and
          anxiety signs have fallen as time has distanced us from the initial
          onset of the COVID-19 pandemic. Still, these metrics indicate superior
          conditions among white and Asian adults as they have consistently
          reported better mental health than adults in Black, Hispanic, and
          other nonwhite communities throughout the entire pandemic and its
          fallout.
        </TypographyP>
        <img
          src={buildWeeklyPlotUrl(
            "US",
            [13, 67],
            undefined,
            "depression_anxiety_signs",
          )}
          className="flex-shrink min-w-0"
        />
      </div>
      <TypographyP>
        The plot of depression and anxiety signs reveals that mental health
        among US adults was at its worst in late 2020. This peak occurred before
        the distribution of vaccines and as the number of confirmed COVID-19
        cases was skyrocketing. The United States also experienced significant
        political unrest during this time following the murder of George Floyd,
        the presidential election, and the January 6 attack on the US Capitol.
        These factors are all conducive to a pessimistic outlook, which is
        reflected also in the plot of expected income loss that peaks during
        this period.
      </TypographyP>
      <img
        src={buildWeeklyPlotUrl("US", [13, 32], undefined, "expect_inc_loss")}
        className="flex-shrink min-w-0"
      />
      <TypographyP>
        The geographic distribution of expected income loss reveals that
        respondents in some states were more optimistic about their economic
        outlook than others. Comparing these rates to the political party
        affiliation of each state, we recognize some overlap and association,
        suggesting that Republican states tended to be less pessimistic about
        economic fallout and the pandemic's effects than Democrat states.
      </TypographyP>
      <div className="flex flex-row items-center justify-between">
        <img
          src={buildNationalPlotUrl(20, "total", "expect_inc_loss")}
          className="flex-1 min-w-0"
        />
        <div className="flex flex-col items-center justify-center flex-1">
          <img src={politicalAffiliation} className="flex-shrink min-w-0" />
          <span className="font-semibold text-center text-sm">
            2020 Presidential Race Political Affiliation, by State
          </span>
          <span className="text-center text-muted-foreground text-xs">
            <em>
              <TypographyAnchor href="https://www.bbc.com/news/election/us2020/results">
                Source: US Election 2020; BBC, 13 November 2020
              </TypographyAnchor>
            </em>
          </span>
        </div>
      </div>
      <TypographyP>
        Still, respondents everywhere demonstrate appalling mental health
        outcomes, with the total populations of all states exhibiting
        greater-than-average rates of anxiety and depression.
      </TypographyP>
      <img
        src={buildNationalPlotUrl(20, "total", "depression_anxiety_signs")}
        className="flex-1 min-w-0"
      />
      <TypographyP>
        In early 2021, following the conclusion of the 2020 presidential
        election, the authorization and distribution of stimulus payments, and
        the initial distribution of COVID-19 vaccines in the US, mental health
        improved dramatically. Still, amidst fluctuating COVID-19 cases, the
        announcement of new threatening COVID-19 variants, and the increasingly
        salient economic fallout of the pandemic, mental health subsequently
        worsened steadily until late 2023.
      </TypographyP>
      <TypographyP>
        This pattern of adverse well-being metrics peaking in late 2020, dipping
        over the next 3-6 months, and then steadily increasing again is
        exhibited by food insufficiency, household expense difficulty, and
        credit card and loan spending, too. Perhaps these indicators are
        mutually conducive or share a common cause. As mentioned, the
        intensifying threat of COVID-19 explains the initial peaks, and the
        subsequent improvements occur as the threat of COVID infection is
        subdued briefly. The steady increase in these metrics following this
        trough may be explained by the announcement of new COVID-19 variants and
        the increasingly widespread economic impact of the pandemic.
      </TypographyP>
      <div className="grid grid-cols-2">
        <img
          src={buildWeeklyPlotUrl(
            "US",
            [13, 67],
            ["total"],
            "food_insufficient",
          )}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildWeeklyPlotUrl(
            "US",
            [13, 67],
            ["total"],
            "depression_anxiety_signs",
          )}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildWeeklyPlotUrl("US", [13, 67], ["total"], "expense_dif")}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildWeeklyPlotUrl("US", [13, 67], ["total"], "spend_credit")}
          className="flex-shrink min-w-0"
        />
      </div>
      <TypographyP>
        The plot of depression and anxiety signs also illustrates that at the
        beginning of Phase 4.0, mental health improved dramatically. While the
        cause of this sudden drop in depression and anxiety rates is uncertain,
        it is worth noting that the location of the relevant survey questions
        changed in Phase 4.0. Before this phase, questions about mental health
        followed questions about the experience of and recovery from natural
        disasters; now, they follow questions about disability-related
        difficulty in communicating.
      </TypographyP>
      <TypographyP>
        Still, it seems unlikely that a change in the question location would
        contribute to such a considerable decrease. Moreover, metrics like food
        insufficiency and household expense difficulty reveal a similar dip
        starting in Phase 4.0. In this way, relevant economic and social
        conditions may have actually improved since Phase 3.10 ended, leading to
        better mental health outcomes. Nevertheless, at around 20%, rates of
        depression and anxiety remain significantly higher than they were in
        2019 when, according to the{" "}
        <TypographyAnchor href="https://www.cdc.gov/nchs/data/nhis/mental-health-monthly-508.pdf">
          National Health Interview Study
        </TypographyAnchor>
        , only 10.8% of adults over the age of 18 reported symptoms of anxiety
        disorder or depressive disorder.
      </TypographyP>
      <TypographyP>
        <TypographyH3>Geographic Disparities in Nutrition</TypographyH3>
        At the end of 2023 and Phase 3.10, households across the entire United
        States reported experiencing significant food insufficiency.
      </TypographyP>
      <img
        src={buildNationalPlotUrl(63, "total", "food_insufficient")}
        className="flex-shrink min-w-0"
      />
      <TypographyP>
        This impact was felt most deeply in the Southern United States, where,
        according to{" "}
        <TypographyAnchor href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10956714/">
          a study of food insecurity in the rural South
        </TypographyAnchor>
        , rural and low-income communities primarily comprise Black populations.
        Indeed, Black communities demonstrate significantly higher food
        insufficiency rates than white populations, not only in the South but in
        almost all regions.
      </TypographyP>
      <div className="flex flex-row items-center justify-between">
        <img
          src={buildNationalPlotUrl(63, "white", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildNationalPlotUrl(63, "black", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
      </div>
      <TypographyP>
        This disparity is further represented in side-by-side plots of food
        insufficiency in Asian communities and communities of Hispanic or other
        nonwhite, non-Asian populations.
      </TypographyP>
      <div className="flex flex-row items-center justify-between">
        <img
          src={buildNationalPlotUrl(63, "asian", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildNationalPlotUrl(63, "hispanic", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildNationalPlotUrl(63, "other", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
      </div>
      <TypographyP>
        This geographic disparity in food insufficiency once again reflects the
        trend of nonwhite, non-Asian communities facing disproportionate
        hardship associated with the economic fallout of the COVID-19 pandemic.
        Notably, these disparities don't seem to correlate with SNAP spending:
        regions that experience higher rates of food insufficiency are not
        necessarily regions where SNAP spending is the highest. For example, in
        the same period, Black communities in Wisconsin, Illinois, and Indiana
        experienced some of the lowest food insufficiency rates in the country
        yet demonstrated the highest rates of SNAP spending. Conversely, Black
        populations in Texas represent some of the highest food insufficiency
        rates during this period yet demonstrate relatively low rates of SNAP
        spending.
      </TypographyP>
      <div className="flex flex-row items-center justify-between">
        <img
          src={buildNationalPlotUrl(63, "black", "food_insufficient")}
          className="flex-shrink min-w-0"
        />
        <img
          src={buildNationalPlotUrl(63, "black", "spend_snap")}
          className="flex-shrink min-w-0"
        />
      </div>
      <TypographyP>
        One may be tempted to assume that regions with higher rates of food
        insufficiency comprise more people depending on SNAP. However, the plots
        above may reflect an opposite association for some regions: populations
        with less access to SNAP may experience higher rates of food
        insufficiency. That is, access to support programs like SNAP, or lack
        thereof, may contribute to food insufficiency rates instead of
        vice-versa.
      </TypographyP>
    </div>
  );
}
