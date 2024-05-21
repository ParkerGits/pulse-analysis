export default function buildNationalPlotUrl(
  week: number | undefined,
  race: string | undefined,
  metric: string,
) {
  const url = new URL(
    "https://pulse-analysis-production.up.railway.app/national",
  );

  if (week !== undefined) url.searchParams.append("week", week.toString());
  if (race !== undefined && race !== "") url.searchParams.append("race", race);
  if (metric !== undefined && metric !== "")
    url.searchParams.append("metric", metric);

  return url.toString();
}
