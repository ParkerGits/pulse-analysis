ses <- read_csv(here("data/intermediate-data", "phase2_all_ses.csv"))
total_ses <- read_csv(here("data/intermediate-data", "phase2_all_total_ses.csv"))

all_ses <- rbind(ses, total_ses)
write_csv(all_ses, "data/intermediate-data/all_ses.csv")

us_ses <- read_csv(here("data/intermediate-data", "phase2_all_us_ses.csv"))
us_total_ses <- read_csv(here("data/intermediate-data", "phase2_all_us_total_ses.csv"))

all_ses_moe <- all_ses |>
  mutate(
    moe_95 = se * 1.96,
    moe_95_lb = mean - moe_95,
    moe_95_ub = mean + moe_95,
    sigdiff = ifelse(abs(diff_mean / diff_se) > 1.96, 1, 0)
  ) |>
  rename(
    race_var = race_indicator
  ) |>
  select(-other_mean, -other_se, -diff_mean, -diff_se)

us_ses_moe <- us_ses |>
  mutate(
    moe_95 = se * 1.96,
    moe_95_lb = mean - moe_95,
    moe_95_ub = mean + moe_95,
    sigdiff = ifelse(abs(diff_mean / diff_se) > 1.96, 1, 0)
  ) |>
  rename(
    race_var = race_indicator,
    week_num = week
  ) |>
  select(-other_mean, -other_se, -diff_mean, -diff_se)


us_total_ses_moe <- us_total_ses |>
  mutate(
    moe_95 = se * 1.96,
    moe_95_lb = mean - moe_95,
    moe_95_ub = mean + moe_95,
    geo_type = "national"
  ) %>%
  select(geography, metric, week_num, race_var, mean, se, moe_95, moe_95_lb, moe_95_ub, geo_type)


data_all <- bind_rows(all_ses_moe, us_ses_moe, us_total_ses_moe)

week_crosswalk <- tibble::tribble(
  ~week_num, ~date_int,
  "wk13", paste("8/19/20\u2013", "8/31/20", sep = ""),
  "wk14", paste("9/2/20\u2013", "9/14/20", sep = ""),
  "wk15", paste("9/16/20\u2013", "9/28/20", sep = ""),
  "wk16", paste("9/30/20\u2013", "10/12/20", sep = ""),
  "wk17", paste("10/14/20\u2013", "10/26/20", sep = ""),
  "wk18", paste("10/28/20\u2013", "11/9/20", sep = ""),
  "wk19", paste("11/11/20\u2013", "11/23/20", sep = ""),
  "wk20", paste("11/25/20\u2013", "12/7/20", sep = ""),
  "wk21", paste("12/9/20\u2013", "12/21/20", sep = ""),
  "wk22", paste("1/6/21\u2013", "1/18/21", sep = ""),
  "wk23", paste("1/20/21\u2013", "2/1/21", sep = ""),
  "wk24", paste("2/3/21\u2013", "2/15/21", sep = ""),
  "wk25", paste("2/17/21\u2013", "3/1/21", sep = ""),
  "wk26", paste("3/3/21\u2013", "3/15/21", sep = ""),
  "wk27", paste("3/17/21\u2013", "3/29/21", sep = ""),
  "wk28", paste("4/14/21\u2013", "4/26/21", sep = ""),
  "wk29", paste("4/28/21\u2013", "5/10/21", sep = ""),
  "wk30", paste("5/12/21\u2013", "5/24/21", sep = ""),
  "wk31", paste("5/26/21\u2013", "6/7/21", sep = ""),
  "wk32", paste("6/9/21\u2013", "6/21/21", sep = ""),
  "wk33", paste("6/23/21\u2013", "7/5/21", sep = ""),
  "wk34", paste("7/21/21\u2013", "8/2/21", sep = ""),
  "wk35", paste("8/4/21\u2013", "8/16/21", sep = ""),
  "wk36", paste("8/18/21\u2013", "8/30/21", sep = ""),
  "wk37", paste("9/1/21\u2013", "9/13/21", sep = ""),
  "wk38", paste("9/15/21\u2013", "9/27/21", sep = ""),
  "wk39", paste("9/29/21\u2013", "10/11/21", sep = ""),
  "wk40", paste("12/1/21\u2013", "12/13/21", sep = ""),
  "wk41", paste("12/29/21\u2013", "1/10/22", sep = ""),
  "wk42", paste("1/26/22\u2013", "2/7/22", sep = ""),
  "wk43", paste("3/2/22\u2013", "3/14/22", sep = ""),
  "wk44", paste("3/30/22\u2013", "4/11/22", sep = ""),
  "wk45", paste("4/27/22\u2013", "5/9/22", sep = ""),
  "wk46", paste("6/1/22\u2013", "6/13/22", sep = ""),
  "wk47", paste("6/29/22\u2013", "7/11/22", sep = ""),
  "wk48", paste("7/27/22\u2013", "8/8/22", sep = ""),
  "wk49", paste("9/14/22\u2013", "9/28/22", sep = ""),
  "wk50", paste("10/5/22\u2013", "10/17/22", sep = ""),
  "wk51", paste("11/2/22\u2013", "11/14/22", sep = ""),
  "wk52", paste("12/9/22\u2013", "12/19/22", sep = ""),
  "wk53", paste("1/4/23\u2013", "1/16/23", sep = ""),
  "wk54", paste("2/1/23\u2013", "2/13/23", sep = ""),
  "wk55", paste("3/1/23\u2013", "3/13/23", sep = ""),
  "wk56", paste("3/29/23\u2013", "4/10/23", sep = ""),
  "wk57", paste("4/26/23\u2013", "5/8/23", sep = ""),
  "wk58", paste("6/7/23\u2013", "6/19/23", sep = ""),
  "wk59", paste("6/28/23\u2013", "7/10/23", sep = ""),
  "wk60", paste("7/26/23\u2013", "8/7/23", sep = ""),
  "wk61", paste("8/23/23\u2013", "9/4/23", sep = ""),
  "wk62", paste("9/20/23\u2013", "10/2/23", sep = ""),
  "wk63", paste("10/18/23\u2013", "10/30/23", sep = ""),
  "wk64", paste("01/09/24\u2013", "02/05/24", sep = ""),
  "wk65", paste("02/06/24\u2013", "03/04/24", sep = ""),
  "wk66", paste("03/05/24\u2013", "04/01/24", sep = ""),
  "wk67", paste("04/02/24\u2013", "04/29/24", sep = "")
)

# create data for feature with combined inc_loss and inc_loss_rv metric
data_out_feature <- left_join(data_all, week_crosswalk, by = "week_num")


# variables removed between start of questionnaire two and phase 3.5
phase_3_5_rem_metric <- c("inc_loss",
                          "telework",
                          "learning_fewer",
                          "expect_inc_loss",
                          "rent_not_conf",
                          "mortgage_not_conf",
                          "mentalhealth_unmet")

data_out <- data_out_feature |>
  mutate(
    var_removed = case_when((metric %in% phase_3_5_rem_metric)  ~ 1,
                            TRUE ~ 0)
  ) |>
  arrange(metric, race_var, geography,
          factor(week_num,
                 levels = week_crosswalk$week_num))

# combine inc_loss with inc_loss_rv for feature
inc_loss_rv <- data_out_feature %>%
  filter(metric == "inc_loss") %>%
  mutate(metric = "inc_loss_rv")
data_out <- rbind(data_out_feature, inc_loss_rv) |>
  filter(metric != "inc_loss")


dir.create("data/final-data", showWarnings = F)

write_csv(data_out, here("data/final-data", "phase2_all.csv"))
