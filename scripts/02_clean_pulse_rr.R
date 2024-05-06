puf_all_weeks <- read_csv("data/intermediate-data/pulse_puf2_all_weeks.csv")

calculate_response_rate_metrics <- function(df_clean) {
  # Function to calculate the following response rate metrics:
  #   1) rr_out: The proportion of racial group respondents who responded to
  #      each question (ie 75% of black survey takers responded to Question X in
  #      Week Y)
  #   2) job_loss_out: the proportion of respondents who that did and did not answer the question(s)
  #      answered that at least one member of their household had lost employment income since March 13.
  #      (ie 75% of survey respondents who answered Question X in Week Y responded that at least one member
  #      of their household had lost employment income since March 13 compared to 70% of survey respondents
  #      who didn't answer Question X in Week Y). We choose this metric because the overall item response 
  #      for this metric is very high (> 99%) though some respondents did not answer.
  #   3) prop_resp_by_race: the racial breakdown of respondents who answered
  #      each question  (ie 30% of survey takers who responded to Question X
  #      were black in Week Y)
  #   For metrics where all respondents answer the questions
  #   (metrics_no_elig) we use the question(s) that are used to calculate the
  #   metric. Where only certain respondents receive the questions
  #   (learning_fewer, rent_not_conf, mortgage_not_conf, rent_caughtup,
  #   mortgage_caughtup, eviction_risk, foreclosure_risk) we use the response
  #   rate to the question that determines eligibility to receive the
  #   question(s) used to calculate the metric to approximate response rate
  #
  # INPUTS:
  #   df_clean: dataframe output from download_and_clean_puf_data() function
  # OUTPUTS:
  #   list of dataframes with response rate metrics: rr_out, job_loss_out, prop_resp_by_race
  
  # Look into var: learning_fewer, using enrollment variable as proxy
  metrics_no_elig <- c(
    "uninsured",
    "insured_public",
    "inc_loss",
    "expect_inc_loss",
    "food_insufficient",
    "depression_anxiety_signs",
    "spend_credit", 
    "spend_ui", 
    "spend_stimulus", 
    "spend_savings",
    "spend_snap",
    "telework",
    "mentalhealth_unmet",
    "expense_dif"
  )
  
  answered_df <- df_clean %>% 
    mutate(across(metrics_no_elig, ~if_else(is.na(.), 0, 1), .names = "answered_{.col}"),
           # used to approximate response rate for rent_not_conf, mortgage_not_conf, rent_caughtup,
           #   mortgage_caughtup, eviction_risk, foreclosure_risk
           answered_tenure = if_else(tenure > 0, 1, 0)
    )
  # used to approximate response rate for learning_fewer
  # the rr for enroll is very low because many respondents without
  # school age kids may skip this question. Some that didn't answer this
  # question (both coded -88 and -99) went on to answer subsequent questions.
  # 
  # When we exclude households without children under 18 by requiring thhld_numkid > 0,
  # the response rate for enroll is between 80-81% in weeks 13-15. However, there are some
  # respondents where thhld_numkid == 0 who do answer the enroll question, perhaps either because
  # they have a member of the household over 18 in school, or to answer "no" (enroll3 == 1).
  # Because households without children are in the universe of respondents, we decide to keep them
  # in the denominator for purposes of response rate, but recognize that this is an imperfect metric.
  # answered_enroll = case_when(enroll1 > 0 | enroll2 > 0 | enroll3 > 0 ~ 1,
  #                             TRUE ~ 0)) 
  
  
  # This calculates the racial breakdown of people who answered each of the
  # questions 
  prop_resp_by_race <- answered_df %>%
    # Add in answered_hisp_rrace to get overall survey prop resp by race
    mutate(answered_hisp_rrace = ifelse(is.na(hisp_rrace), 0, 1)) %>%
    select(week_num, hisp_rrace, starts_with("answered")) %>%
    pivot_longer(!c("hisp_rrace", "week_num"), names_to = "metric", values_to = "answered") %>%
    group_by(week_num, metric, hisp_rrace) %>%
    summarise(across(starts_with("answered"), ~sum(.x, na.rm = TRUE))) %>%
    mutate(across(starts_with("answered"), ~.x/sum(.x, na.rm =  TRUE))) %>%
    pivot_wider(names_from = metric, values_from = answered)
  
  rr_by_race <- answered_df %>%
    group_by(week_num, hisp_rrace) %>%
    summarise(across(starts_with("answered"), ~mean(.x, na.rm = TRUE)))
  
  rr_total <- answered_df %>%
    group_by(week_num) %>%
    summarise(across(starts_with("answered"), ~mean(.x, na.rm = TRUE))) %>%
    mutate(hisp_rrace = "Total")
  
  rr_out <- rbind(rr_by_race, rr_total)
  
  job_loss_non_answer_race <- answered_df %>%
    filter(!is.na(inc_loss)) %>%
    select(week_num, hisp_rrace, inc_loss, starts_with("answered")) %>%
    pivot_longer(!c("hisp_rrace", "week_num", "inc_loss"), names_to = "metric", values_to = "answered") %>%
    group_by(week_num, metric, hisp_rrace, answered) %>%
    summarise(inc_loss_pct = mean(inc_loss, na.rm = TRUE)) %>%
    pivot_wider(names_from = metric, values_from = inc_loss_pct)
  
  job_loss_non_answer_all <- answered_df %>%
    filter(!is.na(inc_loss)) %>%
    select(week_num, inc_loss, starts_with("answered")) %>%
    pivot_longer(!c("week_num", "inc_loss"), names_to = "metric", values_to = "answered") %>%
    group_by(week_num, metric, answered) %>%
    summarise(inc_loss_pct = mean(inc_loss, na.rm = TRUE)) %>%
    mutate(hisp_rrace = "Total") %>%
    pivot_wider(names_from = metric, values_from = inc_loss_pct)
  
  print(job_loss_non_answer_all)
  
  job_loss_out <- rbind(job_loss_non_answer_race, job_loss_non_answer_all)
  
  return(list(rr_out, job_loss_out, prop_resp_by_race))
}

