library(httpuv)

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

PORT <- 8080

http_not_found <- list(
  status=404,
  body='404 Not Found'
)
http_method_not_allowed <- list(
  status=405,
  body='405 Method Not Allowed'
)

# From Shiny
# https://rdrr.io/cran/shiny/src/R/utils.R
parse_query_string <- function(str, nested = FALSE) {
  if (is.null(str) || nchar(str) == 0)
    return(list())

  # Remove leading ?
  if (substr(str, 1, 1) == '?')
    str <- substr(str, 2, nchar(str))

  pairs <- strsplit(str, '&', fixed = TRUE)[[1]]
  # Drop any empty items (if there's leading/trailing/consecutive '&' chars)
  pairs <- pairs[pairs != ""]
  pairs <- strsplit(pairs, '=', fixed = TRUE)

  keys   <- vapply(pairs, function(x) x[1], FUN.VALUE = character(1))
  values <- vapply(pairs, function(x) x[2], FUN.VALUE = character(1))
  # Replace NA with '', so they don't get converted to 'NA' by URLdecode
  values[is.na(values)] <- ''

  # Convert "+" to " ", since URLdecode doesn't do it
  keys   <- gsub('+', ' ', keys,   fixed = TRUE)
  values <- gsub('+', ' ', values, fixed = TRUE)

  keys   <- URLdecode(keys)
  values <- URLdecode(values)

  res <- stats::setNames(as.list(values), keys)
  if (!nested) return(res)

  # Make a nested list from a query of the form ?a[1][1]=x11&a[1][2]=x12&...
  for (i in grep('\\[.+\\]', keys)) {
    k <- strsplit(keys[i], '[][]')[[1L]]  # split by [ or ]
    res <- assignNestedList(res, k[k != ''], values[i])
    res[[keys[i]]] <- NULL    # remove res[['a[1][1]']]
  }
  res
}

hello_handler <- list(
  GET = function(request) {
    query <- parse_query_string(request$QUERY_STRING)
    cat(paste(names(query), query, sep = "=", collapse=", "))
    list(body = "Hello world")
  }
  # POST = function (request) { ... }
)

routes <- list(
  '/hello' = hello_handler,
  # Required by App Engine.
  '/_ah/health' = list(
    GET = function (request) list()
  )
)

router <- function (routes, request) {
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

app <- list(
  call = function (request) {
    response <- router(routes, request)

    # Provide some defaults for the response
    # to make handler code simpler.
    if (!'status' %in% names(response)) {
      response$status <- 200
    }
    if (!'headers' %in% names(response)) {
      response$headers <- list()
    }
    if (!'Content-Type' %in% names(response$headers)) {
      response$headers[['Content-Type']] <- 'text/plain'
    }

    return(response)
  }
)

cat(paste0("Server listening on :", PORT, "...\n"))
runServer("0.0.0.0", PORT, app)
