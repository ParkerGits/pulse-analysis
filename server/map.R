library(tidyverse)
library(openintro)
library(plotly)
library(albersusa) 
us_states <- usa_sf("laea") 
library(ggplot2) 
std_err_significance <- read_csv("phase2_all.csv") 
#written for title to start with percentage of people who
title_list <- list(
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

colnames(std_err_significance)[colnames(std_err_significance) == 'mean'] <- 'average'
plot_state_map <- function(race, week, variable) { 
  std_err_significance$sigdiff <- ifelse(std_err_significance$sigdiff == 1, "Yes", "No") 
  a <- subset(std_err_significance, metric == variable) 
  b <- (subset(a,week_num == week)) 
  final_data <- (subset(b,race_var == race))
  final_data <- us_states %>% 
    left_join(final_data, c('iso_3166_2'='geography')) 
  final_data <- final_data[-6,] 
  my_map_theme <- function(){
    theme(panel.background=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          axis.title=element_blank())
  } 
  mini <- round(min(std_err_significance$se, na.rm = TRUE),digits = 4)*100
  middle <- round(mean(std_err_significance$average, na.rm = TRUE),digits = 4) * 100 
  firstq <- round(mean(std_err_significance$average, na.rm = TRUE) +   sd(std_err_significance$average, na.rm = TRUE),digits = 4) * 100 
  thirdq <- round(mean(std_err_significance$average, na.rm = TRUE) - sd(std_err_significance$average, na.rm = TRUE),digits = 4) * 100
  maxi <- round(max(std_err_significance$average, na.rm = TRUE),digits = 4) * 100 
  graph <- final_data %>%
    mutate(text = paste("<b>",round(average, digits = 4)*100,"%", metric, "\n","Race =",race_var,"\n","95% confidence interval (",round(moe_95_lb, digits = 4)*100, ",",round(moe_95_ub, digits = 4)*100,")", "\n", "Statistically Significant:", sigdiff)) %>% 
    mutate(average = round(average, digits = 4)*100) %>%
    ggplot() + 
    geom_sf(aes(fill = average+runif(nrow(final_data),min=0, max = .01),text = text),color = 'black') + 
    scale_fill_continuous(paste('Percentage of people who',variable), low = "white",high = "darkgreen", breaks = c(mini,firstq,middle,thirdq,maxi), limits = c(mini,maxi))+ 
    my_map_theme()+
    labs(title = paste('Percentage of people who',variable)) 
  last1 <- ggplotly(graph, tooltip = "text") %>% 
    style(hoveron = "fill") 
  last1
} 
plot_state_map('black', 'wk30', 'uninsured')
