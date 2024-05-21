require(devtools)
install_version("survey", version = "4.0", repos = "http://cran.us.r-project.org")
install_version("srvyr", version = "1.0.0", repos = "http://cran.us.r-project.org")
library(tidyverse)
library(here)
library(srvyr)
library(survey)
library(fastDummies)
library(parallel)
library(future)
library(furrr)
library(data.table)
library(assertthat)

metrics <- c(
  "uninsured",
  "insured_public",
  "inc_loss",
  "expect_inc_loss",
  "rent_not_conf",
  "mortgage_not_conf",
  "food_insufficient",
  "depression_anxiety_signs",
  "spend_credit",
  "spend_ui",
  "spend_stimulus",
  "spend_savings",
  "spend_snap",
  "rent_caughtup",
  "mortgage_caughtup",
  "eviction_risk",
  "foreclosure_risk",
  "telework",
  "mentalhealth_unmet",
  "learning_fewer",
  "expense_dif"
)

# functions to calculate US total means/SEs
calculate_se_us_total <- function(metric, svy) {
  se_df <- svy %>%
    srvyr::filter(!is.na(!!sym(metric)))
  
  n_not_na <- se_df |>
    pull(!!sym(metric)) |> 
    length()
  
  # handle case where all NA
  if (n_not_na == 0) {
    return (
      se_df |> 
        group_by(week_num) |>
        summarize() |>
      mutate(
        mean = NA,
        se = NA,
        metric = metric,
        geography = "US",
        race_var = "total"
      ) |>
      select(week_num, geography, race_var, mean, se, metric)
    )
  }
  
  result <- se_df |>
    group_by(week_num) |> 
    summarise(mean = survey_mean(!!sym(metric), na.rm = T)) |>
    mutate(
      se = case_when(
        is.numeric(mean_se) ~ mean_se * 2,
        TRUE ~ 0),
      metric = metric,
      geography = "US",
      race_var = "total"
    ) |>
    select(week_num, geography, race_var, mean, se, metric)
  
  return(result)
}

generate_se_us_total <- function(df) {
  svy <- df |>
    as_survey_rep(
      repweights = dplyr::matches("pweight[0-9]+"),
      weights = pweight,
      type = "BRR",
      mse = TRUE
    )
  
  # calculate US-wide means for each metric/week
  # starting in week 34, don't include expect_inc_loss
  # starting in week 46, don't include rent_not_conf, mortgage_not_conf, mentalhealth_unmet
  metrics_total <- metrics[!metrics %in% c("telework", 
                                           "learning_fewer", 
                                           "expect_inc_loss",
                                           "rent_not_conf",
                                           "mortgage_not_conf",
                                           "mentalhealth_unmet")]
  us_total <- map_df(metrics_total, calculate_se_us_total, svy = svy)
  
  return (us_total)
}

year_from_week <- function (week_num) {
  case_when(week_num < 22 ~ 2020,
            week_num >= 22 & week_num < 41 ~ 2021,
            week_num >= 41 & week_num < 52 ~ 2022,
            week_num >= 52 & week_num < 64 ~ 2023,
            week_num >= 64 ~ 2024)
}

get_repwgt_filepath <- function (week_num) {
  year <- year_from_week(week_num)
  # week_num 52 repwgt file has wrong year, should be 2023
  year <- ifelse(week_num == 52, 2022, year)
  # in 2024, switches from weeks to cycles
  cycle_num_padded <- case_when(
    # week 64 is cycle 01, week 65 is cycle 02, etc.
    week_num >= 64 ~ str_pad(week_num - 63, width = 2, side = "left", pad = "0"),
    TRUE ~ ""
  )
  # in 2024, files distinguished by phase version (e.g. 4.0, 4.1)
  phase_version <- case_when(
    week_num >= 64 & week_num < 67 ~ 0,
    week_num >= 67 ~ 1,
    TRUE ~ NA_real_
  )
  phase_version_padded <- str_pad(phase_version, width = 2, side = "left", pad = "0")
  repwgt_filepath <- case_when(
    week_num < 64 ~ str_glue("data/raw-data/public_use_files/pulse{year}_repwgt_puf_{week_num}.csv"),
    week_num >= 64 ~ str_glue("data/raw-data/public_use_files/hps_04_{phase_version_padded}_{cycle_num_padded}_repwgt_puf.csv")
  )
  return(repwgt_filepath)
}

generate_us_total_se_for_weeks <- function(df, week_nums) {
  all_diff_ses_us_total <- list()
  
  for (week_num in week_nums) {
    print(str_glue("Week {week_num}"))
    
    # create directory if it doesn't exist
    dir.create("data/intermediate-data/week-us-total-ses", showWarnings = F)
    se_us_total_week_filepath <- str_glue("data/intermediate-data/week-us-total-ses/se_us_total_{week_num}.csv")
    
    # if already computed, read it from file and continue
    if(file.exists(se_us_total_week_filepath)) {
      se_us_total_week <- read_csv(se_us_total_week_filepath)
      all_diff_ses_us_total <- all_diff_ses_us_total |>
        append(list(as.data.table(se_us_total_week)))
      
      next
    }
    
    
    # get replicate weights for current week
    year <- year_from_week(week_num)
    # week_num 52 repwgt file has wrong year, should be 2023
    # get replicate weights for current week
    repwgt_filepath <- get_repwgt_filepath(week_num)
    repwgt <- read_csv(repwgt_filepath) %>%
      janitor::clean_names()
    
    week_str <- str_glue("wk{week_num}")
    
    # filter puf data to current week and join weights
    puf_cur_week <- df |>
      filter(week_num == week_str) |>
      left_join(repwgt, by = "scram")
       
    # computes totals
    start <- Sys.time()
    all_diff_ses_us_total_week <- generate_se_us_total(puf_cur_week)
    end <- Sys.time()
    print(end - start)
    
    all_diff_ses_us_total_week_dt <- all_diff_ses_us_total_week |>
      as.data.table()
    
    # write to file
    write_csv(all_diff_ses_us_total_week_dt, se_us_total_week_filepath)
    
    # store in list
    all_diff_ses_us_total <- all_diff_ses_us_total |> 
      append(list(all_diff_ses_us_total_week_dt))
  }
  
  return(rbindlist(all_diff_ses_us_total))
}

puf_all_weeks <- read_csv("data/intermediate-data/puf_formatted.csv")
us_total_ses <- generate_us_total_se_for_weeks(puf_all_weeks, 13:67)

write_csv(us_total_ses, "data/intermediate-data/phase2_all_us_total_ses.csv")
