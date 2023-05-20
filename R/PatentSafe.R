library(tidyverse)
library(units)
library(readxl)
library(writexl)
library(janitor)
library(knitr)
library(icons)
library(rmarkdown)

# We need RCurl
install.packages("RCurl", dependencies = TRUE)
library("RCurl")

# Curl options, ignore SSL just in case this version of Curl is out of date
curlOpts <- list(
  ssl.verifypeer = FALSE
)

#------------------------------------------------------------------------------
# Change this to be your server and PatentSafe user ID
#------------------------------------------------------------------------------
url <- "https://test.morescience.com/submit/document.html"
authorId <- "simonc"

#------------------------------------------------------------------------------
# Set things up for the submission
#------------------------------------------------------------------------------

# The main PDF itself
pdfFile <- fileUpload("C:\\Users\\SimonColes\\Downloads\\AD71688450.pdf", "application/pdf")

# The Zip file of this experiment content, which will be attached
#zipFile <- fileUpload("data.zip", "application/zip")
zipFile <- NULL

# Any metadata you might want to set
metadata <- "<metadata> <tag name=\"TAG NAME\">VALUE</tag> </metadata>"

# Summary of the document
docSummary <- "This is a summary of the document. Put up to 200 characters here"

# text content
textContent <- ""

# Do the post
docId <- postForm(url,
                  .opts = curlOpts,
                  pdfContent = pdfFile,
                  attachment = zipFile,
                  authorId= authorId,
                  summary = docSummary,
                  destination = "sign",
                  metadata = metadata,
                  textContent = textContent,
                  style = "httppost")
docId

# Attachments should work
# Text submission will come
# Metadata will be better (possible JSON)
