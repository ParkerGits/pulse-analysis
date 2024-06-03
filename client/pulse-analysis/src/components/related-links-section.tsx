import { TypographyAnchor } from "./typography-anchor";
import { TypographyH2 } from "./typography-h2";
import TypographyUL from "./typography-ul";

export default function RelatedLinksSection() {
  return (
    <div>
      <TypographyH2>References and Related Links</TypographyH2>
      <div>
        <TypographyUL className="mt-0">
          <li>
            View the{" "}
            <TypographyAnchor href="https://github.com/ParkerGits/pulse-analysis">
              GitHub repository
            </TypographyAnchor>{" "}
            associated with this project.
          </li>
          <li>
            See the{" "}
            <TypographyAnchor href="https://www.urban.org/data-tools/tracking-covid-19s-effects-race-and-ethnicity-questionnaire-two">
              Urban Institute's original analysis{" "}
            </TypographyAnchor>{" "}
            of COVID-19's effects between Phase 2 and Phase 3.5 of the Household
            Pulse Survey.
          </li>
          <li>
            Read "
            <TypographyAnchor href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10956714/">
              Food Insecurity in the Rural South in the Wake of the COVID-19
              Pandemic
            </TypographyAnchor>
            ."
          </li>
          <li>
            See{" "}
            <TypographyAnchor href="https://www.bbc.com/news/election/us2020/results">
              US Election 2020
            </TypographyAnchor>{" "}
            from the BBC, November 13, 2020.
          </li>
        </TypographyUL>
      </div>
    </div>
  );
}
