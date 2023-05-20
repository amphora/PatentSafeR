# Utility functions for submitting to PatentSafe


#' Submit a PDF
#'
#' @param reportFilename filename of your report file (should be a PDF)
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param authorId your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param textContent Textual content of the PDF, defaults to PatentSafe's automatic extraction
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#' @param attachmentFilename The filename of an attachment defaults to no attachment
#'
#' @return PatentSafe document ID or error code
#' @export
#'
#' @examples
#' submitPDF('report.pdf', 'https://demo.morescience.com', 'clarusc')
submitPDF <- function(reportFilename,
                      textContent = NULL,
                      summary = NULL,
                      metadata = NULL,
                      destination = 'sign',
                      attachmentFilename = NULL,
                      url = Sys.getenv("PATENTSAFE_URL"),
                      authorId = Sys.getenv("PATENTSAFE_USERID"))
{
  # This is the URL of the API endpoint
  submitUrl <- paste(url, "/submit/document.html")

  # Any metadata you might want to set
  # TODO generate this from the parameters
  metadata <-
    "<metadata> <tag name=\"TAG NAME\">VALUE</tag> </metadata>"

  # Summary of the document
  docSummary <-
    "This is a summary of the document. Put up to 200 characters here"

  req <- httr2::request(submitUrl)
  httr2::req_options(req, ssl_verifypeer = 0)
  httr2::req_body_multipart(
    req,
    pdfContent = curl::form_file(reportFilename),
    authorId = authorId,
    summary = docSummary,
    destination = destination,
    textContent = textContent,
    summary = summary,
    metadata = metadata
  )
  httr2::req_dry_run(req)
}

#' Submit this project to PatentSafe
#'
#' @param directory The directory to submit. Must contain a .Rmd file
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param authorId your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param reportFilename Filename of the Report file, defaults to Report.Rmd
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' submitPDF('report.pdf', 'https://demo.morescience.com', 'clarusc')
submitThisProject <- function(directory = '.',
                              reportFilename = "Report.Rmd",
                              summary = NULL,
                              metadata = NULL,
                              destination = 'sign',
                              url = Sys.getenv("PATENTSAFE_URL"),
                              authorId = Sys.getenv("PATENTSAFE_USERID"))

{
  # Render the file
  rmarkdown::render(
    input = reportFilename,
    output_format = "pdf_document",
    output_file = "report.pdf",
    output_dir = tempdir()
  )
  report_filename <- paste0(tempdir(), "/report.pdf")

  # TODO get the text content
  textContent <- "Complete me"

  # Create a Zip of the project
  zipFilename <- paste0(tempdir(), "/project.zip")
  zip(zipfile = zipFilename, projectDirectory, flags = "-r")

  # Now we've prepared things, submit to PatentSafe
  response = submitPDF(
    report_filename,
    textContent = textContent,
    summary = summary,
    metadata = metadata,
    destination = destination,
    attachmentFilename = zipFilename,
    url = url,
    authorId = authorId
  )

  # Now open the project
  openPatentSafeDocument(response)
}

#' Submit an .Rmd file to PatentSafe. This is the best option for submission because we can extract text etc.
#'
#' @param reportFilename Filename of the Report file, defaults to Report.Rmd
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param authorId your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' submitPDF('report.pdf', 'https://demo.morescience.com', 'clarusc')
submitRmd <- function(reportFilename,
                      summary = NULL,
                      metadata = NULL,
                      destination = 'sign',
                      url = Sys.getenv("PATENTSAFE_URL"),
                      authorId = Sys.getenv("PATENTSAFE_USERID"))
{
  # Render the file
  rmarkdown::render(
    input = reportFilename,
    output_format = "pdf_document",
    output_file = "report.pdf",
    output_dir = tempdir()
  )
  report_filename <- paste0(tempdir(), "/report.pdf")

  # Now we've prepared things, submit to PatentSafe
  response = submitPDF(
    report_filename,
    textContent = textContent,
    summary = summary,
    metadata = metadata,
    destination = destination,
    url = url,
    authorId = authorId
  )

  # Now open the project
  openPatentSafeDocument(response)

}


#' Title Open a PatentSafe document in the browser, based on the
#'
#' @param submissionReturn The return from a PatentSafe submission HTTP call
#' @param baseURL The PatentSafe server's URL
#'
#' @return
#' This function isn't exported so there's no @export
#'
#' @examples
#' openPatentSafeDocument('report.pdf', 'https://demo.morescience.com', 'clarusc')
openPatentSafeDocument <- function(submissionReturn, baseURL)
{
  # This will either be OK and a document ID, e.g. "OK:AMPH4500001388" or an error code
  # So extract the components
  returnCode = substring(submissionReturn, 0, 2)
  docID = substring(submissionReturn, 4)
  docUrl <-
    paste(baseURL,
          "/document/",
          docID,
          sep = "",
          collapse = "")

  # So if it starts with OK, redirect the user to sign it
  if (returnCode == "OK") {
    browseURL(docUrl)
  } else {
    "Something bad  happened"
  }
}
