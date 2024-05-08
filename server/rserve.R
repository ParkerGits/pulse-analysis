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

data_path <- here("server", "static", "phase2_all.csv")
pulse <- read_csv(data_path)

metrics <- c(
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
  "eviction_risk",
  "foreclosure_risk",
  "learning_fewer",
  "spend_snap"
)

var_title_list <- list(
  "food_insufficient" = "Mean share of adults in households where there was often or sometimes not enough food\nin the past week by Race, per Week",
  "depression_anxiety_signs" = "Mean share of adults that experienced symptoms of depression or anxiety disorders\nin the last week by Race, per Week",
  "expense_dif" = "Mean share of adults that experienced difficulty paying household expenses in past 7 days\nby Race, per Week"
)

var_ylab_list <- list(
  "food_insufficient" = "Food Insufficiency Rate",
  "depression_anxiety_signs" = "Depression/Anxiety Rate",
  "expense_dif" = "Expense Difficulty Rate"
)

all_races <- c("white", "black", "hispanic", "other", "asian", "total")
all_weeks <- 13:63
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
  week_seq <- seq(1, length(filtered_week_nums), ceiling(length(filtered_week_nums)/10))
  week_breaks <- pulse$week_num[week_seq]
  week_labels <- pulse$date_int[week_seq]

  title <- var_title_list[[var]]
  ylab <- var_ylab_list[[var]]

  pulse |>
    filter(geography == geo_var, metric == var, week_num %in% filtered_week_nums, race_var %in% race_vars) |>
    ggplot(aes(x = week_num, y = mean, color = race_var, fill = race_var, group = race_var)) +
    geom_line() +
    geom_point() +
    geom_ribbon(aes(ymin = moe_95_lb, ymax = moe_95_ub), alpha = 0.5) +
    scale_x_discrete(breaks = week_breaks, labels = week_labels) +
    scale_fill_discrete(name = "Race") +
    scale_color_discrete(name = "Race") +
    labs(x = "Week",
         y = ylab,
         title = title)
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
    week_min_num <- all_weeks[1]
    if (!is.null(week_min)) {
      week_min_num <- as.numeric(week_min)
      # error if not numeric
      if (is.na(week_min_num)) {
        return(http_bad_request)
      }
    }

    week_max <- query[["week_max"]]
    week_max_num <- all_weeks[length(all_weeks)]
    if (!is.null(week_max)) {
      week_max_num <- as.numeric(week_max)
      # error if not numeric
      if (is.na(week_max_num)) {
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

    response_filename <- paste0(paste(metric_var, paste0(race_list_str, collapse = "-"), week_min_num, week_max_num, geography_var, sep = "-"), ".png")
    response_filepath <- here("server", "tmp", response_filename)
    # if img file does not exist, plot and save it
    if (!file.exists(response_filepath)) {
      plot_estimates_for_var_state_time(var = metric_var, race_vars = race_list_str, week_nums = week_min_num:week_max_num, geo = geography_var)
      ggsave(response_filepath, create.dir = TRUE)
    }
    response_png <- read_file_raw(response_filepath)
    return(list(
      status = 200,
      headers = list(
        "Content-Type" = "image/png"
      ),
      body = response_png
    ))
  }
  # POST = function (request) { ... }
)

routes <- list(
  "/weekly" = weekly_handler,
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
