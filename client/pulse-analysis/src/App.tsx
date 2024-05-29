import DiscussionSection from "./components/discussion-section";
import AbstractSection from "./components/abstract-section";
import IntroductionSection from "./components/introduction-section";
import MethodsSection from "./components/methods-section";
import ResultsSection from "./components/results-section";

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
          <AbstractSection />
          <IntroductionSection />
          <MethodsSection />
          <ResultsSection />
          <DiscussionSection />
        </div>
      </div>
    </div>
  );
}
