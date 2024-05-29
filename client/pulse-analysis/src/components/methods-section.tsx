import { TypographyAnchor } from "./typography-anchor";
import { TypographyH2 } from "./typography-h2";
import { TypographyP } from "./typography-p";

export default function MethodsSection() {
  return (
    <div>
      <TypographyH2>Methods</TypographyH2>
      <div>
        <TypographyP>
          The interactive data tool comprises data from the Public Use Data
          Files published by the Household Pulse Survey. The collection and
          dissemination of Public Use Data Files occurs in periodic phases. Our
          analysis considers data published as Public Use Files between the
          start of Phase 2 (August 19, 2020) and the end of Phase 4.1 Cycle 4
          (April 29, 2024) of the Household Pulse Survey. All public use files,
          associated data dictionaries, and replicate weight files are located
          on the{" "}
          <TypographyAnchor href="https://www.census.gov/programs-surveys/household-pulse-survey/data/datasets.2024.html">
            US Census Bureau website
          </TypographyAnchor>
          .
        </TypographyP>
      </div>
    </div>
  );
}
