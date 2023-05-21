
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

## Example

To submit the current directory to PatentSafe, assuming you have a file Report.Rmd

``` r
library(PatentSafeR)
## basic example code
```

## Credentials 

Store in your `.Renviron` file 
- `PATENTSAFE_URL` - Your PatentSafe server URL
- `PATENTSAFE_USERID` - Your PatentSafe user ID


## Development

To get an R Session in the included Dev Container, "R: Create R Terminal".

To check the Package, use `devtools::check()`

To generate documentation use `devtools::document()`

