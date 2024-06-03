if (!require(httpuv)) {
  install.packages("httpuv")
  require(httpuv)
}
if (!require(here)) {
  install.packages("here")
  require(here)
}
if (!require(tidyverse)) {
  install.packages("tidyverse")
  require(tidyverse)
}
if (!require(sf)) {
  install.packages("sf")
  require(sf)
}

data_path <- here("server", "static", "phase2_all.csv")
pulse <- read_csv(data_path)

metrics <- c(
  "uninsured",
  "insured_public",
  "inc_loss_rv",
  "expect_inc_loss",
  "rent_not_conf",
  "mortgage_not_conf",
  "rent_caughtup",
  "mortgage_caughtup",
  "food_insufficient",
  "spend_savings",
  "spend_credit",
  "spend_ui",
  "spend_stimulus",
  "depression_anxiety_signs",
  "expense_dif",
  "telework",
  "eviction_risk",
  "foreclosure_risk",
  "spend_snap",
  "mentalhealth_unmet"
)

metric_title_list <- list(
  depression_anxiety_signs = "Percentage of adults that have shown depression\n or anxiety signs in the past week (phases 2, 3, and 3.1)\nor in the last two weeks (phases 3.2-4.1)",
  eviction_risk = "Percentage of adults in households at high risk\nof being evicted in the next two months",
  expect_inc_loss = "Percentage of adults in households where at least one person\nexpects to lose employment income in the next four weeks\n(question removed in phase 3.2)",
  expense_dif = "Percentage of adults in households have had difficulty\npaying for usual household expenses",
  food_insufficient = "Percentage of adults in households where there was\noften or sometimes not enough food in the past week",
  foreclosure_risk = "Percentage of adults in households at high risk\nof being foreclosed in the next two months",
  inc_loss_rv = "Percentage of adults in households where at least one person\nhas lost employment income since March 13, 2020 (phases 2 and 3)\nor in the last four weeks (phases 3.1-4.1)",
  insured_public = "Percentage of adults under 65 that have public health insurance\n(Medicare, Medicaid, or VA Health Insurance)",
  mentalhealth_unmet = "Percentage of adults that needed but did not get\ncounseling or therapy from a mental health professional in the past 4 weeks,\nfor any reason (question removed in phase 3.5)",
  mortgage_caughtup = "Percentage of adults in households that are\ncurrently caught up on mortgage payments",
  mortgage_not_conf = "Percentage of adults in households that have\nno or slight confidence they can pay their mortgage next month\nor have deferred payment (question removed in phase 3.5)",
  rent_caughtup = "Percentage of adults in households that are\ncurrently caught up on rent payments",
  rent_not_conf = "Percentage of adults in households that have\nno or slight confidence they can pay their rent next month\nor have deferred payment (question removed in phase 3.5)",
  spend_credit = "Percentage of adults that have used credit cards or loans spending to meet\ntheir weekly needs in the past 7 days\n(question removed in phase 4.0)",
  spend_savings = "Percentage of adults that used savings or sold assets to meet\ntheir spending needs in the past week\n(question removed in phase 4.0)",
  spend_snap = "Percentage of adults that have used SNAP to meet\ntheir spending needs in the past 7 days\n(question removed in phase 4.0)",
  spend_stimulus = "Percentage of adults that used stimulus payments to meet\ntheir spending needs in the past week\n(question removed in phase 4.0)",
  spend_ui = "Percentage of adults that used unemployment insurance (UI) benefits\nto meet their spending needs in the past week\n(question removed in phase 4.0)",
  telework = "Percentage of adults in households where at least one adult\nwhose work is typically in-person has begun working online\nbecause of the COVID-19 pandemic (question removed in phase 3.1)",
  uninsured = "Percentage of adults under 65 that have no health insurance\n(or only have insurance through the Indian Health Service)"
)

weekly_metric_ylab_list <- list(
  "food_insufficient" = "Percent Experiencing Food Insufficiency",
  "depression_anxiety_signs" = "Percent Experiencing Depression/Anxiety Signs",
  "expense_dif" = "Percent Experiencing Expense Difficulty",
  "uninsured" = "Percent Uninsured",
  "insured_public" = "Percent Having Public Health Insurance",
  "inc_loss_rv" = "Percent Experiencing Income Loss",
  "expect_inc_loss" = "Percent Expecting Income Loss",
  "rent_not_conf" = "Percent Feeling Uncertain about Rent Payments",
  "mortgage_not_conf" = "Percent Feeling Uncertain about Mortgage Payments",
  "rent_caughtup" = "Percent Feeling Caught Up on Rent Payments",
  "mortgage_caughtup" = "Percent Feeling Caught Up on Mortgage Payments",
  "spend_savings" = "Percent Using Savings to Meet Spending Needs",
  "spend_credit" = "Percent Using Credit Cards and Loans to Meet Spending Needs",
  "spend_ui" = "Percent Using Unemployment Insurance to Meet Spending Needs",
  "spend_stimulus" = "Percent Using Stimulus Payments to Meet Spending Needs",
  "telework" = "Percent Working Remotely",
  "eviction_risk" = "Percent Experiencing Risk of Eviction",
  "foreclosure_risk" = "Percent Experiencing Risk of Foreclosure",
  "spend_snap" = "Percent using SNAP to Meet Spending Needs",
  "mentalhealth_unmet" = "Percent Experiencing Unment Mental Health Needs"
)

