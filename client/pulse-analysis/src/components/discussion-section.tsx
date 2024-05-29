import { TypographyH2 } from "./typography-h2";
import foodInsufficient from "../assets/discussion/food_insufficient.png";
import mortgage from "../assets/discussion/mortgage.png";
import rent from "../assets/discussion/rent.png";
import uninsured from "../assets/discussion/uninsured.png";
import publicHealthInsurance from "../assets/discussion/insured_public.png";

export default function DiscussionSection() {
  return (
    <>
      <TypographyH2>Discussion</TypographyH2>
      <p>
        The Weekly Metrics interactive data tool demonstrates stark, sustained
        disparities between racial and ethnic groups across several critical
        social and economic well-being indicators. These disparities are most
        pronounced in the plot of food insufficiency rates over time, where
        white and Asian communities consistently fall significantly below the
        aggregate rates of food insufficiency while black, Hispanic, and other
        groups consistently lie significantly above.
      </p>
      <img src={foodInsufficient} />
      <p>
        Aliquam eget enim nec dui posuere tincidunt ut et sem. In blandit, lacus
        sed dignissim accumsan, massa libero auctor mauris, ut malesuada nunc ex
        in sem. Sed justo nulla, euismod et maximus quis, fermentum id lorem.
        Nullam mauris nulla, vehicula pretium purus sit amet, hendrerit
        hendrerit justo. Sed finibus pulvinar tellus, sed aliquam leo interdum
        ac. Nullam ullamcorper, ipsum ac vestibulum tristique, tortor quam
        congue quam, eu vulputate nisi leo eget ante. Etiam efficitur dui eu
        fringilla blandit. Cras commodo odio rhoncus felis vehicula lacinia et
        eu elit. Nunc vulputate fringilla commodo. Phasellus vehicula mauris in
        semper placerat. Mauris lacinia pharetra ullamcorper. Suspendisse
        convallis finibus varius. Praesent lobortis ligula erat, non maximus
        nisl ullamcorper ut. Aliquam vitae accumsan mauris, fermentum aliquet
        nulla. Nulla facilisi.
      </p>
      <img src={mortgage} />
      <img src={rent} />
      <p>
        Morbi purus eros, mollis ac pellentesque at, finibus non turpis. Aliquam
        sit amet justo quis metus tempus tincidunt quis vitae diam. Praesent vel
        ullamcorper sem, at convallis nunc. Aenean facilisis venenatis lacus, in
        convallis purus vulputate nec. Duis ac nisi lacus. Donec fringilla, arcu
        quis convallis efficitur, risus orci ultricies felis, sed consectetur
        justo odio vel dolor. Praesent et tempus mauris.
      </p>
      <img src={uninsured} />
      <img src={publicHealthInsurance} />
      <p>
        Integer venenatis mi tempor convallis lobortis. Donec efficitur risus id
        ipsum eleifend, vel aliquet diam hendrerit. Donec et risus malesuada,
        egestas magna vel, imperdiet quam. Quisque commodo metus eu ullamcorper
        commodo. Nunc vestibulum dolor nec ipsum faucibus, vitae sagittis dui
        tempor. Quisque id arcu sed arcu luctus rutrum in ac enim. Phasellus vel
        orci ut est sagittis pulvinar. Fusce ac faucibus leo, sit amet sodales
        tortor. Ut aliquet lorem nisl, eu euismod ex viverra vitae. Nunc laoreet
        diam ante, ut sagittis urna egestas eget. Suspendisse posuere sem sit
        amet ex varius, id malesuada orci varius. Etiam lorem libero,
        ullamcorper vitae imperdiet eget, consectetur id ligula. Ut vitae
        scelerisque dolor, id euismod ante.
      </p>
    </>
  );
}
