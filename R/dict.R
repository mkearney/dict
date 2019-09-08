#' Create word dictionary
#'
#' @param x Input can be a vector of words, a list of 'positive' and 'negative'
#'   word vectors, a data frame with 'word' and 'weight' columns
#'
#' @examples
#'
#' pos <- c("like", "love", "amazing", "excellent", "great", "fantastic",
#'   "incredible", "awesome", "best", "favorite", "fan", "fun", "enjoyed",
#'   "enjoyed", "good", "solid", "better", "soooo", "happy")
#' neg <- c("hate", "loathe", "dislike", "awful", "horrible", "worst",
#'   "miserable", "ruin", "ruining", "destroy", "destroyed", "destroying",
#'   "pathetic", "hated", "hateful", "unhappy", "horrifies", "horrifying",
#'   "terrible")
#'
#' ## create dictionary using only positive words
#' dict(pos)
#'
#' ## create dictionary using only negative words
#' dict(neg)
#'
#' ## create dictionary using both positive and negative words
#' d <- dict(list(pos = pos, neg = neg))
#'
#' ## view up to n entries of dictionary
#' print(d, n = 100)
#'
#' ## example text
#' txt <- c("love amazing excellent good",
#'   "hate loathe horrifies unhappy terrible",
#'   "awesome best hateful hated worst")
#'
#' ## get estimate for each element of txt using pos/neg dictionary
#' d(txt)
#'
#' ## create tibble
#' tibble::tibble(
#'   text = txt,
#'   sent = d(txt)
#' )
#'
#' @return A dictionary
#' @export
dict <- function(x) {
  UseMethod("dict")
}

#' @export
dict.list <- function(x) {
  stopifnot(
    is.character(x[[1]]),
    length(x) < 3
  )
  ## create second element if necessary
  if (length(x) == 1) {
    x[[2]] <- character()
  }
  ## order elements
  if (!is.null(names(x))) {
    x <- x[c(grep("pos|^$", names(x)), grep("pos|^$", names(x), invert = TRUE))]
  }
  ## create tibble
  x <- tibble::tibble(
    word = unlist(x),
    weight = c(
      rep(1, length(x[[1]])),
      rep(-1, length(x[[2]]))
    )
  )
  ## pass to dict
  dict(x)
}

#' @export
dict.character <- function(x) {
  x <- tibble::tibble(word = x, weight = 1)
  dict(x)
}

#' @export
dict.data.frame <- function(x) {
  x <- tibble::as_tibble(x)
  dict(x)
}

#' @export
dict.tbl_df <- function(x) {
  stopifnot(is.character(x[[1]]), ncol(x) < 3)
  names(x)[1] <- "word"
  if (ncol(x) == 1) {
    x$weight <- 1
  } else {
    stopifnot(is.numeric(x[[2]]))
    names(x)[2] <- "weight"
  }
  f <- function(txt) dict_apply(txt, x)
  attr(f, "dict") <- dict
  structure(f,
    class = c("dict", "function"),
    dict = x)
}

#' @export
print.dict <- function(x, ...) {
  cat("# A dict[ionary]", fill = TRUE)
  print(attr(x, "dict"), ...)
  invisible(x)
}