all_races <- c("white", "black", "hispanic", "other", "asian", "total")
all_weeks_min <- 13
all_weeks_max <- 67
all_weeks <- all_weeks_min:all_weeks_max
all_geographies <- c(
  "US",
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
  "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
  "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
  "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
  "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
)

plot_estimates_for_var_state_time <- function(var = metrics[1], geo_var = all_geographies[1], week_nums = all_weeks, race_vars = all_races) {
  filtered_week_nums = str_glue("wk{week_nums}")

  # format breaks/labels so that x-axis contains, at most, 11 evenly spaced x-axis labels
  week_step <- ceiling(length(filtered_week_nums)/10)
  week_seq <- seq(1, length(filtered_week_nums), week_step)
  week_breaks <- filtered_week_nums[week_seq]
  week_labels <- pulse |>
    filter(week_num %in% week_breaks) |>
    pull(date_int) |>
    unique()

  title <- metric_title_list[[var]]
  ylab <- weekly_metric_ylab_list[[var]]


  weekly_plot_theme <- function() {
    theme(
      axis.title.x = element_text(family = "Helvetica", face = "bold", size = 8),
      axis.title.y = element_text(family = "Helvetica", face = "bold", size = 8),
      axis.text.x = element_text(family = "Helvetica", size = 6, angle = 45, hjust = 1),
      axis.text.y = element_text(family = "Helvetica", size = 6),
      plot.title = element_text(family = "Helvetica", face = "bold", size = 10, hjust = 0.5),
      plot.subtitle = element_text(family = "Helvetica", face = "bold", size = 10, hjust = 0.5),
      legend.text = element_text(face = "italic", family = "Helvetica"),
      legend.title = element_text(family = "Helvetica"),
    )
  }

  palette <- scales::brewer_pal(type = "qual", palette = "Dark2")(length(all_races))

  pulse |>
    filter(geography == geo_var, metric == var, week_num %in% filtered_week_nums, race_var %in% race_vars) |>
    ggplot(aes(x = week_num, y = mean, color = race_var, fill = race_var, group = race_var)) +
    geom_line() +
    geom_point() +
    geom_ribbon(aes(ymin = moe_95_lb, ymax = moe_95_ub), alpha = 0.5) +
    scale_x_discrete(breaks = week_breaks, labels = week_labels) +
    scale_y_continuous(labels = scales::percent) +
    scale_fill_manual(name = "Race", breaks = all_races, values = palette) +
    scale_color_manual(name = "Race", breaks = all_races, values = palette) +
    weekly_plot_theme() +
    labs(
         x = "Week",
         y = ylab,
         title = title,
         subtitle = "By Race, per Week"
    )
}

usa_sf <- function() {
  sf_path <- here("server", "static", "states_sf.rda")
  us <- read_rds(sf_path)

  # 4326 for laea
  return(sf::st_transform(us, crs = 4326))
}
us_states <- usa_sf()

plot_state_map <- function(race, week, variable) {
  week_str <- str_glue("wk{week}")
  data_metric <- pulse |>
    filter(metric == variable)

  summary_breaks <- data_metric |>
    pull(mean) |>
    summary() |>
    unname() |>
    as.numeric()

  data <- data_metric |>
    filter(week_num == week_str, race_var == race) |>
    left_join(us_states, c('geography'='iso_3166_2'))

  date_title <- data[1,] |> pull(date_int)

  national_map_theme <- function() {
    theme(
      panel.background = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      plot.title = element_text(family = "Helvetica", face = "bold", size = 10, hjust = 0.5),
      plot.subtitle = element_text(family = "Helvetica", face = "bold", size = 10, hjust = 0.5),
      legend.text = element_text(face = "italic", family = "Helvetica", size = 6),
      legend.position = "bottom",
      legend.key.width = unit(0.1, "npc")
    )
  }

  graph <- data |>
    ggplot() +
    geom_sf(aes(fill = mean, geometry = geometry), color = "black") +
    scale_fill_gradient2(element_blank(), low = "#D7191C", mid = "#FFFFBF", high = "#2C7BB6", midpoint = summary_breaks[3], breaks = summary_breaks[1:5], limits = c(summary_breaks[1],summary_breaks[5]), labels = function(x) case_when(
                                                                                                                                                                                                                                           x == summary_breaks[1] ~ scales::percent(x, suffix = "%\n(Min)"),
                                                                                                                                                                                                                                           x == summary_breaks[2] ~ scales::percent(x, suffix = "%\n(1st Qu)"),
                                                                                                                                                                                                                                           x == summary_breaks[3] ~ scales::percent(x, suffix = "%\n(Median)"),
                                                                                                                                                                                                                                           x == summary_breaks[4] ~ scales::percent(x, suffix = "%\n(Mean)"),
                                                                                                                                                                                                                                           x == summary_breaks[5] ~ scales::percent(x, suffix = "%+\n(3rd Qu.)"),
                                                                                                                                                                                                                                           TRUE ~ scales::percent(x)), oob = scales::oob_squish) +
    national_map_theme() +
    labs(title = metric_title_list[[variable]], subtitle = str_glue("{date_title}, Week {week}, Race = {race}"))

  graph
}

