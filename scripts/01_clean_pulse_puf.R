# Generate cleaned Public Use File according to UrbanInstitute variables
library(tidyverse)
library(readxl)
library(testit)
library(tigris)
library(stringr)
library(httr)
library(here)
library(janitor)
options(timeout = 200)

ui_vars <- c(
  # numeric week
  "week_x",
  # year
  "year",
  # added by UI
  "week_num",
  "hisp_rrace",
  "uninsured",
  "insured_public",
  "inc_loss",
  "inc_loss_rv",
  "expect_inc_loss",
  "payment_not_conf",
  "rent_not_conf",
  "mortgage_not_conf",
  "rent_caughtup",
  "mortgage_caughtup",
  "food_insufficient",
  "spend_savings",
  "spend_credit",
  "spend_ui",
  "spend_stimulus",
  "anxious_score",
  "worry_score",
  "interest_score",
  "down_score",
  "anxiety_signs",
  "depression_signs",
  "depression_anxiety_signs",
  "expense_dif",
  "telework",
  "metalhealth_unmet",
  "eviction_risk",
  "foreclosure_risk",
  "learning_fewer",
  "spend_snap",
  "week_num",
  "state",
  "state_name",
  "csa_title",
  "cbsa_title",
  # not added but included in UI analyses
  "mentalhealth_unmet",
  "tenure",
  "tbirth_year",
  "scram",
  "pweight"
)

