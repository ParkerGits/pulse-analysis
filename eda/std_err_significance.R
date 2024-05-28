library(tidyverse)
library(here)

std_err_significance <- read_csv("data/final-data/phase2_all.csv")


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

all_races <- c("white", "black", "hispanic", "other", "asian")
plot_estimates_for_var_state_time <- function(data, var, state, week_nums = 13:63, race_vars = all_races, title = waiver(), y_lab = "") {
  filtered_week_nums = str_glue("wk{week_nums}")
  week_step <- ceiling(length(filtered_week_nums)/10)
  week_seq = seq(1, length(filtered_week_nums), week_step)
  print(week_seq)
  week_breaks = filtered_week_nums[week_seq]
  week_labels = data |> 
    filter(week_num %in% week_breaks) |> 
    pull(date_int) |> 
    unique()

  data |>
    filter(geography == state, metric == var, week_num %in% filtered_week_nums, race_var %in% race_vars) |>
    ggplot(aes(x=week_num, y=mean, color=race_var, fill=race_var, group=race_var)) +
    geom_line() +
    geom_point() +
    geom_ribbon(aes(ymin=moe_95_lb, ymax=moe_95_ub), alpha = 0.5) +
    scale_x_discrete(breaks=week_breaks, labels=week_labels) +
    scale_y_continuous(labels=scales::percent) +
    scale_fill_manual(name = "Race", breaks = all_races, values = scales::brewer_pal(type = "qual", palette = "Dark2")(6)) +
    scale_color_manual(name="Race", breaks = all_races, values = scales::brewer_pal(type = "qual", palette = "Dark2")(6)) +
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
                             week_num = 13:67,
                             title = "Mean share of adults in households where there was often or sometimes not enough food\nin the past week by Race, per Week",
                             y_lab="Food Insufficiency Rate")

plot_estimates_for_var_state_time(std_err_significance,
                             "expense_dif",
                             "WA",
                             week_nums = 13:63,
                             race_vars = c("white", "hispanic", "black"),
                             title = "Mean share of adults that experienced difficulty paying household expenses in past 7 days\nby Race, per Week",
                             y_lab="Expense Difficulty Rate")


usa_sf <- function() {
  sf_path <- here("data", "states_sf.rda")
  us <- read_rds(sf_path)

  # 4326 for laea
  return(sf::st_transform(us, crs = 4326))
}

national_title_list <- list(
  depression_aniexty_signs = "have shown depression or anxiety signs",
  eviction_risk = "are at risk of being evicted",
  expect_inc_loss = "are expected to lose income",
  expense_dif = "have had difficulty paying for usual household expenses",
  food_insufficient = "have had food insufficiencies",
  foreclosure_risk = "are at risk of being foreclosed",
  inc_loss = "have had a decrease in income",
  inc_loss_rv = "have had a decrease in income",
  insured_public = "have public insurance",
  learning_fewer = "have had kids with classes canceled",
  mentalhealth_unmet = "feel have unmet mental health needs",
  mortgage_caughtup = "are caught up on their mortgage(s)",
  mortgage_not_conf = "are not confident about being able to pay their next mortgage",
  rent_caughtup = "are caught up on their rent",
  rent_not_conf = "are not confident about being able to pay their next rent",
  spend_credit = "have used credit cards or loans spending to meet their weekly needs in the past 7 days",
  spend_savings = "have used savings money to meet their weekly needs in the past 7 days",
  spend_snap = "have used food stamps in the in the past 7 days",
  spend_stimulus = "have used stimulus checks to meet their weekly needs in the past 7 days",
  spend_ui = "have used unemployment benefits to meet their weekly needs in the past 7 days",
  telework = "have had in-person work moved online",
  uninsured = "are uninsured"
)

std_err_significance |>
  filter(metric == "food_insufficient") |>
  pull(mean) |>
  summary()

us_states <- usa_sf()

plot_state_map <- function(race, week, variable) {
  week_str <- str_glue("wk{week}")
  data_metric <- std_err_significance |>
    filter(metric == variable) 
  
  summary_breaks <- data_metric |>
    pull(mean) |>
    summary() |>
    unname() |>
    as.numeric()
  
  data <- data_metric |>
    filter(week_num == week_str, race_var == race) |>
    left_join(us_states, c('geography'='iso_3166_2'))

  my_map_theme <- function(){
    theme(panel.background=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank(),
          legend.position="bottom")
  }

  graph <- data %>%
    mutate(average = round(mean, digits = 4)*100) %>%
    ggplot() +
    geom_sf(aes(fill = mean, geometry = geometry),color = 'black') +
    scale_fill_gradient2(element_blank(), low = "#D7191C", mid = "#FFFFBF", high = "#2C7BB6", midpoint = summary_breaks[3], breaks = summary_breaks, limits = c(summary_breaks[1],summary_breaks[5]), labels = scales::percent)+
    my_map_theme() +
    labs(title = paste('Percentage of people who', national_title_list[[variable]]))

  graph
}

plot_state_map("white", 45, "food_insufficient")
std_err_significance |>
  filter(metric == "food_insufficient", week_num == "wk13", geography == "US") |>
  pull(mean)
