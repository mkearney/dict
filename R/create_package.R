#' Create an R package
#'
#' Exports one or more word dictionaries as a standalone R package
#'
#' @param d Word dictionary created by \code{\link{dict}}
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param rstudio If TRUE, calls use_rstudio() to make the new package or
#'   project into an RStudio Project. If FALSE and a non-package project, a
#'   sentinel .here file is placed so that the directory can be recognized as a
#'   project by the here or rprojroot packages.
#' @param open If TRUE, activates the new project
#' @return Path to the newly created project or package, invisibly.
#' @details The created package is modelled off the extremely fast meanr
#'   package, which means it requires compilation but is extremely fast.
#' @examples
#'
#' ## create dict
#' d <- dict(list(
#'   pos = c("good", "great", "awesome"),
#'   neg = c("worst", "awful", "terrible")))
#'
#' ## create package path via temp directory
#' path_pkg <- file.path(tempdir(), "simpleexample")
#'
#' ## create R package featuring d
#' #create_dict_pkg(d, path_pkg)
#'
#' ## create txt vector to test package on
#' txt <- c("good great terrible terrible",
#'   "good", "good", "other", "awful",
#'   "awful", "good", "great", "terrible")
#'
#' ## use new package on txt
#' #simpleexample::score(txt)
#'
#' @export
create_dict_pkg <- function(d,
                            path,
                            open = FALSE,
                            rstudio = TRUE) {
  if (basename(path) %in% utils::installed.packages()) {
    suppressMessages(utils::remove.packages(basename(path)))
  }
  usethis::create_package(path,
    list(Version = "0.0.1",
      Title = "Word Dictionary Analysis Scorer",
      Description = "Data and functions for a natural language word dictionary",
      Depends = 'R (>= 3.0.0)',
      LazyData = 'yes',
      LazyLoad = 'yes',
      NeedsCompilation = 'yes',
      ByteCompile = 'yes'
    ),
    rstudio, open = FALSE)
  create_pkg_skeleton(path)
  s <- tfse::readlines(file.path(path, "R/score.R"))
  s <- gsub("meanrtemplate", basename(path), s)
  write_utf8(gsub("meanr", basename(path), s), file.path(path, "R/score.R"))
  s <- tfse::readlines(file.path(path, "src/native.c"))
  write_utf8(gsub("meanr", basename(path), s), file.path(path, "src/native.c"))
  write_pos_neg(d, path)
  make_hashtables(path)
  Sys.chmod(file.path(path, "configure"), "777")
  Sys.chmod(file.path(path, "configure.ac"), "777")
  Sys.chmod(file.path(path, "configure.win"), "777")
  Sys.chmod(file.path(path, "cleanup"), "777")
  devtools::load_all(path, quiet = TRUE)
  sh <- utils::capture.output(suppressMessages(devtools::document(path)))
  sh <- utils::capture.output(suppressMessages(devtools::install(path, quiet = TRUE, upgrade = "always")))
  if (open) {
    utils::browseURL(list.files(path, full.names = TRUE, pattern = "\\.Rproj$"))
  }
  invisible(path)
}


create_pkg_skeleton <- function(path) {
  ## first, cleanup any preexisting directories
  if (dir.exists(file.path(path, "inst"))) {
    unlink(file.path(path, "inst"), recursive = TRUE)
  }
  if (dir.exists(file.path(path, "src"))) {
    unlink(file.path(path, "src"), recursive = TRUE)
  }
  if (dir.exists(file.path(path, "R"))) {
    unlink(file.path(path, "R"), recursive = TRUE)
  }

  ## second, create paths for pkg skeleton
  dirs <- file.path(path,
    c("inst/sexputils", "R", "src/hashtable/maker"))

  ## third, create directories as necessary
  sh <- dapr::lap(dirs, dir.create, showWarnings = FALSE, recursive = TRUE)

  ## fourth, create full paths to template files
  files <- file.path(path, names(pkg_tmp))

  ## fifth, save template files
  for (i in seq_along(files)) {
    sh <- write_utf8(pkg_tmp[[i]], files[i])
  }
}


write_utf8 <- function(x, path, ...) {
  opts <- options(encoding = "native.enc")
  on.exit(options(opts), add = TRUE)
  writeLines(enc2utf8(x), path, ...)
  invisible(path)
}

write_pos_neg <- function(x, path) {
  x <- x$dict
  pos <- unique(x$word[x$weight > 0])
  neg <- unique(x$word[x$weight < 0])
  write_utf8(pos, file.path(path, "src/hashtable/maker/positive.txt"))
  tfse::print_complete("Save positive word list")
  write_utf8(neg, file.path(path, "src/hashtable/maker/negative.txt"))
  tfse::print_complete("Save negative word list")
  invisible()
}

make_hashtables <- function(path) {
  ## create words file
  system(
    paste0("cd ", file.path(path, "src/hashtable/maker"),
      " && sh ./makewords.sh")
  )

  ## create hash files
  system(
    paste0("cd ", file.path(path, "src/hashtable/maker"),
      " && sh ./make2tables.sh")
  )

  ## change size_t to pointer
  x <- tfse::readlines(file.path(path, "src/hashtable/maker/neghash.h"))
  x <- sub("int\\)\\(size_t", "intptr_t", x)
  write_utf8(x, file.path(path, "src/hashtable/maker/neghash.h"))
  x <- tfse::readlines(file.path(path, "src/hashtable/maker/poshash.h"))
  x <- sub("int\\)\\(size_t", "intptr_t", x)
  write_utf8(x, file.path(path, "src/hashtable/maker/poshash.h"))

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
  invisible()
}
