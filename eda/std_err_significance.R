std_err_significance <- read_csv("data/final-data/phase2_wk63.csv")

plot_estimates_for_var_state <- function(data, var, state, title = waiver(), y_lab = "") {
  week_breaks = data |> pull(week_num)
  week_labels = data |> pull(date_int)
  data |> 
    filter(geography == state, metric == var, race_var != "total") |>
    ggplot(aes(x=week_num, y=mean, fill=race_var)) +
      geom_bar(stat="identity", color="black", position=position_dodge()) +
      geom_errorbar(aes(ymin=moe_95_lb, ymax=moe_95_ub), width=.2, position=position_dodge(.9)) +
      scale_x_discrete(breaks=week_breaks, labels=week_labels) +
      scale_fill_discrete(name = "Race") + 
      labs(x = "Week",
           y = y_lab,
           title = title)
}

plot_estimates_for_var_state(std_err_significance, "food_insufficient", "WA", title = "Mean food insufficiency rate by Race, per Week", y_lab="Mean Food Insufficient")
plot_estimates_for_var_state(std_err_significance, "depression_anxiety_signs", "WA", title = "Mean share of adults that experienced symptoms of depression or anxiety disorders\nin the last week by Race, per Week", y_lab="Mean Depression/Anxiety Rate")