port <- 8080

http_bad_request <- list(
  status = 400,
  body = "400 Bad Request"
)
http_not_found <- list(
  status = 404,
  body = "404 Not Found"
)
http_method_not_allowed <- list(
  status = 405,
  body = "405 Method Not Allowed"
)

# From Shiny
# https://rdrr.io/cran/shiny/src/R/utils.R
# Assign value to the bottom element of the list x using recursive indices idx
assign_nested_list <- function(x = list(), idx, value) {
  for (i in seq_along(idx)) {
    sub <- idx[seq_len(i)]
    if (is.null(x[[sub]])) x[[sub]] <- list()
  }
  x[[idx]] <- value
  x
}
# From Shiny
# https://rdrr.io/cran/shiny/src/R/utils.R
parse_query_string <- function(str, nested = FALSE) {
  if (is.null(str) || nchar(str) == 0)
    return(list())

  # Remove leading ?
  if (substr(str, 1, 1) == "?")
    str <- substr(str, 2, nchar(str))

  pairs <- strsplit(str, "&", fixed = TRUE)[[1]]
  # Drop any empty items (if there's leading/trailing/consecutive '&' chars)
  pairs <- pairs[pairs != ""]
  pairs <- strsplit(pairs, "=", fixed = TRUE)

  keys   <- vapply(pairs, function(x) x[1], FUN.VALUE = character(1))
  values <- vapply(pairs, function(x) x[2], FUN.VALUE = character(1))
  # Replace NA with '', so they don't get converted to 'NA' by URLdecode
  values[is.na(values)] <- ""

  # Convert "+" to " ", since URLdecode doesn't do it
  keys   <- gsub("+", " ", keys,   fixed = TRUE)
  values <- gsub("+", " ", values, fixed = TRUE)

  keys   <- URLdecode(keys)
  values <- URLdecode(values)

  res <- stats::setNames(as.list(values), keys)
  if (!nested) return(res)

  # Make a nested list from a query of the form ?a[1][1]=x11&a[1][2]=x12&...
  for (i in grep("\\[.+\\]", keys)) {
    k <- strsplit(keys[i], "[][]")[[1L]]  # split by [ or ]
    res <- assign_nested_list(res, k[k != ""], values[i])
    res[[keys[i]]] <- NULL    # remove res[['a[1][1]']]
  }
  res
}
parse_query_string_list <- function(str) unlist(strsplit(str, ","))

# returns true if x is a subset of y
subset_of <- function(x, y) length(setdiff(y, x)) + length(x) == length(y)

