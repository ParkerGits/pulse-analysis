export default function buildWeeklyPlotUrl(
  geography: string,
  weeks: number[] | undefined,
  races: string[] | undefined,
  metric: string,
) {
  const url = new URL(
    "https://pulse-analysis-production.up.railway.app/weekly",
  );

  if (weeks !== undefined) {
    url.searchParams.append("week_min", weeks[0].toString());
    url.searchParams.append("week_max", weeks[1].toString());
  }
  if (races !== undefined && races.length !== 0)
    url.searchParams.append("race", races.join(","));
  if (geography !== "") url.searchParams.append("geography", geography);
  if (metric !== undefined && metric !== "")
    url.searchParams.append("metric", metric);

  return url.toString();
}