download_and_clean_puf_data <- function(week_num, vars = ui_vars, output_filepath = "data/raw-data/public_use_files/") {
  # Function to download in Pulse Public Use File for a given week, and add:
  #   1) cleaned Non Hispanic Race variable, (hisp_rrace)
  #   2) MSA and state names (cbsa_title  and state_name)
  #   3) a week number variable (week_num)
  #   4) indicator variable for uninsured persons (uninsured)
  #   5) indicator variable for publicly insured persons (insured_public)
  #   6) indicator variable for if a person has experienced loss in employment income (inc_loss)
  #   7) indicator variable for if a person expects a loss in employment income (expect_inc_loss)
  #   8) indicator variable for if a person has low to no confidence in paying rent next month or has already deferred (rent_not_conf)
  #   9) indicator variable for if a person has low to no confidence in paying mortgage next month or has already deferred (mortgage_not_conf)
  #   10)joint indicator variable for if a person has either 8 or 9, (payment_not_conf)
  #   11)adjusted score columns for the mental health questions
  #   12)indicator variable for if a person displays signs of anxiety (anxiety_signs)
  #   13)indicator variable for if a person displays signs of depression (depression_signs)
  #   14) indicator variable for if a person is caught up on rent payments (rent_caughtup)
  #   15) indicator variable for if a person is caught up on mortgage payments (mortgage_caughtup)
  #   16) indicator variable for if a person used SNAP to meet spending needs in past 7 days (spend_snap)
  #   17) indicator variable for if a person used credit cards or loans to meet spending needs in past 7 days (spend_credit)
  #   18) indicator variable for if a person used savings to meet spending needs in past 7 days (spend_savings)
  #   19) indicator variable for if a person used UI benefits to meet spending needs in past 7 days (spend_ui)
  #   20) indicator variable for if a person used stimulus payment to meet spending needs in past 7 days (spend_stimulus)
  #   21) indicator variable for if a person not caught up on rent is somewhat likely or very likely to be evicted in next two months (eviction_risk)
  #   22) indicator variable for if a person not caught up on mortgage is somewhat likely or very likely to be foreclosed on in next two months (foreclosure_risk)


  # INPUT:
  #   week_num (num): week number of Pulse survey (ie 13, 14, 15..., etc). Can be a vector if
  #     you want to pull data for multiple weeks. Should only be used for questionnaire 2
  #     week 13 or greater.
  #   output_filepaths (chr): Output folder where puf file and data dictionary
  #     be written to
  # OUPUT:
  #   df_clean: cleaned pubilc use file
  #   This fxn will also write out the raw downlaoded public use files into the data/raw-data directory

  week_num_padded <- str_pad(week_num, width = 2, side = "left", pad = "0")

  # account for year changes
  year <- case_when(week_num < 22 ~ 2020,
                    week_num >= 22 & week_num < 41 ~ 2021,
                    week_num >= 41 & week_num < 52 ~ 2022,
                    week_num >= 52 & week_num < 64 ~ 2023,
                    week_num >= 64 & week_num <= 67 ~ 2024)

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

  puf_url <- case_when(
    week_num <= 63 ~ str_glue("https://www2.census.gov/programs-surveys/demo/datasets/hhp/{year}/wk{week_num}/HPS_Week{week_num_padded}_PUF_CSV.zip"),
    week_num >= 64 & week_num < 67 ~ str_glue("https://www2.census.gov/programs-surveys/demo/datasets/hhp/{year}/cycle{cycle_num_padded}/HPS_Phase4Cycle{cycle_num_padded}_PUF_CSV.zip"),
    week_num >= 67 ~ str_glue("https://www2.census.gov/programs-surveys/demo/datasets/hhp/{year}/cycle{cycle_num_padded}/HPS_Phase4-{phase_version}Cycle{cycle_num_padded}_PUF_CSV.zip")
  )

  # Create public_use_files directory if it doesn't exist
  dir.create("data/raw-data/public_use_files/", showWarnings = F)

  # Download zip file
  if(!file.exists(str_glue("data/raw-data/public_use_files/week_{week_num_padded}.zip"))){
    download.file(puf_url,
                  destfile = str_glue("data/raw-data/public_use_files/week_{week_num_padded}.zip"),
                  # By default uses winnet method which is for some reason very slow
                  method = "libcurl"

    )

  }

  #Note: data dictionaries change naming conventions within phase 2 due to December
  # update, we accordingly default to extracting all files without names
  unzip(str_glue("data/raw-data/public_use_files/week_{week_num_padded}.zip"),
        exdir = "data/raw-data/public_use_files")

  # Get MSA FIPS Codes for appending later
  fips_msa_url <- "https://query.data.world/s/vn4chhniqhslgt5fpb7swxbkcsq3oj"
  GET(fips_msa_url, write_disk(tf <- tempfile(fileext = ".xls")))
  msa_fips_codes <- read_excel(tf, skip = 2) %>%
    select("CBSA Code", "CSA Title", "CBSA Title") %>%
    # There seem to be some duplicate entries, so we remove them
    distinct(.keep_all = TRUE)

  ### Read in PUF file
  # week_num 52 wrongly formatted, is 2022 but says 2023
  year_path <- ifelse(week_num == 52, 2022, year)
  puf_filepath <- case_when(
    year <= 2023 ~ str_glue("{output_filepath}pulse{year_path}_puf_{week_num_padded}.csv"),
    year == 2024 ~ str_glue("{output_filepath}hps_04_{phase_version_padded}_{cycle_num_padded}_puf.csv")
  )
  df <- read_csv(puf_filepath)

  #Phase 2 (Week 13-17) and phase 3 (Week 18-27)

  if (week_num <= 27) {
    df <- df %>%
      mutate(spndsrc9 = NA_real_,
             spndsrc10 = NA_real_,
             spndsrc11 = NA_real_,
             spndsrc12 = NA_real_)
  }

  #Phase 3.1: Week 28-33

  if (week_num > 27 & week_num <= 33) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV) %>%
      mutate(tw_start = NA_real_,
             tch_hrs = NA_real_,
             spndsrc10 = NA_real_,
             spndsrc11 = NA_real_,
             spndsrc12 = NA_real_)
  }

  #Phase 3.2: Week 34-39

  if (week_num > 33 & week_num <= 39) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRC1,
             SPNDSRC2 = SPND_SRC2,
             SPNDSRC3 = SPND_SRC3,
             SPNDSRC4 = SPND_SRC4,
             SPNDSRC5 = SPND_SRC5,
             SPNDSRC6 = SPND_SRC6,
             SPNDSRC7 = SPND_SRC7,
             SPNDSRC8 = SPND_SRC8,
             SPNDSRC9 = SPND_SRC9,
             SPNDSRC10 = SPND_SRC10,
             SPNDSRC11 = SPND_SRC11,
             SPNDSRC12 = SPND_SRC12) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_)
  }

  #Phase 3.3: Week 40 - 42

  if (week_num > 39 & week_num <= 42) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRC1,
             SPNDSRC2 = SPND_SRC2,
             SPNDSRC3 = SPND_SRC3,
             SPNDSRC4 = SPND_SRC4,
             SPNDSRC5 = SPND_SRC5,
             SPNDSRC6 = SPND_SRC6,
             SPNDSRC7 = SPND_SRC7,
             SPNDSRC8 = SPND_SRC8,
             SPNDSRC9 = SPND_SRC9,
             SPNDSRC10 = SPND_SRC10,
             SPNDSRC11 = SPND_SRC11,
             SPNDSRC12 = SPND_SRC12) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_)
  }

  #Phase 3.4: Week 43-45

  if (week_num > 42 & week_num <= 45) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRC1,
             SPNDSRC2 = SPND_SRC2,
             SPNDSRC3 = SPND_SRC3,
             SPNDSRC4 = SPND_SRC4,
             SPNDSRC5 = SPND_SRC5,
             SPNDSRC6 = SPND_SRC6,
             SPNDSRC7 = SPND_SRC7,
             SPNDSRC8 = SPND_SRC8,
             SPNDSRC9 = SPND_SRC9,
             SPNDSRC10 = SPND_SRC10,
             SPNDSRC11 = SPND_SRC11,
             SPNDSRC12 = SPND_SRC12) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_)
  }

  #Phase 3.5: Week 46-48
  #Question about confidence making next rent or mortgage payment (mortconf)
  #dropped from survey. Question about receiving needed mental healthcare
  #(mh_notget) dropped from survey.

  if (week_num > 45 & week_num <= 48) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRC1,
             SPNDSRC2 = SPND_SRC2,
             SPNDSRC3 = SPND_SRC3,
             SPNDSRC4 = SPND_SRC4,
             SPNDSRC5 = SPND_SRC5,
             SPNDSRC6 = SPND_SRC6,
             SPNDSRC7 = SPND_SRC7,
             SPNDSRC8 = SPND_SRC8,
             SPNDSRC9 = SPND_SRC9,
             SPNDSRC10 = SPND_SRC10,
             SPNDSRC11 = SPND_SRC11,
             SPNDSRC12 = SPND_SRC12) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_)
  }

  #Phase 3.6: Week 49-51
  #Updates to spending questions, no longer asking about stimulus (SPNDSRC6) or child tax credit (SPNDSRC7)
  if (week_num > 48 & week_num <= 51) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRCRV1,
             SPNDSRC2 = SPND_SRCRV2,
             SPNDSRC3 = SPND_SRCRV3,
             SPNDSRC4 = SPND_SRCRV4,
             SPNDSRC5 = SPND_SRCRV5,
             SPNDSRC8 = SPND_SRCRV6,
             SPNDSRC9 = SPND_SRCRV7,
             SPNDSRC10 = SPND_SRCRV9,
             SPNDSRC11 = SPND_SRCRV10,
             SPNDSRC12 = SPND_SRCRV11) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_)
  }

  #Phase 3.7: Week 52-54
  if (week_num > 51 & week_num <= 54) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRCRV1,
             SPNDSRC2 = SPND_SRCRV2,
             SPNDSRC3 = SPND_SRCRV3,
             SPNDSRC4 = SPND_SRCRV4,
             SPNDSRC5 = SPND_SRCRV5,
             SPNDSRC8 = SPND_SRCRV6,
             SPNDSRC9 = SPND_SRCRV7,
             SPNDSRC10 = SPND_SRCRV9,
             SPNDSRC11 = SPND_SRCRV10,
             SPNDSRC12 = SPND_SRCRV11) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_)
  }

  #Phase 3.8: Week 55-57
  if (week_num > 54 & week_num <= 57) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRCRV1,
             SPNDSRC2 = SPND_SRCRV2,
             SPNDSRC3 = SPND_SRCRV3,
             SPNDSRC4 = SPND_SRCRV4,
             SPNDSRC5 = SPND_SRCRV5,
             SPNDSRC8 = SPND_SRCRV6,
             SPNDSRC9 = SPND_SRCRV7,
             SPNDSRC10 = SPND_SRCRV9,
             SPNDSRC11 = SPND_SRCRV10,
             SPNDSRC12 = SPND_SRCRV11) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_)
  }

  #Phase 3.9: Week 58-60
  if (week_num > 57 & week_num <= 60) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRCRV1,
             SPNDSRC2 = SPND_SRCRV2,
             SPNDSRC3 = SPND_SRCRV3,
             SPNDSRC4 = SPND_SRCRV4,
             SPNDSRC5 = SPND_SRCRV5,
             SPNDSRC8 = SPND_SRCRV6,
             SPNDSRC9 = SPND_SRCRV7,
             SPNDSRC10 = SPND_SRCRV9,
             SPNDSRC11 = SPND_SRCRV10,
             SPNDSRC12 = SPND_SRCRV11) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_)
  }

  #Phase 3.10: Week 61-63
  if (week_num > 60 & week_num <= 63) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             SPNDSRC1 = SPND_SRCRV1,
             SPNDSRC2 = SPND_SRCRV2,
             SPNDSRC3 = SPND_SRCRV3,
             SPNDSRC4 = SPND_SRCRV4,
             SPNDSRC5 = SPND_SRCRV5,
             SPNDSRC8 = SPND_SRCRV6,
             SPNDSRC9 = SPND_SRCRV7,
             SPNDSRC10 = SPND_SRCRV9,
             SPNDSRC11 = SPND_SRCRV10,
             SPNDSRC12 = SPND_SRCRV11) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_)
  }

  #Phase 4.0: Week 64-66
  if (week_num > 63 & week_num <= 66) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC1 = NA_real_,
             SPNDSRC2 = NA_real_,
             SPNDSRC3 = NA_real_,
             SPNDSRC4 = NA_real_,
             SPNDSRC5 = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_,
             SPNDSRC8 = NA_real_,
             SPNDSRC9 = NA_real_,
             SPNDSRC10 = NA_real_,
             SPNDSRC11 = NA_real_,
             SPNDSRC12 = NA_real_)
  }

  #Phase 4.1: Week 67
  if (week_num == 67) {
    df <- df %>%
      rename(WRKLOSS = WRKLOSSRV,
             FORCLOSE = FORECLOSE) %>%
      mutate(expctloss = NA_real_,
             tw_start = NA_real_,
             tch_hrs = NA_real_,
             mortconf = NA_real_,
             mh_notget = NA_real_,
             SPNDSRC1 = NA_real_,
             SPNDSRC2 = NA_real_,
             SPNDSRC3 = NA_real_,
             SPNDSRC4 = NA_real_,
             SPNDSRC5 = NA_real_,
             SPNDSRC6 = NA_real_,
             SPNDSRC7 = NA_real_,
             SPNDSRC8 = NA_real_,
             SPNDSRC9 = NA_real_,
             SPNDSRC10 = NA_real_,
             SPNDSRC11 = NA_real_,
             SPNDSRC12 = NA_real_)
  }

  df_clean <- df %>%
    janitor::clean_names() %>%
    ### Append Urban specific columns
    mutate(
      # Generate hispanic/non-hispanic race variables
      hisp_rrace = case_when(
        rrace == 1 ~ "White alone, not Hispanic",
        rrace == 2 ~ "Black alone, not Hispanic",
        rrace == 3 ~ "Asian alone, not Hispanic",
        rrace == 4 ~ "Two or more races + Other races, not Hispanic",
        TRUE ~ NA_character_
      ),
      # Note: hispanic ethnicity overrides all other race variables
      hisp_rrace = case_when(
        rhispanic == 1 ~ hisp_rrace,
        rhispanic == 2 ~ "Hispanic or Latino (may be of any race)",
        TRUE ~ hisp_rrace
      ),
      # Dummy var for uninsured respondents
      uninsured = case_when(
        # Note the order of these case_when statements matter
        # First if they have any of the first 6 healath insurance options, they are insured (0)
        hlthins1 == 1 |
          hlthins2 == 1 |
          hlthins3 == 1 |
          hlthins4 == 1 |
          hlthins5 == 1 |
          hlthins6 == 1 ~ 0,
        # If they answer no to all 6 health insurance quetions, they are uninsured (1)
        (hlthins1 == 2 &
           hlthins2 == 2 &
           hlthins3 == 2 &
           hlthins4 == 2 &
           hlthins5 == 2 &
           hlthins6 == 2) ~ 1,
        # Note Census includes those who have Indian Health Service coverage as uninsured (1)
        hlthins7 == 1 ~ 1,

        TRUE ~ NA_real_
      ),
      # Dummy var for respondents with public insurance
      insured_public = case_when(
        # if they have medicare, medicaid, or VA insurance = 1
        hlthins3 == 1 | hlthins4 == 1 | hlthins6 == 1 ~ 1,

        # if they didn't answer any of the helath insurance questions& assign them NA
        hlthins1 == -99 & hlthins2 == -99 & hlthins3 == -99 &
          hlthins4 == -99 & hlthins5 == -99 & hlthins6 == -99 &
          hlthins7 == -99 & hlthins8 == -99 ~ NA_real_,

        hlthins1 == -88 & hlthins2 == -88 & hlthins3 == -88 &
          hlthins4 == -88 & hlthins5 == -88 & hlthins6 == -88 &
          hlthins7 == -88 & hlthins8 == -88 ~ NA_real_,
        # If they answered at least one question but were not publicly insured, mark as 0
        TRUE ~ 0
      ),
      # Dummy var for lost income in past 4 weeks? (1 = lost income, 0 = didn't lose income)
      inc_loss = case_when(
        wrkloss == 1 ~ 1,
        wrkloss == 2 ~ 0,
        TRUE ~ NA_real_
      ),
      # Dummy var for future Employment income loss
      expect_inc_loss = case_when(
        expctloss == 1 ~ 1,
        expctloss == 2 ~ 0,
        TRUE ~ NA_real_
      ),
      # Dummy var for not confident in housing payment next month? (1 = yes, 0 = no)
      payment_not_conf = case_when(
        # slight or no confidnece or payment already deferred = 1
        mortconf %in% c(1, 2, 5) ~ 1,
        # moderate or high confidence = 0
        mortconf %in% c(3, 4) ~ 0,
        TRUE ~ NA_real_
      ),
      # Dummy var for not confident in rent payment next month (1 = yes, 0 = no)
      rent_not_conf = case_when(
        # slight or no confidnece or payment already deferred = 1
        mortconf %in% c(1, 2, 5) & tenure == 3 ~ 1,
        # moderate or high confidence = 0
        mortconf %in% c(3, 4) & tenure == 3 ~ 0,
        TRUE ~ NA_real_
      ),
      mortgage_not_conf = case_when(
        # slight or no confidnece or payment already deferred = 1
        mortconf %in% c(1, 2, 5) & tenure == 2 ~ 1,
        # moderate or high confidence = 0
        mortconf %in% c(3, 4) & tenure == 2 ~ 0,
        TRUE ~ NA_real_
      ),
      # Dummy var caught up on rent (1 = yes, 0 = no)
      rent_caughtup = case_when(
        # caught up on rent payments = 1
        rentcur == 1 & tenure == 3 ~ 1,
        # not caught up on rent payments = 0
        rentcur == 2 & tenure == 3 ~ 0,
        .default = NA_real_,
      ),
      # Dummy var for caught up on mortage (1 = yes, 0 = no)
      mortgage_caughtup = case_when(
        # caught up on mortgage payments = 1
        mortcur == 1 & tenure == 2 ~ 1,
        # not caught up on mortgage payments = 0
        mortcur == 2 & tenure == 2 ~ 0,
        TRUE ~ NA_real_
      ),
      # Dummy var for Food Insufficient households
      food_insufficient = case_when(
        curfoodsuf %in% c(3, 4) ~ 1,
        curfoodsuf %in% c(1, 2) ~ 0,
        TRUE ~ NA_real_
      ),
      spend_credit = as.numeric(case_when(
        #set 1 if respondent answered they use credit cards or loans
        spndsrc2 == 1 ~ 1,
        # Set 0 if respondent answered atleast one of the spending questions
        (spndsrc1 >= 0 | spndsrc2 >= 0 | spndsrc3 >= 0 | spndsrc4 >= 0 |
           spndsrc5 >= 0 | spndsrc6 >= 0 | spndsrc7 >= 0| spndsrc8 >= 0 |
           spndsrc9 >= 0 | spndsrc10 >= 0 | spndsrc11 >= 0 | spndsrc12 >= 0) ~ 0,
        # Set NA otherwise
        TRUE ~ NA_real_
      )),
      spend_savings = as.numeric(case_when(
        #set 1 if respondent answered they use savings or selling assets
        spndsrc3 == 1 ~ 1,
        # Set 0 if respondent answered at least one of the spending questions
        (spndsrc1 >= 0 | spndsrc2 >= 0 | spndsrc3 >= 0 | spndsrc4 >= 0 |
           spndsrc5 >= 0 | spndsrc6 >= 0 | spndsrc7 >= 0| spndsrc8 >= 0|
           spndsrc9 >= 0 | spndsrc10 >= 0 | spndsrc11 >= 0 | spndsrc12 >= 0) ~ 0,
        # Set NA otherwise
        TRUE ~ NA_real_
      )),
      spend_ui = as.numeric(case_when(
        #set 1 if respondent answered they use creditcards or loans
        spndsrc5 == 1 ~ 1,
        # Set 0 if respondent answered at least one of the spending questions
        (spndsrc1 >= 0 | spndsrc2 >= 0 | spndsrc3 >= 0 | spndsrc4 >= 0 |
           spndsrc5 >= 0 | spndsrc6 >= 0 | spndsrc7 >= 0| spndsrc8 >= 0|
           spndsrc9 >= 0 | spndsrc10 >= 0 | spndsrc11 >= 0 | spndsrc12 >= 0) ~ 0,
        # Set NA otherwise
        TRUE ~ NA_real_
      )),
      spend_stimulus = as.numeric(case_when(
        #set 1 if respondent answered they use creditcards or loans
        spndsrc6 == 1 ~ 1,
        # Set 0 if respondent answered atleast one of the child education questions
        (spndsrc1 >= 0 | spndsrc2 >= 0 | spndsrc3 >= 0 | spndsrc4 >= 0 |
           spndsrc5 >= 0 | spndsrc6 >= 0 | spndsrc7 >= 0| spndsrc8 >= 0|
           spndsrc9 >= 0 | spndsrc10 >= 0 | spndsrc11 >= 0 | spndsrc12 >= 0) ~ 0,
        # Set NA otherwise
        TRUE ~ NA_real_
      )),
      # Score variables for mental health qs. Note we use scoring scheme laid out here:
      # https://www.cdc.gov/nchs/covid19/pulse/mental-health.htm which requires recoding
      # the 4 mental health questions to thier specific scores. If sum of sets of 2 qs
      # are greater than 3, that means the respondent has a sign of anxiety or depression
      anxious_score = case_when(
        anxious == 1 ~ 0,
        anxious == 2 ~ 1,
        anxious == 3 ~ 2,
        anxious == 4 ~ 3,
        TRUE ~ NA_real_
      ),
      worry_score = case_when(
        worry == 1 ~ 0,
        worry == 2 ~ 1,
        worry == 3 ~ 2,
        worry == 4 ~ 3,
        TRUE ~ NA_real_
      ),
      interest_score = case_when(
        interest == 1 ~ 0,
        interest == 2 ~ 1,
        interest == 3 ~ 2,
        interest == 4 ~ 3,
        TRUE ~ NA_real_
      ),
      down_score = case_when(
        down == 1 ~ 0,
        down == 2 ~ 1,
        down == 3 ~ 2,
        down == 4 ~ 3,
        TRUE ~ NA_real_
      ),
      #difficulty paying household expenses in past 7 days
      expense_dif= case_when(
        expns_dif >= 3 ~ 1,
        expns_dif %in% c(1, 2) ~ 0,
        TRUE ~ NA_real_
      ),
      #dummy for telework
      telework= case_when(tw_start == 1 ~ 1,
                          tw_start %in% c(2, 3) ~ 0,
                          TRUE ~ NA_real_
      ),
      #dummy for unmet need for mental health services in last 4 weeks
      mentalhealth_unmet= case_when(mh_notget == 1 ~ 1,
                                    mh_notget == 2 ~ 0,
                                    TRUE ~ NA_real_
      ),
      #dummy for eviction risk
      # this question was asked of everyone who answered rentcur == 2 and tenure == 3,
      # or that they are renters and they are not caught up on rent.
      eviction_risk = case_when(evict %in% c(1, 2) ~ 1,
                                evict %in% c(3, 4) ~ 0,
                                TRUE ~ NA_real_
      ),
      #dummy for foreclosure risk
      # this question was asked of everyone who answered mortcur == 2 and tenure == 2,
      # or that they pay mortgages and are not caught up on mortgages.
      foreclosure_risk = case_when(forclose %in% c(1, 2) ~ 1,
                                   forclose %in% c(3, 4) ~ 0,
                                   TRUE ~ NA_real_
      ),
      #dummy for Proportion of adults with children in school who spend fewer
      #hours on learning activities in the past 7 days relative to before the pandemic
      learning_fewer= case_when(tch_hrs %in% c(1, 2) ~ 1,
                                tch_hrs >= 3 ~ 0,
                                TRUE ~ NA_real_
      ),
      #SNAP spending
      spend_snap = case_when(spndsrc8 == 1 ~ 1,
                             (spndsrc1 >= 0 | spndsrc2 >= 0 | spndsrc3 >= 0 | spndsrc4 >= 0 |
                                spndsrc5 >= 0 | spndsrc6 >= 0 | spndsrc7 >= 0 | spndsrc8 >= 0 |
                                spndsrc9 >= 0 | spndsrc10 >= 0 | spndsrc11 >= 0 | spndsrc12 >= 0) ~ 0
      )
    ) %>%
    # Needed for rowwise sum calculations in anxiety_signs and depression_signs var
    rowwise() %>%
    mutate(
      # Dummy var for sign of anxiety (based on >=3 score)
      anxiety_signs = case_when(
        sum(anxious_score, worry_score, na.rm = T) >= 3 ~ 1,
        is.na(anxious_score) & is.na(worry_score) ~ NA_real_,
        TRUE ~ 0
      ),
      # Dummy var for sign of depression (based on >=3 score)
      depression_signs = case_when(
        sum(interest_score, down_score, na.rm = T) >= 3 ~ 1,
        is.na(interest_score) & is.na(down_score) ~ NA_real_,
        TRUE ~ 0
      )
    ) %>%
    ungroup() %>%
    mutate(
      # Dummy Var for any signs of anxiety/depression
      depression_anxiety_signs = case_when(
        # Set 1 if respondent has either anxiety signs or depression sigs
        anxiety_signs == 1 | depression_signs == 1 ~ 1,
        is.na(anxiety_signs == 1) & is.na(depression_signs) ~ NA_real_,
        TRUE ~ 0
      ),
      # Turn MSA column into character
      est_msa = as.character(est_msa),
      # split inc_loss variable to reflect change in the survey question beginning
      # in week 28 (see data dictionary for details)
      inc_loss_rv = case_when(week_num >= 28 ~ as.numeric(inc_loss),
                              TRUE ~ NA_real_),
      inc_loss = case_when(week_num >= 28 ~ NA_real_,
                           TRUE ~ as.numeric(inc_loss)),
      # Add numeric year column
      year = year,
      # Add numeric week number column
      week_x = week_num,
      # Add string week num column
      week_num = paste0("wk", week_num)
    ) %>%
    ### Append full state names
    left_join(tigris::fips_codes %>% select(state, state_code, state_name) %>%
                distinct(state_code, .keep_all = TRUE),
              by = c("est_st" = "state_code")
    ) %>%
    ### Append MSA Names
    left_join(msa_fips_codes, by = c("est_msa" = "CBSA Code")) %>%
    janitor::clean_names() %>%
    select(any_of(vars))

  # Check that cleaned data has same number of rows as raw data
  assert("Cleaned df has same # of rows as raw data", nrow(df) == nrow(df_clean))

  return(df_clean)
}


