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

phase_breaks <- c("wk13", "wk18", "wk28", "wk34", t(distinct(pulse["week_num"]))[seq(28,50,3)])
week_labels <- c("08/19/2020",
                 "10/28/2020",
                 "04/14/2021",
                 "07/21/2021",
                 "12/01/2021",
                 "03/02/2022",
                 "06/01/2022",
                 "09/14/2022",
                 "12/09/2022",
                 "03/01/2023",
                 "06/07/2023",
                 "08/23/2023")
phase_labels <- c("Phase 2", "Phase 3", paste("Phase 3.", 1:10, sep = ""))

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
             "spend_snap")



plot_variable_by_week_race <- function (variable, y = "", title = waiver(), phase_y = 0.10, y_upper = NA) {
  variable_by_week_race <- pulse |>
    filter(metric == variable, geo_type == "national")


  p <- ggplot(variable_by_week_race, aes(x=week_num, y=mean, color = race_var, group = race_var)) +
    geom_vline(xintercept = phase_breaks, color = "gray", linetype="dashed") +
    geom_line() +
    geom_point() +
    scale_x_discrete(breaks=phase_breaks, labels = week_labels) +
    scale_y_continuous(labels = scales::percent) +
    scale_color_discrete(name = "Race") +
    labs(title = title,
         x = "Date",
         y = y) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  for (i in 1:12) {
    p <- p + annotate("text", x=phase_breaks[i], label=paste("\n", phase_labels[i], " Begins", sep=""), y=phase_y, colour="lightgrey", angle=90)
  }

  p
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

weekly_handler <- list(
  GET = function(request) {
    query <- parse_query_string(request$QUERY_STRING)
    metric <- query[["metric"]]
    if (is.null(metric) | !metric %in% metrics) {
      return(http_bad_request)
    }
    response_filepath <- here("server", "tmp", paste0(metric, ".png"))
    if (!file.exists(response_filepath)) {
      plot_variable_by_week_race(metric)
      ggsave(response_filepath)
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

cat(paste0("Server listening on :", port, "...\n"))
runServer("0.0.0.0", port, app)
