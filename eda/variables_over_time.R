library(tidyverse)

puf_all_weeks <- read_csv("data/final-data/phase2_all.csv")

phase_breaks = c("wk13", "wk18", "wk28", "wk34", t(distinct(puf_all_weeks["week_num"]))[seq(28,50,3)])
week_labels = c("08/19/2020",
                "10/28/2020",
                "04/14/2021",
                "07/21/2021",
                "12/01/2021",
                "03/02/2022",
                "06/01/2022",
                "09/14/2022",
                "12/09/2022",
                "03/01/2023",
                "06/07/2023",
                "08/23/2023")
phase_labels = c("Phase 2", "Phase 3", paste("Phase 3.", 1:10, sep=""))


plot_variable_by_week_race <- function (variable, y = "", title = waiver(), phase_y = 0.80, y_upper = NA) {
  variable_by_week_race <- puf_all_weeks |>
    filter(metric == variable, geo_type == "national")
  
  
  p <- ggplot(variable_by_week_race, aes(x=week_num, y=mean, color = race_var, group = race_var)) +
    geom_vline(xintercept = phase_breaks, color = "gray", linetype="dashed") +
    geom_line() +
    geom_point() +
    scale_x_discrete(breaks=phase_breaks, labels = week_labels) +
    scale_y_continuous(labels = scales::percent) +
    scale_color_discrete(name = "Race") +
    labs(title = title,
         x = "Date",
         y = y) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  for (i in 1:12) {
    p <- p + annotate("text", x=phase_breaks[i], label=paste("\n", phase_labels[i], " Begins", sep=""), y=phase_y, colour="lightgrey", angle=90)
  }
  
  p  
}

plot_variable_by_week_race("food_insufficient",
                         y = "Food Insufficiency Rate",
                         title = "Share of adults in households where there was often or sometimes not enough\nfood in the past week, by race",
                         phase_y = 0.075)

plot_variable_by_week_race("depression_anxiety_signs",
                         y = "Depression/Anxiety Rate",
                         title = "Share of adults that experienced symptoms of depression or anxiety disorders\nin the past week (phases 2, 3, and 3.1) or in the last two weeks (phases 3.2-3.10)",
                         phase_y = 0.4)

read_file_raw("test.png")
