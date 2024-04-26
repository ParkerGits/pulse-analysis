std_err_significance <- read_csv("data/final-data/phase2_all_ses_moe.csv")

plot_estimates_for_var_state <- function(data, var, state, week_nums = 13:63, race_vars = c("white", "black", "hispanic", "other", "asian"), title = waiver(), y_lab = "") {
  week_breaks = data |> pull(week_num)
  week_labels = data |> pull(date_int)
  filtered_week_nums = str_glue("wk{week_nums}")
  data |> 
    filter(geography == state, metric == var, race_var %in% race_vars, week_num %in% filtered_week_nums) |>
    ggplot(aes(x=week_num, y=mean, fill=race_var)) +
      geom_bar(stat="identity", color="black", position=position_dodge()) +
      geom_errorbar(aes(ymin=moe_95_lb, ymax=moe_95_ub), width=.2, position=position_dodge(.9)) +
      scale_x_discrete(breaks=week_breaks, labels=week_labels) +
      scale_fill_discrete(name = "Race") + 
      labs(x = "Week",
           y = y_lab,
           title = title)
}

plot_estimates_for_var_state(std_err_significance, 
                             "food_insufficient", 
                             "WA", 
                             week_num = 13:16, 
                             title = "Mean share of adults in households where there was often or sometimes not enough food\nin the past week by Race, per Week", 
                             y_lab="Food Insufficiency Rate")

plot_estimates_for_var_state(std_err_significance,
                             "depression_anxiety_signs",
                             "WA",
                             week_nums = 13:16,
                             title = "Mean share of adults that experienced symptoms of depression or anxiety disorders\nin the last week by Race, per Week",
                             y_lab="Depression/Anxiety Rate")

plot_estimates_for_var_state(std_err_significance,
                             "expense_dif",
                             "WA",
                             week_nums = 13:20,
                             title = "Mean share of adults that experienced difficulty paying household expenses in past 7 days\nby Race, per Week",
                             y_lab="Expense Difficulty Rate")

plot_estimates_for_var_state(std_err_significance,
                             "expense_dif",
                             "WA",
                             week_nums = 13:20,
                             race_vars = c("white", "black"),
                             title = "Mean share of adults that experienced difficulty paying household expenses in past 7 days\nby Race, per Week",
                             y_lab="Expense Difficulty Rate")


plot_estimates_for_var_state_time <- function(data, var, state, week_nums = 13:63, race_vars = c("white", "black", "hispanic", "other", "asian"), title = waiver(), y_lab = "") {
  week_breaks = data |> pull(week_num)
  week_labels = data |> pull(date_int)
  filtered_week_nums = str_glue("wk{week_nums}")
  data |> 
    filter(geography == state, metric == var, week_num %in% filtered_week_nums, race_var %in% race_vars) |>
    ggplot(aes(x=week_num, y=mean, color=race_var, fill=race_var, group=race_var)) +
    geom_line() +
    geom_point() +
    geom_ribbon(aes(ymin=moe_95_lb, ymax=moe_95_ub), alpha = 0.5) +
    scale_x_discrete(breaks=week_breaks, labels=week_labels) +
    scale_fill_discrete(name = "Race") + 
    scale_color_discrete(name="Race") +
    labs(x = "Week",
         y = y_lab,
         title = title)
}

# race/metric combinations with the most instances of significant difference?
std_err_significance |> 
  group_by(race_var, metric) |> 
  summarize(n_sigdiff = sum(sigdiff, na.rm=T)) |> 
  arrange(desc(n_sigdiff))

plot_estimates_for_var_state_time(std_err_significance, 
                             "food_insufficient", 
                             "WA", 
                             week_num = 13:63, 
                             race_vars = c("white", "hispanic"),
                             title = "Mean share of adults in households where there was often or sometimes not enough food\nin the past week by Race, per Week", 
                             y_lab="Food Insufficiency Rate")
    
plot_estimates_for_var_state_time(std_err_significance,
                             "expense_dif",
                             "WA",
                             week_nums = 13:63,
                             race_vars = c("white", "hispanic", "black"),
                             title = "Mean share of adults that experienced difficulty paying household expenses in past 7 days\nby Race, per Week",
                             y_lab="Expense Difficulty Rate")

