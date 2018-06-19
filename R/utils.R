leading_nas <- function(data) {
  i <- 0
  while (is.na(data[i+1])) {
    i <- i + 1
  }
  return(i)
}

trailing_nas <- function(data) {
  i <- 0
  while (is.na(data[length(data)-i])) {
    i <- i + 1
  }
  return(i)
}

get_start_date <- function(date_col, frequency) {
  start <- min(date_col)
  if (frequency == "quarter") {
    return(c(lubridate::year(start), lubridate::quarter(start)))
  } else if (frequency == "month") {
    return(c(lubridate::year(start), lubridate::month(start)))
  } else if (frequency == "day") {
    return(c(lubridate::year(start), lubridate::yday(start)))
  } else {
    stop(paste0("Don't know how to handle frequency ", frequency))
  }
}

frequency_number <- function(frequency) {
  if (frequency == "quarter") {
    return(4)
  } else if (frequency == "month") {
    return(12)
  } else if (frequency == "day") {
    return(365)
  }
}

get_date_col <- function(data) {
  date_col <- NULL
  for (col in colnames(data)) {
    if (lubridate::is.Date(data[[col]])) {
      if (is.null(date_col)) {
        date_col <- col
      } else {
        stop("More than one date column in your data.")
      }
    }
  }

  if (!is.null(date_col)) {
    return(date_col)
  } else {
    stop("Could not find a column of dates in your data.")
  }
}

find_frequency <- function(dates) {
  start <- min(dates)
  end <- max(dates)
  for (posit in c("year", "quarter", "month", "day")) {
    viable_seq <- seq.Date(from = start, to = end, by = posit)
    if (all(dates %in% viable_seq)) {
      return(posit)
    }
  }
  stop("Unable to determine frequency of data.")
}

regularise <- function(data, date_col, frequency, group_vars) {
  if (any(duplicated(data[[date_col]]))) {
    stop("You have duplicate dates within a group. Have you correctly grouped your data?")
  }
  start <- min(data[[date_col]])
  end <- max(data[[date_col]])
  reg_seq <- seq.Date(from = start, to = end, by = frequency)
  staging_tibble <- tibble::tibble(full_dates = reg_seq)
  joinNames <- stats::setNames("full_dates", date_col)
  widened <- dplyr::right_join(data, staging_tibble, by = joinNames)
  # And now ensure that any new vars get the correct values for each of the group variables
  for (var in group_vars) {
    val <- unique(data[[var]])
    val <- val[!is.na(val)]
    widened[[var]] <- val
  }
  return(widened)
}
