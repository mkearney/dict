#' score
#'
#' Computes word-based dictionary score via the sum of the total number of positive and
#' negative scored words. The function is vectorized so that it will return one
#' row per string. The scoring function ignores (upper/lower) case and
#' punctuation.
#'
#' @details
#' The scoring function uses OpenMP to process text in parallel.
#'
#' @param s A string or vector of strings.
#' @param nthreads Number of threads to use. By default it will use the total
#'   number of cores + hyperthreads.
#'
#' @return
#' A dataframe, consisting of columns "positive", "negative", "score", and "wc".
#' With the exception of "score", these are counts; that is, "positive" is the
#' number of positively-coded words, "negative" is the number of negatively-
#' coded words, and "wc" is the wordcount (total number of words).
#'
#' @useDynLib meanrtemplate R_score
#' @export
score <- function(s, nthreads = NULL) {
  if (is.null(nthreads)) {
    nthreads <- get_nthreads()
  }
  .Call(R_score, s, nthreads)
}

#' @inheritParams score
#' @useDynLib meanrtemplate R_score_score
#' @rdname score
#' @export
score_score <- function(s, nthreads = NULL) {
  if (is.null(nthreads)) {
    nthreads <- get_nthreads()
  }
  .Call(R_score_score, s, nthreads)
}

#' @useDynLib meanrtemplate R_get_nthreads
get_nthreads <- function() {
  .Call(R_get_nthreads)
}
