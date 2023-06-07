
# PatentSafeR

<!-- badges: start -->
<!-- badges: end -->

The goal of PatentSafeR is to make it quick and easy to submit your experimental
work to the [PatentSafe ELN from Amphora Research Systems](https://www.amphora-research.com/).

## Installation

Install PatentSafeR from CRAN as normal. 


## Requirements

You will need to have `pandoc` installed on your computer. This is used to convert your R Markdown file to a PDF.

You will also need a LaTeX distribution installed.

On a Mac with Homebrew installed you can do this with:

``` sh
brew install pandoc
brew install --cask mactex
```

Note you will need to restart your R environment after installing `mactex` to pick up the new binaries.

On Ubuntu:

``` sh
sudo apt-get update
sudo apt-get install texlive-latex-recommended texlive-latex-extra
```

## Example

To submit the current directory to PatentSafe, assuming you have a file `Report.Rmd` which is your write up.

``` r
PatentSafeR::submit_this_project(".")
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

### Devcontainer 

To get an R Session in the included Dev Container, "R: Create R Terminal".

To check the Package, use `devtools::check()`

To generate documentation use `devtools::document()`


### Quick Examples for use in Development 

To test you can use the folllowing. Note that `system.file("extdata", "test.pdf", package = "PatentSafeR")` is a way to get to the `inst/extdata` directory and wouldn't be needed normally)

``` r
devtools::load_all()
PatentSafeR::submit_pdf(system.file("extdata", "test.pdf", package = "PatentSafeR"))
PatentSafeR::submit_rmd(system.file("extdata", "Writeup.Rmd", package = "PatentSafeR"))
PatentSafeR::submit_rmd(system.file("extdata", "Writeup.Rmd", package = "PatentSafeR"), metadata = list(key1 = "value1", key2 = "value2", key3 = "value3"))
PatentSafeR::submit_this_project(directory = system.file("extdata", package = "PatentSafeR"), report_filename = system.file("extdata", "Writeup.Rmd", package = "PatentSafeR"), url = "test.morescience.com", author_id = "simonc")
```

When shipping, remember to increment the version number. 

### Installing the Development Version

You can install the development version of PatentSafeR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("amphora/PatentSafeR")
```

### Releasing

Do `usethis::use_release_issue(version = x.x.x.x)
