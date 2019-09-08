dict_apply <- function(x, dict) {
  if (is.character(x)) {
    x <- tokenizers::tokenize_words(
      x, lowercase = TRUE, strip_punct = TRUE, strip_numeric = FALSE
    )
  }
  dapr::vap_dbl(x, ~ sum(dict$weight[match(.x, dict$word)], na.rm = TRUE))
}
