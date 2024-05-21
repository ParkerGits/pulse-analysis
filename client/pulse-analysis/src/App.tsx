import { TypographyH2 } from "./components/typography-h2";
import WeeklyPlotSection from "./components/weekly-plot-section";
import NationalPlotSection from "./components/national-plot-section";
import { TypographyAnchor } from "./components/typography-anchor";

export default function Component() {
  return (
    <div className="bg-white px-4 py-8 md:px-6 md:py-12 lg:px-8 lg:py-16">
      <div className="mx-auto max-w-3xl space-y-8">
        <div className="space-y-4">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            Tracking Economic Disparity Throughout the COVID-19 Pandemic
          </h1>
          <div className="flex items-center space-x-4 text-gray-500">
            <div>Parker Landon, Jack Goode</div>
            <div className="h-4 w-px bg-gray-300" />
            <div>DAT4500 Data and Society</div>
            <div className="h-4 w-px bg-gray-300" />
            <div>Seattle Pacific University</div>
          </div>
        </div>
        <div className="prose prose-gray max-w-none">
          <TypographyH2>Abstract</TypographyH2>
          <p></p>
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
            <NationalPlotSection />
          </div>
          <TypographyH2>Discussion</TypographyH2>
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sed
            fringilla nibh. Mauris auctor eros lectus, in tincidunt diam
            imperdiet vel. Cras sodales fermentum nisi, a mollis purus cursus
            vitae. Sed id ipsum ut tellus euismod elementum. Etiam pharetra nec
            mi at molestie. Ut euismod elit odio, sed egestas leo vulputate eu.
            Curabitur tempor nibh et nibh scelerisque pharetra eu id eros.
            Maecenas quis arcu pharetra, pharetra tellus quis, fringilla dolor.
            Curabitur placerat vehicula ligula, vel faucibus sem rhoncus ut.
            Vivamus nec pretium leo. Maecenas mollis massa nec gravida
            ullamcorper. Vestibulum commodo euismod lectus sit amet imperdiet.
          </p>
          <p>
            Aliquam eget enim nec dui posuere tincidunt ut et sem. In blandit,
            lacus sed dignissim accumsan, massa libero auctor mauris, ut
            malesuada nunc ex in sem. Sed justo nulla, euismod et maximus quis,
            fermentum id lorem. Nullam mauris nulla, vehicula pretium purus sit
            amet, hendrerit hendrerit justo. Sed finibus pulvinar tellus, sed
            aliquam leo interdum ac. Nullam ullamcorper, ipsum ac vestibulum
            tristique, tortor quam congue quam, eu vulputate nisi leo eget ante.
            Etiam efficitur dui eu fringilla blandit. Cras commodo odio rhoncus
            felis vehicula lacinia et eu elit. Nunc vulputate fringilla commodo.
            Phasellus vehicula mauris in semper placerat. Mauris lacinia
            pharetra ullamcorper. Suspendisse convallis finibus varius. Praesent
            lobortis ligula erat, non maximus nisl ullamcorper ut. Aliquam vitae
            accumsan mauris, fermentum aliquet nulla. Nulla facilisi.
          </p>
          <p>
            Morbi purus eros, mollis ac pellentesque at, finibus non turpis.
            Aliquam sit amet justo quis metus tempus tincidunt quis vitae diam.
            Praesent vel ullamcorper sem, at convallis nunc. Aenean facilisis
            venenatis lacus, in convallis purus vulputate nec. Duis ac nisi
            lacus. Donec fringilla, arcu quis convallis efficitur, risus orci
            ultricies felis, sed consectetur justo odio vel dolor. Praesent et
            tempus mauris.
          </p>
          <p>
            Integer venenatis mi tempor convallis lobortis. Donec efficitur
            risus id ipsum eleifend, vel aliquet diam hendrerit. Donec et risus
            malesuada, egestas magna vel, imperdiet quam. Quisque commodo metus
            eu ullamcorper commodo. Nunc vestibulum dolor nec ipsum faucibus,
            vitae sagittis dui tempor. Quisque id arcu sed arcu luctus rutrum in
            ac enim. Phasellus vel orci ut est sagittis pulvinar. Fusce ac
            faucibus leo, sit amet sodales tortor. Ut aliquet lorem nisl, eu
            euismod ex viverra vitae. Nunc laoreet diam ante, ut sagittis urna
            egestas eget. Suspendisse posuere sem sit amet ex varius, id
            malesuada orci varius. Etiam lorem libero, ullamcorper vitae
            imperdiet eget, consectetur id ligula. Ut vitae scelerisque dolor,
            id euismod ante.
          </p>
        </div>
      </div>
    </div>
  );
}