metric_list <- calculate_response_rate_metrics(puf_all_weeks)

rr_out <- metric_list[[1]]
job_loss_out <- metric_list[[2]]
prop_resp_race_out <- metric_list[[3]]

write_csv(rr_out, here("data/intermediate-data", "pulse2_rr_metrics_race_all.csv"))
write_csv(job_loss_out, here("data/intermediate-data", "pulse2_rr_metrics_job_loss_all.csv"))
write_csv(prop_resp_race_out, here("data/intermediate-data", "pulse2_response_by_race_all.csv"))

# Manually generate and write out data dictionary for rr metrics
rr_metrics_data_dictionary <-
  tibble::tribble(
    ~col_name, ~description,
    "hisp_rrace", "Combination of Hispanic and Race column. Groups respondents into the following categories: Hispanic, White non Hispanic, Black non Hispanic, Asian non Hispanic, and Other race/two or more races",
    "answered_uninsured", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for uninsured metric",
    "answered_insured_public", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for insured_public metric",
    "answered_inc_loss", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for inc_loss and inc_loss_rv metric",
    "answered_expect_inc_loss", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for expect_inc_loss metric",
    "answered_food_insufficient", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for food_insufficient metric",
    "answered_spend_savings", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for spend_savings metric. All of the spending variables have the same response rate because they are calculated from different response choices from the same question.",
    "answered_spend_credit", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for spend_credit metric. All of the spending variables have the same response rate because they are calculated from different response choices from the same question.",
    "answered_spend_ui", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for spend_ui metric. All of the spending variables have the same response rate because they are calculated from different response choices from the same question.",
    "answered_spend_stimulus", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for spend_stimulus metric. All of the spending variables have the same response rate because they are calculated from different response choices from the same question.",
    "answered_depression_anxiety_signs", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for depression_anxiety_signs metric",
    "answered_expense_dif", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for expense_dif metric",
    "answered_telework", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for telework metric",
    "answered_metalhealth_unmet", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for mentalhealth_unmet metric",
    "answered_spend_snap", "Proportion of total respondents (overall and by race/ethnicity) that answered question(s) for spend_snap metric. All of the spending variables have the same response rate because they are calculated from different response choices from the same question.",
    "answered_tenure", "Proportion of total respondents (overall and by race/ethnicity) that answered tenure question. Used as proxy for housing variable response rate because tenure question determines eligibility for housing questions.",
    "answered_enroll", "Proportion of total respondents (overall and by race/ethnicity) that answered school enrollment question. Used as proxy for learning_fewer variable response rate because enrollment question determines eligibility for housing questions. Response rate is low because asked of all respondents, even those without children under 18 (some of whom answer the question). Question only asked through week 27. Value will be NA for week 28 onward.",
    "week_num", "The week number that the survey data is from"
  )

# Write out data dictionary
write_csv(
  rr_metrics_data_dictionary,
  "data/intermediate-data/pulse_puf2_rr_metrics_data_dictionary.csv"
)
