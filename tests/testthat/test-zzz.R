test_that("linting", {
  # lintr has issues in R CMD check: https://github.com/jimhester/lintr/issues/421
  find_package <- function(path) {
    path <- normalizePath(path, mustWork = FALSE)

    while (!file.exists(file.path(path, "DESCRIPTION"))) {
      path <- dirname(path)
      if (identical(path, dirname(path))) {
        return(NULL)
      }
    }

    path
  }

  if (!is.null(find_package("."))) {
    lintr::expect_lint_free()
  } else {
    skip("lintr not run: https://github.com/jimhester/lintr/issues/421")
  }
})