week_vec <- 13:67
puf_all_weeks <- map_df(week_vec, download_and_clean_puf_data)

# single week
#puf_all_weeks <- map_df(33:34, download_and_clean_puf_data)

# Create public_use_files directory if it doesn't exist
dir.create("data/intermediate-data", showWarnings = F)

write_csv(puf_all_weeks, here("data/intermediate-data", "pulse_puf2_all_weeks.csv"))

# Manually generate and write out data dictionary for appended columns
appended_column_data_dictionary <-
  tibble::tribble(
    ~col_name, ~description,
    "hisp_rrace", "Combination of Hispanic and Race column. Groups respondents into the following categories: Hispanic, White non Hispanic, Black non Hispanic, Asian non Hispanic, and Other race/two or more races",
    "uninsured", "Indicator variable for if a respondent is uninsured. This is 1 if the respondent reported that they have none of the available insurnace ooptions or only have insurance through the Indian Health Service. It is 0 if the respondents have some type of health insurance (excluding the Indian Health service)",
    "insured_public", "Indicator variable for if a respondent has public insurance. This is 1 if the respondent reported thaty had Medicare, Medicaid, or VA Health Insurance",
    "inc_loss", "Indicator variable for if a respondent (or anyone in their houshold) experienced a loss in employment income since March 13, 2020. This is essentially a recoding of the wrkloss variable with -88 and -99 coded as NA, 1 coded as 1 and 2 coded as 0. This question was changed in the survey instrument with the beginning of phase 3.1. Values will be NA for week 28 onward. We do not recommend that users of this data compare the inc_loss and inc_loss_rv variables.",
    "inc_loss_rv", "Indicator variable for if a respondent (or anyone in their houshold) experienced a loss in employment income in the last four weeks. This is essentially a recoding of the wrklossrv variable with -88 and -99 coded as NA, 1 coded as 1 and 2 coded as 0. This question was introduced in the survey instrument with the beginning of phase 3.1. Values will be NA for prior to week 28. We do not recommend that users of this data compare the inc_loss and inc_loss_rv variables.",
    "expect_inc_loss", "Indicator variable for if a respondent (or anyone in their household) expects to experience a loss in employment income in the next 4 weeks due to the coronavirus. this is essentially a recoding of the expctloss variable with -88 and -99 coded as NA, 1 coded as 1 and 2 coded as 0. Question only asked through week 33. Value will be NA for week 34 onward.",
    "payment_not_conf", "Indicator variable for if a respondent has little or no confidence in paying rent/mortgage next month or has already deferred payment for next months rent/mortgage. Note this excludes people who oen their homes free and clear or occupy thier house without payment of rent. They are coded as 1 if mortconf is  1,2 or ; s 0 if mortconf is 3 or 4; and NA otherwise. This question was only asked through week 45. Values will be NA for week 46 onward.",
    "rent_not_conf", "Indicator variable for if a respondent has little or no confidence in paying thier rent next month or has already deferred. This is a limited to renters (ie tenure ==3). This question was only asked through week 45. Values will be NA for week 46 onward.",
    "mortgage_not_conf", "Indicator variable for if a respondent has little or no confidence in paying thier mortgage next month or has already deferred. This is a limited to owners paying mortgage (ie tenure ==2). This question was only asked through week 45. Values will be NA for week 46 onward.",
    "rent_caughtup", "Indicator variable for if a respondent's household is currently caught up on rent. This is a limited to renters (ie tenure ==3)",
    "mortgage_caughtup", "Indicator variable for if a respondent's household is currently caught up on mortage. This is a limited to owners paying mortgage (ie tenure ==2)",
    "food_insufficient", "Indicator variable for if a respondents household has sometimes or often had not enough to eat in the last 7 days. This is essentially a recoding of the curfoodsuff variable where 3 and 4 are coded as 1, 1 and 3 are coded as 0, and -88 and -99 are coded as NA",
    "spend_savings", "Indicator variable for if a respondent reported using money from savings or selling assets in last 7 days to meet spending needs",
    "spend_credit", "Indicator variable for if a respondent reported using money from credit cards or loans in last 7 days to meet spending needs",
    "spend_ui", "Indicator variable for if a respondent reported using money from unemployment insurance (UI) benefit payments in last 7 days to meet spending needs",
    "spend_stimulus", "Indicator variable for if a respondent reported using money from stimulus (economic impact) payment in last 7 days to meet spending needs",
    "anxious_score", "A recoding of the anxious variable to correctly reflect the numerical scores used to determine symptoms of generalized anxiety disorder. Specifically not at all = 0, several days = 1, more than half the days = 2, and nearly every day = 3. Starting in week 34, question changed from asking about past 7 days to asking about past two weeks.",
    "worry_score", "A recoding of the worry variable to correctly reflect the numerical scores used to determine symptoms of generalized anxiety disorder. Specifically not at all = 0, several days = 1, more than half the days = 2, and nearly every day = 3. Starting in week 34, question changed from asking about past 7 days to asking about past two weeks.",
    "interest_score", "A recoding of the interest variable to correctly reflect the numerical scores used to determine symptoms of major depresive disorder. Specifically not at all = 0, several days = 1, more than half the days = 2, and nearly every day = 3. Starting in week 34, question changed from asking about past 7 days to asking about past two weeks.",
    "down_score", "A recoding of the worry variable to correctly reflect the numerical scores used to determine symptoms of major depressive disorder. Specifically not at all = 0, several days = 1, more than half the days = 2, and nearly every day = 3. Starting in week 34, question changed from asking about past 7 days to asking about past two weeks.",
    "anxiety_signs", "Indicator variable for if the respondent is showing signs of generalized anxiety disorder. This is coded as 1 if the sum of anxious_score and worry_score is >= 3. Respondents with missing responses to both questions are coded as NA and 0 otherwise",
    "depression_signs", "Indicator variable for if the respondent is showing signs of major depressive disroder. This is coded as 1 if the sum of down_score and interest_score is >= 3.  Respondents with missing responses to both questions are coded as NA and 0 otherwise",
    "depression_anxiety_signs", " Indicator variable if the respondent is showing either signs of major depressive disorder or generalized anxiety disorder. Respondents with missing responses to both anxiety_signs and depression_signs are coded as NA",
    "expense_dif", "Indicator variable for if a respondent reported difficulty for their household to pay for usual household expense n the last 7 days ",
    "telework", "Indicator variable for if at least one adult in this household substitutes some or all of their typical in-person work for telework because of the coronavirus pandemic. Question only asked through week 27. Value will be NA for week 28 onward.",
    "metalhealth_unmet", "Indicator variable for if respondent needed but did not get counseling or therapy from a mental health professional in the past 4 weeks, for any reason. This question was only asked through week 45. Values will be NA for week 46 onward.",
    "eviction_risk", "Indicator variable for if the household will very likely or extremely likely have to leave this home or apartment within the next two months because of eviction. ",
    "foreclosure_risk", "Indicator variable for if the houeshold will very likely or extremely likely have to leave this home within the next two months because of foreclosure",
    "learning_fewer", "Indicator variable for if the student(s) in the household spend less time on all learning activities relative to a school day before the coronavirus pandemic during the last 7 days. Question only asked through week 27. Value will be NA for week 28 onward.",
    "spend_snap", "Indicator variable for if household members are using SNAP to meet their spending needs in the past 7 days",
    "week_num", "The week number that the survey data is from",
    "state", "2 digit abbrevation of the state that respondents are from",
    "state_name", "The full name of the state that respondents are from",
    "csa_title", "The name of the larger Combined statistical area that the respondent is from. Note the Census only reports the Metropolitan Statistical Area (aks the CBSA)",
    "cbsa_title", "The full name of the Core based statistical area that the respondent is from"
  )

