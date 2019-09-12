#' Use dictionary
#'
#' Calculates counts based on word dictionaries
#'
#' @param x Input text vector
#' @param dict A word dictionary
#' @return A data frame with the number of postively and negatively coded words,
#'   the overall score (sum of positive and negative), and the total word count.
#' @keywords internal
#' @export
dict_score <- function(x, dict) {
  if (is.character(x)) {
    x <- tokenizers::tokenize_words(
      x, lowercase = TRUE, strip_punct = TRUE, strip_numeric = FALSE
    )
  }
  pos <- dapr::vap_int(x, ~ sum(.x %in% dict$word[dict$weight > 0L]))
  neg <- dapr::vap_int(x, ~ sum(.x %in% dict$word[dict$weight < 0L]))
  score <- pos - neg
  data.frame(
    positive = pos,
    negative = neg,
    score    = score,
    wc       = lengths(x)
  )
}
#' @inheritParams dict_score
#' @rdname dict_score
#' @keywords internal
#' @export
dict_score_score <- function(x, dict) {
  if (is.character(x)) {
    x <- tokenizers::tokenize_words(
      x, lowercase = TRUE, strip_punct = TRUE, strip_numeric = FALSE
    )
  }
  dapr::vap_dbl(x, ~ sum(dict$weight[match(.x, dict$word)], na.rm = TRUE))
}
