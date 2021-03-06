#' Use test subdirectories
#'
#' Create a subdir in \file{tests/testthat/} and optionally an R script
#' containing a helper function to run all tests in that subdir. Useful for
#' separating long-running tests from your unit tests, or storing tests that
#' you do not want to run on CRAN or during R CMD Check. For running tests in
#' \file{tests/testthat/} subdirectories see [`test_subdir()`].
#'
#' @inheritSection test_subdir Test subdirectory presets
#'
#' @param path Character scalar. Will be processed with [base::make.names()] to
#'   make a syntactically valid name.
#' @param make_tester Logical or character scalar. Create an R script with a
#'   test helper function. If `TRUE` an R script file will be placed into the
#'   \file{R/} directory of the current package, containing a function definition
#'   for running the tests in `path`. The file will be named
#'   \file{testthis-testers.R}, but you can specify  your own name by
#'   passing a character scalar to make_tester. See [use_tester()] for details.
#' @param ignore_tester Logical. Add \file{tester} file to \file{.Rbuildignore}?
#' @seealso [`test_subdir()`]
#' @family infrastructure
#'
#' @return `TRUE` on success (invisibly).
#' @export
#'
#' @examples
#' \dontrun{
#' use_test_subdir("special_tests", make_tester = TRUE)
#'
#' ## Reload the Package manually...
#' ## Create some tests in tests/testthat/test_special_tests/
#'
#' test_special_tests()
#' }
#'
use_test_subdir <- function(
  path,
  make_tester = TRUE,
  ignore_tester = TRUE
){
  # Preconditions
  assert_that(is.scalar(path) && is.character(path))
  assert_that(is.scalar(make_tester))
  assert_that(is.scalar(is.logical(make_tester) || is.character(make_tester)))

  # Process arguments
  path <- make.names(path)

  # Logic
  usethis::use_directory(
    file.path("tests", "testthat", path),
    ignore = FALSE
  )

  if (is.character(make_tester)) {
    use_tester(path, tester_path = make_tester, ignore = ignore_tester)
  } else if (make_tester) {
    use_tester(path, ignore = ignore_tester)
  }


  invisible(TRUE)
}




#' Use a tester function
#'
#' Quickly create an \R script that contains a function for running all tests
#' in a predefined directory. This function powers the `make_tester` option
#' of [use_test_subdir()] and you will likely not need to run it manually.
#'
#' @param path Name of the subdirectory oft \file{tests/testthat/} for which
#'   to create a tester function.
#' @param ignore Logical. Add `tester_path` to \file{.Rbuildignore}?
#' @param tester_path \R script file in which to store the tester functions
#'
#' @return `TRUE` on success (invisibly).
#' @export
#' @family infrastructure
#'
use_tester <- function(
  path,
  ignore = TRUE,
  tester_path = file.path("R", "testthis-testers.R")
){
  fname   <- file.path(usethis::proj_get(), tester_path)
  funname <- paste0("test_", path)

  message(sprintf("creating tester function %s() in %s", funname, fname))
  rcode <- sprintf('%s <- function() testthis::test_subdir("%s")\n', funname, path)

  if(!file.exists(tester_path)){
    rcode <- paste0(
      "# Generated by testthis::use_tester; do not edit by hand\n\n",
      rcode
    )
  }

  write(rcode, fname, append = TRUE)

  if(ignore) {
    usethis::use_build_ignore(tester_path)
  }

  invisible(TRUE)
}




#' @export
#' @rdname use_test_subdir
use_integration_tests <- function(){
  use_test_subdir(
    unlist(options('testthis.integration_tests_path')),
    make_tester = FALSE
  )
}




#' @export
#' @rdname use_test_subdir
use_acceptance_tests <- function(){
  use_test_subdir(
    unlist(options('testthis.acceptance_tests_path')),
    make_tester = FALSE
  )
}




#' @export
#' @rdname use_test_subdir
use_manual_tests <- function(){
  use_test_subdir(
    unlist(options('testthis.manual_tests_path')),
    make_tester = FALSE
  )
}
