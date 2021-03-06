
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dict

<!-- badges: start -->

<!-- badges: end -->

The goal of dict is to make it easy to create, modify, and use
word-based dictionaries for analyzing natural language texts. In other
words, this package is designed to create sentiment-analysis like tools
for measuring the extent to which natural language reflects (positively
and/or negatively) any user-defined dimension or topic (e.g., politics,
sports, emotions, active, pass, medical, philosophical, etc.).

## Installation

You can install the released version of dict from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("dict")
```

You can install the developmernt version of dict from
[Github](https://github.com) with:

``` r
remotes::install_github("mkearney/dict")
```

## Example

Create vectors of positively and negatively identifying words for a
simple “valence” dimension.

``` r
## load package
library(dict)

## vector of positive words
pos <- c("like", "love", "amazing", "excellent", "great", "fantastic",
  "incredible", "awesome", "best", "favorite", "fan", "fun", "enjoyed",
  "good", "solid", "better", "soooo", "happy")

## vetor of negative words
neg <- c("hate", "loathe", "dislike", "awful", "horrible", "worst",
  "miserable", "ruin", "ruining", "destroy", "destroyed", "destroying",
  "pathetic", "hated", "unhappy", "terrible")
```

## Create dictionaries

Create a dictionary using only positively-coded words or both positively
and negatively coded words.

``` r
## create dictionary using only positive words
only_pos <- dict(pos)

## create dictionary using both positive and negative words
d <- dict(list(pos = pos, neg = neg))

## view up to n entries of dictionary
print(d, n = 15)
#> # A dict[ionary]
#> # A tibble: 34 x 2
#>    word       weight
#>    <chr>       <dbl>
#>  1 like            1
#>  2 love            1
#>  3 amazing         1
#>  4 excellent       1
#>  5 great           1
#>  6 fantastic       1
#>  7 incredible      1
#>  8 awesome         1
#>  9 best            1
#> 10 favorite        1
#> 11 fan             1
#> 12 fun             1
#> 13 enjoyed         1
#> 14 good            1
#> 15 solid           1
#> # … with 19 more rows
```

## Use word dictionary

Apply a dictionary to some example text:

``` r
## example text
txt <- c("love amazing excellent good",
  "hate loathe horrifies unhappy terrible",
  "awesome best hateful hated worst")

## get estimates for each element of txt using pos/neg dictionary
d$score(txt)
#>   positive negative score wc
#> 1        4        0     4  4
#> 2        0        4    -4  5
#> 3        2        2     0  5

## store only the overall score in a tibble
tibble::tibble(
  text  = txt,
  score = d$score_score(txt)
)
#> # A tibble: 3 x 2
#>   text                                   score
#>   <chr>                                  <dbl>
#> 1 love amazing excellent good                4
#> 2 hate loathe horrifies unhappy terrible    -4
#> 3 awesome best hateful hated worst           0
```

## Export dictionary via R package

Export word dictionaries as super fast packages using this wrapper
around `usethis::create_package()`

``` r
## create package path via temp directory
path_pkg <- file.path(tempdir(), "simpleexample")

## create R package featuring d
create_dict_pkg(d, path_pkg)
#> ✔ Creating '/tmp/RtmppISNUk/simpleexample/'
#> ✔ Setting active project to '/tmp/RtmppISNUk/simpleexample'
#> ✔ Creating 'R/'
#> ✔ Writing 'DESCRIPTION'
#> Package: simpleexample
#> Title: Word Dictionary Analysis Scorer
#> Version: 0.0.1
#> Authors@R (parsed):
#>     * Michael W. Kearney <kearneymw@missouri.edu> [aut, cre] (<https://orcid.org/0000-0002-0730-4694>)
#> Description: Data and functions for a natural language word dictionary
#> License: What license it uses
#> Depends:
#>     R (>= 3.0.0)
#> ByteCompile: yes
#> Encoding: UTF-8
#> LazyData: yes
#> LazyLoad: yes
#> NeedsCompilation: yes
#> ✔ Writing 'NAMESPACE'
#> ✔ Writing 'simpleexample.Rproj'
#> ✔ Adding '.Rproj.user' to '.gitignore'
#> ✔ Adding '^simpleexample\\.Rproj$', '^\\.Rproj\\.user$' to '.Rbuildignore'
#> ✔ Setting active project to '<no active project>'
#> [32m✔[39m Save positive word list
#> [32m✔[39m Save negative word list

## test new package's score function on txt vector
simpleexample::score(txt)
#>   positive negative score wc
#> 1        4        0     4  4
#> 2        0        4    -4  5
#> 3        2        2     0  5
```

Compare the speed of the default returned function (written in R) versus
the optimized version in the standalone package (written in C)

``` r
## analyzeSentiment() won't work unless you load the whole library
library(SentimentAnalysis)
#> 
#> Attaching package: 'SentimentAnalysis'
#> The following object is masked from 'package:base':
#> 
#>     write

## compare speed
bm <- bench::mark(
  SentimentAnalysis = analyzeSentiment(txt),
  syuzhet = syuzhet::get_sentiment(txt),
  dict_fun = d$score(txt),
  dict_pkg = simpleexample::score(txt),
  relative = TRUE,
  check = FALSE,
  iterations = 30
)
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.

## view results
bm
#> # A tibble: 4 x 6
#>   expression            min  median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>          <dbl>   <dbl>     <dbl>     <dbl>    <dbl>
#> 1 SentimentAnalysis 66826.  67647.         1        Inf      Inf
#> 2 syuzhet              49.9    55.8     1211.       Inf      NaN
#> 3 dict_fun             21.8    21.0     3135.       Inf      NaN
#> 4 dict_pkg              1       1      57194.       NaN      NaN

## view plot
ggplot2::autoplot(bm)
#> Loading required namespace: tidyr
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## TO DO

See [issues labelled
enhancement](https://github.com/mkearney/dict/labels/enhancement).
