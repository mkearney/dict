
setwd("~/rstats/meanrtemplate")
unlink("../testdic", recursive = TRUE)
getwd()
remove.packages("testdic")
## vector of positive words
pos <- c("like", "love", "amazing", "excellent", "great", "fantastic",
  "incredible", "awesome", "best", "favorite", "fan", "fun", "enjoyed",
  "enjoyed", "good", "solid", "better", "soooo", "happy")

## vetor of negative words
neg <- c("hate", "loathe", "dislike", "awful", "horrible", "worst",
  "miserable", "ruin", "ruining", "destroy", "destroyed", "destroying",
  "pathetic", "hated", "hateful", "unhappy", "horrifies", "horrifying",
  "terrible")

write_utf8 <- function(x, path, ...) {
  opts <- options(encoding = "native.enc")
  on.exit(options(opts), add = TRUE)
  writeLines(enc2utf8(x), path, ...)
}

write_pos_neg <- function(x, path) {
  x <- attr(x, "dict")
  pos <- unique(x$word[x$weight > 0])
  neg <- unique(x$word[x$weight < 0])
  write_utf8(pos, file.path(path, "src/hashtable/maker/positive.txt"))
  tfse::print_complete("Save positive word list")
  write_utf8(neg, file.path(path, "src/hashtable/maker/negative.txt"))
  tfse::print_complete("Save negative word list")
}

make_hashtables <- function(path) {
  #od <- getwd()
  #on.exit(setwd(od), add = TRUE)
  #setwd("src/hashtable/maker")

  ## create words file
  system(
    paste0("cd ", file.path(path, "src/hashtable/maker"), " && sh ./makewords.sh")
  )
  tfse::print_complete("Create hash words")

  ## create hash files
  system(
    paste0("cd ", file.path(path, "src/hashtable/maker"), " && sh ./make2tables.sh")
  )
  tfse::print_complete("Create hash tables")

  ## change size_t to pointer
  x <- tfse::readlines(file.path(path, "src/hashtable/maker/neghash.h"))
  x <- sub("int\\)\\(size_t", "intptr_t", x)
  writeLines(x, file.path(path, "src/hashtable/maker/neghash.h"))
  x <- tfse::readlines(file.path(path, "src/hashtable/maker/poshash.h"))
  x <- sub("int\\)\\(size_t", "intptr_t", x)
  writeLines(x, file.path(path, "src/hashtable/maker/poshash.h"))

  ## move hash files
  if (file.exists(file.path(path, "src/hashtable/neghash.h")))
    file.remove(file.path(path, "src/hashtable/neghash.h"))
  if (file.exists(file.path(path, "src/hashtable/poshash.h")))
    file.remove(file.path(path, "src/hashtable/poshash.h"))
  file.copy(file.path(path, "src/hashtable/maker/poshash.h"),
    file.path(path, "src/hashtable/poshash.h"))
  file.copy(file.path(path, "src/hashtable/maker/neghash.h"),
    file.path(path, "src/hashtable/neghash.h"))
  file.remove(file.path(path, "src/hashtable/maker/poshash.h"))
  file.remove(file.path(path, "src/hashtable/maker/neghash.h"))
}


create_dict_pkg <- function(d,
                            path,
                            open = FALSE,
                            fields = NULL,
                            rstudio = TRUE) {
  usethis::create_package(path, fields, rstudio, open = FALSE)
  dir.create(file.path(path, "inst"))
  file.copy(
    "../meanrtemplate/inst/sexputils",
    file.path(path, "inst/"),
    recursive = TRUE
  )
  file.copy(
    "../meanrtemplate/src",
    file.path(path, "./"),
    recursive = TRUE
  )
  file.copy(
    "../meanrtemplate/R",
    file.path(path, "./"),
    recursive = TRUE
  )
  s <- tfse::readlines(file.path(path, "R/score.r"))
  s <- gsub("meanrtemplate", basename(path), s)
  writeLines(gsub("meanr", basename(path), s), file.path(path, "R/score.r"))
  s <- tfse::readlines(file.path(path, "src/native.c"))
  writeLines(gsub("meanr", basename(path), s), file.path(path, "src/native.c"))
  file.copy(
    "../meanrtemplate/cleanup",
    file.path(path, "./")
  )
  file.copy(
    "../meanrtemplate/configure",
    file.path(path, "./")
  )
  write_pos_neg(d, path)
  make_hashtables(path)
  devtools::load_all(path)
  devtools::document(path)
  devtools::install(path, build = TRUE)
}

#file.remove(file.path(path, "NAMESPACE"))
d <- dict::dict(list(pos = pos, neg = neg))
open = FALSE
fields = NULL
rstudio = TRUE
path <- "~/rstats/testdic"
create_dict_pkg(d, path)

txt <- c("love amazing excellent good",
  "hate loathe horrifies unhappy terrible",
  "awesome best hateful hated worst")
testdic:::score(txt)
