puf_all_weeks <- read_csv("data/intermediate-data/pulse_puf2_all_weeks.csv")

phase_breaks = c("wk13", "wk18", "wk28", "wk34", t(distinct(food_insufficient_by_week_race["week_num"]))[seq(28,50,3)])
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


plot_food_insufficient_by_week_race <- function () {
  food_insufficient_by_week_race <- puf_all_weeks |>
    group_by(week_num, hisp_rrace) %>%
    summarize(mean_food_insufficient = mean(food_insufficient, na.rm = T))
  
  p <- ggplot(food_insufficient_by_week_race, aes(x=week_num, y=mean_food_insufficient, color = hisp_rrace, group = hisp_rrace)) +
    geom_vline(xintercept = phase_breaks, color = "lightgrey", linetype="dashed") +
    geom_line() +
    scale_x_discrete(breaks=phase_breaks, labels = week_labels) +
    scale_y_continuous(labels = scales::percent) +
    scale_color_discrete(name = "Race") +
    labs(title = "Share of adults in households where there was often or sometimes not enough food in the past week, by race",
         x = "Date",
         y = "Percent Food Insufficient")
  
  for (i in 1:12) {
    p <- p + annotate("text", x=phase_breaks[i], label=paste("\n", phase_labels[i], " Begins", sep=""), y=0.10, colour="lightgrey", angle=90)
  }
  
  p  
}

plot_food_insufficient_by_week_race()
  
      