weekly_handler <- list(
  GET = function(request) {
    query <- parse_query_string(request$QUERY_STRING)

    # get metric from query string
    metric <- query[["metric"]]
    # if null, default to first metric
    metric_var <- metrics[1]
    if (!is.null(metric)) {
      metric_var <- metric
    }
    # provided metric should be one of available metrics
    if (!metric_var %in% metrics) {
      return(http_bad_request)
    }

    # get race from query string
    race <- query[["race"]]
    # if null, default to all_races, otherwise parse
    race_list_str <- all_races
    if (!is.null(race)) {
      race_list_str <- parse_query_string_list(race)
    }
    # provided race list should be a subset of available races
    if (!subset_of(race_list_str, all_races)) {
      return(http_bad_request)
    }


    # get weeks from query string
    week_min <- query[["week_min"]]
    # if null, default to first in all_weeks, otherwise parse
    week_min_num <- all_weeks_min
    if (!is.null(week_min)) {
      week_min_num <- as.numeric(week_min)
      # error if not numeric
      if (is.na(week_min_num)) {
        return(http_bad_request)
      }
      # error if too small
      if (week_min_num < all_weeks_min) {
        return(http_bad_request)
      }
    }

    week_max <- query[["week_max"]]
    week_max_num <- all_weeks_max
    if (!is.null(week_max)) {
      week_max_num <- as.numeric(week_max)
      # error if not numeric
      if (is.na(week_max_num)) {
        return(http_bad_request)
      }
      # error if too big
      if (week_max_num > all_weeks_max) {
        return(http_bad_request)
      }
    }

    # get geography from query string
    geography <- query[["geography"]]
    # if null, default to first geography
    geography_var <- all_geographies[1]
    if (!is.null(geography)) {
      geography_var <- geography
    }
    # provided geography should be a subset of available geographies
    if (!geography_var %in% all_geographies) {
      return(http_bad_request)
    }

    response_filename <- paste(metric_var, paste0(race_list_str, collapse = "-"), week_min_num, week_max_num, geography_var, sep = "-") |>
      paste0(".png")
    response_filepath <- here("server", "tmp", "weekly", response_filename)
    # if img file does not exist, plot and save it
    if (!file.exists(response_filepath)) {
      plot_estimates_for_var_state_time(var = metric_var, race_vars = race_list_str, week_nums = week_min_num:week_max_num, geo = geography_var)
      ggsave(response_filepath, create.dir = TRUE)
    }
    response_png <- read_file_raw(response_filepath)
    return(list(
      status = 200,
      headers = list(
        "content-type" = "image/png"
      ),
      body = response_png
    ))
  }
  # POST = function (request) { ... }
)

national_handler <- list(
  GET = function(request) {
    query <- parse_query_string(request$QUERY_STRING)

    # get metric from query string
    metric <- query[["metric"]]
    # if null, default to first metric
    metric_var <- metrics[1]
    if (!is.null(metric)) {
      metric_var <- metric
    }
    # provided metric should be one of available metrics
    if (!metric_var %in% metrics) {
      return(http_bad_request)
    }

    # get week from query string
    week <- query[["week"]]
    # if null, default to last week
    week_num <- all_weeks_max
    if (!is.null(week)) {
      week_num <- as.numeric(week)
      # error if not numeric
      if (is.na(week_num)) {
        return(http_bad_request)
      }
      # error if outside range of all_weeks
      if (week_num > all_weeks_max | week_num < all_weeks_min) {
        return(http_bad_request)
      }
    }

    # get race from query string
    race <- query[["race"]]
    # if null, default to aggregate (total)
    race_var <- "total"
    if (!is.null(race)) {
      race_var <- race
    }
    # provided race should be a subset of available races
    if (!race_var %in% all_races) {
      return(http_bad_request)
    }

    response_filename <- paste(metric_var, race_var, week_num, sep = "-") |>
      paste0(".png")
    response_filepath <- here("server", "tmp", "national", response_filename)
    if (!file.exists(response_filepath)) {
      plot_state_map(race_var, week_num, metric_var)
      ggsave(response_filepath, create.dir = TRUE, width = 1800, height = 1200, units = "px")
    }
    response_png <- read_file_raw(response_filepath)

    return(list(
      status = 200,
      headers = list(
        "content-type" = "image/png"
      ),
      body = response_png
    ))
  }
)

routes <- list(
  "/weekly" = weekly_handler,
  "/national" = national_handler,
  # Required by App Engine.
  "/_ah/health" = list(
    GET = function(request) list()
  )
)

router <- function(routes, request) {
  # Pick the right handler for this path and method.
  # Respond with 404s and 405s if the handler isn't found.
  if (!request$PATH_INFO %in% names(routes)) {
    return(http_not_found)
  }
  path_handler <- routes[[request$PATH_INFO]]

  if (!request$REQUEST_METHOD %in% names(path_handler)) {
    return(http_method_not_allowed)
  }
  method_handler <- path_handler[[request$REQUEST_METHOD]]

  return(method_handler(request))
}

logger <- function(request) {
  query <- parse_query_string(request$QUERY_STRING)
  query_string <- paste(names(query), query, sep = "=", collapse = ", ")
  cat(paste(Sys.time(), request$REQUEST_METHOD, request$PATH_INFO, query_string, "\n"))
}

app <- list(
  call = function(request) {
    logger(request)
    response <- router(routes, request)

    # Provide some defaults for the response
    # to make handler code simpler.
    if (!"status" %in% names(response)) {
      response$status <- 200
    }
    if (!"headers" %in% names(response)) {
      response$headers <- list()
    }
    if (!"Content-Type" %in% names(response$headers)) {
      response$headers[["Content-Type"]] <- "text/plain"
    }

    return(response)
  }
)

# assert_that(names(var_title_list) == metrics)
# assert_that(names(var_ylab_list) == metrics)

cat(paste0("Server listening on :", port, "...\n"))
runServer("0.0.0.0", port, app)
