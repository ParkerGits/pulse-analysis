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


get_se_diff <- function(..., svy) {
  # Function to calculate all means/SEs and mean/SEs of the difference between
  # racial group mean and all other racial group mean for a given geography/race/
  # metric/week combinations (except US, which is handled separately)
  # INPUT:
  #    ...: Must be a dataframe with the following columns:
  #     metric, race_indicator(dummy race var), geography, week.
  #    svy: must be an object of the class tbl_svy returned by as_survey_rep()
  # OUTPUT:
  #    result: tibble containing mean mean/SE for the given geography/race
  #    metric/week combination, plus mean/SE for all other races and mean/SE for
  #    the difference between the given race and all other races
  dots <- list(...)
  
  metric_formula <- as.formula(paste0("~", dots$metric))
  race_formula <- as.formula(paste0("~", dots$race_indicator))
  
  
  #compare subgroup to geography avg
  
  # Use trycatch bc there are 4 metric-week-geogarphy combinations
  # where there are 0 respondents which return NA and error out
  result <- tryCatch(
    {
      # Use svyby to compute mean (and replicate means) for race and non race var population
      # (ie black and nonblack population)
      x <- svyby(metric_formula, race_formula, svy,
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
      )
    },
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

generate_se_state_and_cbsas <- function(metrics, race_indicators, df) {
  # Wrapper function to calculate all means/SEs and mean/SEs of the difference between
  # racial group mean and all other racial group mean for all geography/race/
  # metric/week combinations (except US, which is handled separately)
  # INPUT:
  #    metrics: vector of metric column name strings
  #    race_indicator: vector of race dummy column name strings
  #    svy: must be an object of the class tbl_svy returned by as_survey_rep()
  # OUTPUT:
  #    full_combo_appended: dataframe with mean/SE for each geography/race
  #    metric/week combination, plus mean/SE for all other races and mean/SE for
  #    the difference between the given race and all other races
  
  
  svy <- df |>
    as_survey_rep(
      repweights = dplyr::matches("pweight[0-9]+"),
      weights = pweight,
      type = "BRR",
      mse = TRUE
    )
  
  wk <- svy |>
    pull(week_num) |>
    unique() |>
    na.omit()
  
  geo <- svy |>
    pull(geography) |>
    unique() |>
    na.omit()
  
  geo_type <- svy |>
    pull(geo_type) |>
    unique() |>
    na.omit()
  
  # Create grid of all metric/race combos for the geo/week dataframe
  full_combo <- expand_grid(
    metric = metrics,
    race_indicator = race_indicators
  )
  
  #for testing (as running on all combinations takes up too much RAM)
  #full_combo = full_combo |>
  #   filter(metric %in% c("telework"))
  
  # get mean and se for diff bw subgroup and (total population -subgroup)
  # Call the get_se_diff function on every row of full_combo
  se_info <- full_combo |> pmap_df(get_se_diff, svy = svy)
  full_combo_appended <- full_combo |>
    bind_cols(se_info) |>
    mutate(geo_type = geo_type,
           geography = geo,
           week_num = wk)
  
  return(full_combo_appended)
}

year_from_week <- function (week_num) {
  case_when(week_num < 22 ~ 2020,
            week_num >= 22 & week_num < 41 ~ 2021,
            week_num >= 41 & week_num < 52 ~ 2022,
            week_num >= 52 & week_num <= 63 ~ 2023)
}

read_format_puf <- function() {
  ##  Read in and clean data
  puf_all_weeks <- read_csv(here("data/intermediate-data", "pulse_puf2_all_weeks.csv")) |>
    mutate(spend_credit = as.numeric(spend_credit),
           spend_savings = as.numeric(spend_savings),
           spend_stimulus = as.numeric(spend_stimulus),
           spend_ui = as.numeric(spend_ui),
           inc_loss = as.numeric(inc_loss),
           inc_loss_rv = as.numeric(inc_loss_rv),
    #create combined inc_loss variable for efficient processing
    inc_loss = case_when(week_x >= 28 ~ inc_loss_rv,
                         TRUE ~ inc_loss),
    tbirth_year = as.numeric(tbirth_year),
    # For the uninsured variable, we filter out people over 65 from the denominator
    insured_public = case_when(
        tbirth_year < 1956 ~ NA_real_,
        TRUE ~ as.numeric(insured_public)
      ),
    uninsured = case_when(
        tbirth_year < 1956 ~ NA_real_,
        TRUE ~ as.numeric(uninsured)
      ),
    insured_public = case_when(
        tbirth_year < 1956 ~ NA_real_,
        TRUE ~ as.numeric(insured_public)
      ),
    uninsured = case_when(
        tbirth_year < 1956 ~ NA_real_,
        TRUE ~ as.numeric(uninsured)
      )) |>
    select(all_cols, scram, pweight) |>
    janitor::clean_names() |>
    # Add race indicator variables for easy use with survey package
    mutate(
      black = case_when(
        str_detect(hisp_rrace, "Black alone") ~ 1,
        TRUE ~ 0
      ),
      white = case_when(
        str_detect(hisp_rrace, "White") ~ 1,
        TRUE ~ 0
      ),
      hispanic = case_when(
        str_detect(hisp_rrace, "Latino") ~ 1,
        TRUE ~ 0
      ),
      asian = case_when(
        str_detect(hisp_rrace, "Asian") ~ 1,
        TRUE ~ 0
      ),
      other = case_when(
        str_detect(hisp_rrace, "Two or") ~ 1,
        TRUE ~ 0
      )
    )
}


generate_se_for_weeks <- function(df, week_nums) {
  all_diff_ses <- list()
  
  for (week_num in week_nums) {
    print(str_glue("Week {week_num}"))
    
    # create directory if it doesn't exist
    dir.create("data/intermediate-data/week-ses", showWarnings = F)
    se_week_filepath <- str_glue("data/intermediate-data/week-ses/se_{week_num}.csv")
    
    # if already computed, read it from file and continue
    if(file.exists(se_week_filepath)) {
      se_week <- read_csv(se_week_filepath)
      all_diff_ses <- all_diff_ses |>
        append(list(as.data.table(se_week)))
      
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
    
    # generate all_list
    state_list <- puf_cur_week %>%
      mutate(geography = state,
             geo_type = "state") %>%
      split(list(puf_cur_week$state, puf_cur_week$week_num))
    cbsa_list <- puf_cur_week %>%
      mutate(geography = cbsa_title,
             geo_type = "msa") %>%
      split(list(puf_cur_week$cbsa_title, puf_cur_week$week_num))
    all_list <- c(state_list, cbsa_list)
    
    # computes ses
    start <- Sys.time()
    plan(multisession, workers = parallel::detectCores() - 2)
    all_diff_ses_week <- future_map_dfr(all_list,
                                   ~generate_se_state_and_cbsas(metrics = metrics,
                                                                race_indicators = race_indicators,
                                                                df = .x))
    end <- Sys.time()
    print(end - start)
    
    all_diff_ses_week_dt <- all_diff_ses_week |>
      as.data.table()
    
    # write to file
    write_csv(all_diff_ses_week_dt, se_week_filepath)
    
    # store in list
    all_diff_ses <- all_diff_ses |> 
      append(list(all_diff_ses_week_dt))
  }
  
  return(rbindlist(all_diff_ses))
}

puf_all_weeks <- read_csv("data/intermediate-data/puf_formatted.csv")
ses <- generate_se_for_weeks(puf_all_weeks, 13:63)

write_csv(ses, "data/intermediate-data/phase2_all_ses.csv")

