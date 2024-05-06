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

get_se_diff_us <- function(..., svy) {
  # Function to calculate all means/SEs and mean/SEs of the difference between
  # racial group mean and all other racial group mean for a given race/
  # metric/week combination for the US
  # INPUT:
  #    ...: Must be a dataframe with the following columns:
  #     metric, race_indicator(dummy race var), week.
  #    svy: must be an object of the class tbl_svy returned by as_survey_rep()
  # OUTPUT:
  #    result: tibble containing mean mean/SE for the given race metric/week
  #    combination for the US, plus mean/SE for all other races and mean/SE for
  #    the difference between the given race and all other races
  dots <- list(...)
  
  metric_formula <- as.formula(paste0("~", dots$metric))
  race_formula <- as.formula(paste0("~", dots$race_indicator))
  
  result <- tryCatch(
    {
      x <- svyby(metric_formula, race_formula, svy %>%
                   srvyr::filter(week_num == dots$week),
                 svymean,
                 na.rm = T,
                 return.replicates = T,
                 covmat = T
      )
      
      mean <- x %>%
        filter(!!sym(dots$race_indicator) == 1) %>%
        pull(!!sym(dots$metric))
      se <- x %>%
        filter(!!sym(dots$race_indicator) == 1) %>%
        pull(se) * 2
      other_mean <- x %>%
        filter(!!sym(dots$race_indicator) == 0) %>%
        pull(!!sym(dots$metric))
      other_se <- x %>%
        filter(!!sym(dots$race_indicator) == 0) %>%
        pull(se)
      
      # Use svycontrast to calulate se bw race and nonrace (ie black and non black) population
      contrast <- svycontrast(x, contrasts = list(diff = c(1, -1)))
      diff_mean <- contrast %>% as.numeric()
      diff_se <- contrast %>%
        attr("var") %>%
        sqrt() %>%
        {
          . * 2
        }
      
      result <- tibble(
        mean = mean,
        se = se,
        other_mean = other_mean,
        other_se = other_se,
        diff_mean = diff_mean,
        diff_se = diff_se
      )},
    error = function(err) {
      # handle case where all NA responses for a given metric/geo/week/race
      data <- tibble(
        mean = NA,
        se = 0,
        other_mean = NA,
        other_se = 0,
        diff_mean = 0,
        diff_se = 0
      )
      return(data)
    }
  )
  return(result)
}


generate_se_us <- function(metrics, race_indicators, svy) {
  # Wrapper function to calculate all means/SEs and mean/SEs of the difference between
  # racial group mean and all other racial group mean for all race/metric/week
  # combinations for the united states
  # INPUT:
  #    metrics: vector of metric column name strings
  #    race_indicator: vector of race dummy column name strings
  #    svy: must be an object of the class tbl_svy returned by as_survey_rep()
  # OUTPUT:
  #    full_combo_appended: dataframe with mean/SE for each race/metric/week
  #    combination for the US, plus mean/SE for all other races and mean/SE for
  #    the difference between the given race and all other races
  
  wks <- svy %>%
    pull(week_num) %>%
    unique() %>%
    na.omit()
  
  #race_indicators <- race_indicators[-6]
  
  full_combo <- expand_grid(
    metric = metrics,
    race_indicator = race_indicators,
    week = wks
  )
  
  # get mean and se for diff bw subgroup and (total population -subgroup)
  se_info <- full_combo %>% pmap_df(get_se_diff_us, svy = svy)
  
  full_combo_appended <- full_combo %>%
    bind_cols(se_info) %>%
    mutate(
      geo_type = "national",
      geography = "US"
    )
  
  return(full_combo_appended)
}

year_from_week <- function (week_num) {
  case_when(week_num < 22 ~ 2020,
            week_num >= 22 & week_num < 41 ~ 2021,
            week_num >= 41 & week_num < 52 ~ 2022,
            week_num >= 52 & week_num <= 63 ~ 2023)
}

generate_us_se_for_weeks <- function(df, week_nums) {
  all_diff_ses_us <- list()
  
  for (week_num in week_nums) {
    print(str_glue("Week {week_num}"))
    
    # create directory if it doesn't exist
    dir.create("data/intermediate-data/week-us-ses", showWarnings = F)
    se_us_week_filepath <- str_glue("data/intermediate-data/week-us-ses/se_us_{week_num}.csv")
    
    # if already computed, read it from file and continue
    if(file.exists(se_us_week_filepath)) {
      se_us_week <- read_csv(se_us_week_filepath)
      all_diff_ses_us <- all_diff_ses_us |>
        append(list(as.data.table(se_us_week)))
      
      next
    }
    
    
    # get replicate weights for current week
    week_str <- str_glue("wk{week_num}")
    year <- year_from_week(week_num)
    # week_num 52 repwgt file has wrong year, should be 2023
    year <- ifelse(week_num == 52, 2022, year)
    rep_wt_filepath <- str_glue("data/raw-data/public_use_files/pulse{year}_repwgt_puf_{week_num}.csv")
    rep_wt <- read_csv(rep_wt_filepath) %>%
      janitor::clean_names()
    
    # filter puf data to current week and join weights
    puf_cur_week <- df |>
      filter(week_num == week_str) |>
      left_join(rep_wt, by = "scram")
    
    #Set BRR survey design and specify replicate weights
    svy_all <- puf_cur_week %>%
      as_survey_rep(
        repweights = dplyr::matches("pweight[0-9]+"),
        weights = pweight,
        type = "BRR",
        mse = TRUE
      )
    
    # computes ses
    start <- Sys.time()
    all_diff_ses_us_week <- generate_se_us(metrics = metrics, race_indicators = race_indicators, svy = svy_all)
    end <- Sys.time()
    print(end - start)
    
    all_diff_ses_us_week_dt <- all_diff_ses_us_week |>
      as.data.table()
    
    # write to file
    write_csv(all_diff_ses_us_week_dt, se_us_week_filepath)
    
    # store in list
    all_diff_ses_us <- all_diff_ses_us |> 
      append(list(all_diff_ses_us_week_dt))
  }
  
  return(rbindlist(all_diff_ses_us))
}

puf_all_weeks <- read_csv("data/intermediate-data/puf_formatted.csv")
us_ses <- generate_us_se_for_weeks(puf_all_weeks, 13:63)

write_csv(us_ses, "data/intermediate-data/phase2_all_us_ses.csv")
