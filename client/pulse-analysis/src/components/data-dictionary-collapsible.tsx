import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible";
import { TypographyH3 } from "./typography-h3";
import { ChevronsUpDownIcon } from "lucide-react";
import { TypographyP } from "./typography-p";
import { TypographyAnchor } from "./typography-anchor";
import DataDictionaryEntry from "./data-dictionary-entry";
import TypographyUL from "./typography-ul";
import { TypographyBlockquote } from "./typography-blockquote";

export default function DataDictionaryCollapsible() {
  return (
    <Collapsible className="mt-4">
      <CollapsibleTrigger className="w-full">
        <div
          className={
            "rounded-t bg-muted hover:bg-gray-300 py-4 flex flex-row items-center justify-between space-x-1 w-full mx-auto px-4"
          }
        >
          <div className="flex flex-col items-start">
            <TypographyH3>Data Dictionary</TypographyH3>
            Click to Expand
          </div>
          <ChevronsUpDownIcon />
        </div>
      </CollapsibleTrigger>
      <CollapsibleContent>
        <div className="px-4 pb-4 bg-muted rounded-b">
          <TypographyP>
            Please note that because the variables considered in this analysis
            are drawn from the{" "}
            <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-two">
              Urban Institute's Questionnaire Two analysis
            </TypographyAnchor>
            , the definitions are similar to those used in their{" "}
            <TypographyAnchor href="https://www.urban.org/sites/default/files/2022-08/Tracking%20COVID-19s%20Effects%20by%20Race%20and%20Ethnicity_appendix_Phase%203-5.pdf">
              technical appendix
            </TypographyAnchor>
            .
          </TypographyP>
          <TypographyP>
            Analyses of individual metrics include all respondents unless
            otherwise noted.{" "}
          </TypographyP>
          <DataDictionaryEntry title="Health Insurance Coverage">
            Respondents were marked as uninsured if they reported that
            <TypographyUL className="mt-0 mb-3">
              <li>
                they did not have any of the following:
                <TypographyUL className="mt-0 mb-3">
                  <li>employer-provided health insurance</li>
                  <li>
                    insurance purchased directly from an insurance company
                  </li>
                  <li>including marketplace coverage</li>
                  <li>
                    Medicaid or any government assistance plan for people with
                    low incomes or a disability
                  </li>
                  <li>TRICARE or other military care</li>
                  <li>VA Health Insurance</li>
                </TypographyUL>
              </li>
              <li>
                they did have health insurance but only through the Indian
                Health Service
              </li>
            </TypographyUL>
            All respondents were asked this question, but our analysis only
            considers respondents younger than 65.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Public Health Insurance Coverage">
            Respondents were marked as having public health insurance coverage
            if they reported that they have any of the following:
            <TypographyUL className="mt-0 mb-3">
              <li>Medicare</li>
              <li>Medicaid</li>
              <li>
                any government assistance plan for people with low incomes or a
                disability
              </li>
              <li>VA Health Insurance</li>
            </TypographyUL>
            All respondents were asked this question, but our analysis only
            considers respondents younger than 65.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Income Loss">
            Between Phase 3 and Phase 3.1, this question changed. Phase 3 of the
            survey asked respondents,{" "}
            <TypographyBlockquote className="mt-0 my-4">
              "Have you, or anyone in your household experienced a loss of
              employment income since March 13, 2020?"
            </TypographyBlockquote>{" "}
            Phase 3.1 of the survey asked respondents,
            <TypographyBlockquote className="mt-0 my-4">
              "Have you, or anyone in your household experienced a loss of your
              household experienced a loss of employment income in the last four
              weeks?"
            </TypographyBlockquote>
            This change significantly affected responses to the question. For
            example, in week 27 (the final week of Phase 3), 44 percent of total
            respondents answered yes to this question; however, in week 28 (the
            first week of Phase 3.1), 19 percent of total respondents answered
            yes to this question. We note this question change in the titles of
            the data visualization tool for the "Income Loss" variable.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Expected Income Loss">
            Respondents were marked as expected to lose income if they reported
            that they or someone in their household expected to lose employment
            income in the next four weeks because of the COVID-19 pandemic. This
            question was removed from questionnaire two starting in Phase 3.2.
            In the data visualization tool, we include the data points from
            Phases 2, 3, and 3.1, with a note in the title that the question was
            removed starting in Phase 3.2.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Rent Payment Confidence">
            Respondents were marked as having no or slight confidence they can
            pay their rent next month or having deferred payment if they
            reported
            <TypographyUL className="mt-0 mb-3">
              <li>no confidence in paying rent next month</li>
              <li>little confidence in paying rent next month</li>
              <li>
                that they had already deferred their next month’s rent payment
              </li>
            </TypographyUL>
            This question was removed from the second questionnaire starting
            Phase 3.5. Analysis only includes respondents who rented their homes
            those who own their homes were not included.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Mortgage Payment Confidence">
            Respondents were marked as having no or slight confidence they can
            pay their mortgage next month or having deferred payment if they
            reported
            <TypographyUL className="mt-0 mb-3">
              <li>
                no confidence in their ability to pay their mortgage next month
              </li>
              <li>
                little confidence in their ability to pay their mortgage next
                month
              </li>
              <li>
                that they had already deferred their next month’s mortgage
                payment
              </li>
            </TypographyUL>
            This question was removed from the second questionnaire starting
            Phase 3.5. Analysis only includes respondents from households with a
            mortgage or loan.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Rent Caught Up">
            Respondents were marked as caught up on their rent payments if they
            responded that their household is currently caught up on rent
            payments. Analysis only includes respondents who rented their homes
            those who own their homes were not included.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Mortgage Caught Up">
            Respondents were marked as caught up on their mortgage payments if
            they responded that their household is currently caught up on
            mortgage payments. Analysis only includes respondents from
            households with a mortgage or loan.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Food Insufficiency">
            Respondents were marked as food insufficient if they reported that
            <TypographyUL className="mt-0 mb-3">
              <li>
                the food in their household in the past week was often not
                enough to eat
              </li>
              <li>
                the food in their household in the past week was sometimes not
                enough to eat.
              </li>
            </TypographyUL>
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Savings Spending">
            Respondents were marked as having spent from savings if they
            reported that they or someone in their household used money from
            savings or sold assets to meet their spending needs in the past
            seven days. This question was removed in Phase 4.0.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Credit Card &amp; Loan Spending">
            Respondents were marked as having used credit card or loan spending
            if they reported that they or someone in their household used credit
            cards or loans to meet their spending needs within the past seven
            days. This question was removed in Phase 4.0.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Unemployment Insurance Benefit Spending">
            Respondents were marked as having spent from UI benefits if they
            reported that they or someone in their household used unemployment
            insurance (UI) benefit payments to meet their spending needs in the
            past seven days. This question was removed in Phase 4.0.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Stimulus Payment Spending">
            Respondents were marked as having spent from stimulus payments if
            they reported that they or someone in their household used "stimulus
            (economic impact) payment" to meet their spending needs in the past
            seven days. This question was removed in Phase 4.0.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Depression &amp; Anxiety">
            Respondents were marked as displaying signs of anxiety or depression
            if in the past seven days (through Phase 3.1) or in the past two
            weeks (starting Phase 3.2) they
            <TypographyUL className="mt-0 mb-3">
              <li>
                experienced symptoms of anxiety, calculated by summing the
                responses to the following two questions based on an assigned
                numerical scale (not at all = 0, several days = 1, more than
                half the days = 2, nearly every day = 3):
                <TypographyUL className="mt-0 mb-3">
                  <li>feeling anxious, nervous, or on edge</li>
                  <li>not able to stop or control worrying</li>
                </TypographyUL>
                If the total score was 3 or higher, then the respondent was
                identified as experiencing symptoms of anxiety.
              </li>
              <li>
                experienced symptoms of depression, calculated by summing the
                responses to the following two questions based on an assigned
                numerical scale (not at all = 0, several days = 1, more than
                half the days = 2, and nearly every day = 3):
                <TypographyUL className="mt-0 mb-3">
                  <li>having little interest or pleasure in doing things</li>
                  <li>feeling down, depressed, or hopeless</li>
                </TypographyUL>
                If the total score was 3 or higher, then the respondent was
                identified as experiencing symptoms of depression.
              </li>
            </TypographyUL>
            <span>
              This definition is drawn from the{" "}
              <TypographyAnchor href="https://www.cdc.gov/nchs/data/nhis/earlyrelease/ERmentalhealth-508.pdf">
                National Center for Health Statistics
              </TypographyAnchor>
              .
            </span>
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Mental Health Needs">
            Respondents were marked if they had tried to get therapy and/or
            counseling from a mental health professional but were not able to
            anytime in the last 4 weeks. This question was removed from the
            survey in Phase 3.5.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Household Expenses">
            Respondents were marked if they reported it being somewhat difficult
            or very difficult for them to pay for their usual household expenses
            in the past seven days. This includes food, rent or mortgage, car
            payments, medical expenses, student loans, and so on.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Remote Work">
            Respondents were marked as working remotely if one or more working
            adults in their household who typically performed in-person work
            began working online because of the COVID-19 pandemic. This question
            was removed in Phase 3.1.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Eviction Risk">
            Respondents were marked as being at risk for eviction if they
            reported that it is somewhat or very likely that they would have to
            leave their house due to eviction in the next two months. Analysis
            only includes respondents who rented their homes those who own their
            homes were not included.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="Foreclosure Risk">
            Respondents were marked as being at risk for foreclosure if they
            reported that it is somewhat or very likely that they would have to
            leave their house due to foreclosure in the next two months.
            Analysis only includes respondents from households with a mortgage
            or loan.
          </DataDictionaryEntry>
          <DataDictionaryEntry title="SNAP Spending">
            Respondents were marked if they used "Supplemental Nutrition
            Assistance Program (SNAP)" to meet their spending needs in the past
            7 days. This question was removed in Phase 4.0.
          </DataDictionaryEntry>
        </div>
      </CollapsibleContent>
    </Collapsible>
  );
}
