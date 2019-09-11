#' Create an R package
#'
#' Exports one or more word dictionaries as a standalone R package
#'
#' @param d Word dictionary created by \code{\link{dict()}}
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param fields A named list of fields to add to DESCRIPTION, potentially
#'   overriding default values. See use_description() for how you can set
#'   personalized defaults using pack?age options
#' @param rstudio If TRUE, calls use_rstudio() to make the new package or
#'   project into an RStudio Project. If FALSE and a non-package project, a
#'   sentinel .here file is placed so that the directory can be recognized as a
#'   project by the here or rprojroot packages.
#' @param open If TRUE, activates the new project
#' @return Path to the newly created project or package, invisibly.
#' @examples
#' ## create dict
#' d <- dict(list(
#'   pos = c("good", "great", "awesome"),
#'   neg = c("worst", "awful", "terrible")))
#'
#' ## create package path via temp directory
#' path_pkg <- file.path(tempdir(), "simpleexample")
#'
#' ## create R package featuring d
#' create_dict_pkg(d, path_pkg)
#'
#' ## create txt vector to test package on
#' txt <- c("good great terrible terrible",
#'   "good", "good", "other", "awful",
#'   "awful", "good", "great", "terrible")
#'
#' ## use new package on txt
#' simpleexample::score(txt)
#'
#' }
#' @export
create_dict_pkg <- function(d,
                            path,
                            open = FALSE,
                            fields = NULL,
                            rstudio = TRUE) {
  usethis::create_package(path, fields, rstudio, open = FALSE)
  if (!dir.exists(file.path(path, "inst"))) {
    dir.create(file.path(path, "inst"))
  }
  tmp <- system.file("rpkg", "templates", "meanrtemplate", package = "dict")
  file.copy(
    file.path(tmp, "../meanrtemplate/inst/sexputils"),
    file.path(path, "inst/"),
    recursive = TRUE
  )
  file.copy(
    file.path(tmp, "../meanrtemplate/src"),
    file.path(path, "./"),
    recursive = TRUE
  )
  file.copy(
    file.path(tmp, "../meanrtemplate/R"),
    file.path(path, "./"),
    recursive = TRUE
  )
  s <- tfse::readlines(file.path(path, "R/score.r"))
  s <- gsub("meanrtemplate", basename(path), s)
  writeLines(gsub("meanr", basename(path), s), file.path(path, "R/score.r"))
  s <- tfse::readlines(file.path(path, "src/native.c"))
  writeLines(gsub("meanr", basename(path), s), file.path(path, "src/native.c"))
  file.copy(
    file.path(tmp, "../meanrtemplate/cleanup"),
    file.path(path, "./")
  )
  file.copy(
    file.path(tmp, "../meanrtemplate/configure"),
    file.path(path, "./")
  )
  write_pos_neg(d, path)
  make_hashtables(path)
  devtools::load_all(path)
  devtools::document(path)
  devtools::install(path, build = TRUE)
  if (open) {
    if (usethis:::proj_activate(path)) {
      on.exit()
    }
  }
  invisible(usethis:::proj_get())
}


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
