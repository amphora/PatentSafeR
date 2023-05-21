
# PatentSafeR

<!-- badges: start -->
<!-- badges: end -->

The goal of PatentSafeR is to make it quick and easy to submit your experimental
work to the [PatentSafe ELN from Amphora Research Systems](https://amphora-research.com).

## Installation

You can install the development version of PatentSafeR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("amphora/PatentSafeR")
```

## Requirements

You will need to have `pandoc` installed on your computer. This is used to convert your R Markdown file to a PDF.

You will also need a LaTeX distribution installed.

On a Mac with Homebrew installed you can do this with:

``` sh
brew install pandoc
brew install --cask mactex
```

Note you will need to restart your R environment after installing `mactex` to pick up the new binaries.

## Example

To submit the current directory to PatentSafe, assuming you have a file `Report.Rmd` which is your write up.

``` r
library(PatentSafeR)
## basic example code
```

## Credentials

Store in your `.Renviron` file

- `PATENTSAFE_URL` - Your PatentSafe server URL
- `PATENTSAFE_USERID` - Your PatentSafe user ID

To set the environment variables, use `usethis::edit_r_environ()`

e.g.

``` sh
PATENTSAFE_URL=test.morescience.com
PATENTSAFE_USERID=clarusc
```

## Development

To get an R Session in the included Dev Container, "R: Create R Terminal".

To check the Package, use `devtools::check()`

To generate documentation use `devtools::document()`

To test

``` r
devtools::load_all()
PatentSafeR::submit_pdf(system.file("extdata", "test.pdf", package = "PatentSafeR"))
PatentSafeR::submit_rmd(system.file("extdata", "Report.Rmd", package = "PatentSafeR"))
```