# Write out data dictionary
write_csv(
  appended_column_data_dictionary,
  "data/intermediate-data/pulse_puf2_appended_columns_data_dictionary.csv"
)

puf_all_weeks <- read_csv("data/intermediate-data/pulse_puf2_all_weeks.csv")

# format puf for data wrangling and analysis
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

puf_fmt <- puf_all_weeks |>
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

write_csv(puf_fmt, here("data/intermediate-data", "puf_formatted.csv"))

# get pct missing for each week by each variable
all_missing <- puf_all_weeks %>%
  group_by(week_num) %>%
  summarise(across(.cols = where(is.numeric), .fns = ~mean(is.na(.x))))

# get number of obs that are missing all variables for each week
num_all_missing <- all_missing %>%
  pivot_longer(-week_num, names_to = "variable", values_to = "pct_missing") %>%
  group_by(week_num) %>%
  summarise(n_all_missing = sum(pct_missing == 1))

# look at differences with adding new phase
phase_diff <- function (wk1, wk2) {
  week_nums <- c(deparse(substitute(wk1)), deparse(substitute(wk2)))
  all_missing %>%
    filter(week_num %in% week_nums) %>%
    pivot_longer(-week_num, names_to = "variable", values_to = "pct_missing") %>%
    pivot_wider(names_from = "week_num", values_from = "pct_missing") %>%
    filter({{ wk1 }} == 1 | {{ wk2 }} == 1, {{ wk1 }} != {{ wk2 }})
}

# phase 3.3 to 3.4
phase_diff(wk42, wk43)

#phase 3.4 to 3.5
phase_diff(wk45, wk46)

#phase 3.5 to 3.6
phase_diff(wk48, wk49)
#phase 3.6 to 3.7
phase_diff(wk51, wk52)

#phase 3.7 to 3.8
phase_diff(wk54, wk55)

#phase 3.8 to 3.9
phase_diff(wk57, wk58)

#phase 3.9 to 3.10
phase_diff(wk60, wk61)

