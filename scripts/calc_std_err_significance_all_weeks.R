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

other_cols <- c(
  "cbsa_title",
  "state",
  "hisp_rrace",
  "week_num"
)

race_indicators <- c("black", "asian", "hispanic", "white", "other")

all_cols <- c(metrics, other_cols)

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

puf_all_weeks <- read_format_puf()

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

ses <- generate_se_for_weeks(puf_all_weeks, 13:63)
ses_moe <- ses |>
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
)

# variables removed between start of questionnaire two and phase 3.5
phase_3_5_rem_metric <- c("inc_loss",
                          "telework",
                          "learning_fewer",
                          "expect_inc_loss",
                          "rent_not_conf",
                          "mortgage_not_conf",
                          "mentalhealth_unmet")

# create data for feature with combined inc_loss and inc_loss_rv metric
data_out_feature <- left_join(moe_ses, week_crosswalk, by = "week_num")

inc_loss_rv <- data_out_feature %>%
  filter(metric == "inc_loss") %>%
  mutate(metric = "inc_loss_rv")

data_out <- rbind(data_out_feature, inc_loss_rv) %>%
  mutate(mean = if_else((metric == "inc_loss"), NA_real_, mean ),
         se = if_else((metric == "inc_loss"), 0, se ),
         moe_95 = if_else((metric == "inc_loss"), 0, moe_95),
         moe_95_lb = if_else((metric == "inc_loss"), NA_real_, moe_95_lb),
         moe_95_ub = if_else((metric == "inc_loss"), NA_real_, moe_95_ub),
         sigdiff= if_else((metric == "inc_loss"), NA_real_, sigdiff),
         var_removed = case_when((metric %in% phase_3_5_rem_metric)  ~ 1,
                                 TRUE ~ 0)
  )

data_out <- data_out %>%
  arrange(metric, race_var, geography,
          factor(week_num,
                 levels = week_crosswalk$week_num))

write_csv(data_out, "data/final-data/phase2_all_ses_moe.csv")
