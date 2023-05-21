# Utility functions for submitting to PatentSafe

#' Submit a PDF
#'
#' @param report_filename filename of your report file (should be a PDF)
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param text_content Textual content of the PDF, defaults to PatentSafe's 
#' automatic extraction
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic 
#'                calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#' @param attachment_filename The filename of an attachment defaults to 
#'        no attachment
#'
#' @return PatentSafe document ID or error code
#' @export
#'
#' @examples
#' submit_pdf(system.file("extdata", "test.pdf", package = "PatentSafeR"),
#'            url = 'https://demo.morescience.com',
#'            author_id = 'clarusc')
submit_pdf <- function(report_filename,
                      text_content = NULL,
                      summary = NULL,
                      metadata = NULL,
                      destination = 'sign',
                      attachment_filename = NULL,
                      url = Sys.getenv("PATENTSAFE_URL"),
                      author_id = Sys.getenv("PATENTSAFE_USERID"))
{
  cat("This is the filename", report_filename)

  # This is the URL of the API endpoint
  submit_url <- paste(url, "/submit/document.html")

  # Any metadata you might want to set
  # TODO generate this from the parameters
  metadata <-
    "<metadata> <tag name=\"TAG NAME\">VALUE</tag> </metadata>"

  # Summary of the document
  doc_summary <-
    "This is a summary of the document. Put up to 200 characters here"

  req <- httr2::request(submit_url)
  httr2::req_options(req, ssl_verifypeer = 0)
  httr2::req_body_multipart(
    req,
    pdfContent = curl::form_file(report_filename),
    author_id = author_id,
    summary = doc_summary,
    destination = destination,
    text_content = text_content,
    summary = summary,
    metadata = metadata
  )
  httr2::req_dry_run(req)
}

#' Submit this project to PatentSafe
#'
#' @param directory The directory to submit. Must contain a .Rmd file
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param report_filename Filename of the Report file, defaults to Report.Rmd
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic 
#'                calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' submit_this_project(system.file("extdata", package = 'PatentSafeR'),
#'                     url = 'https://demo.morescience.com', 
#'                     author_id = 'clarusc')
submit_this_project <- function(directory = '.',
                              report_filename = "Report.Rmd",
                              summary = NULL,
                              metadata = NULL,
                              destination = 'sign',
                              url = Sys.getenv("PATENTSAFE_URL"),
                              author_id = Sys.getenv("PATENTSAFE_USERID"))

{
  # Render the file
  rmarkdown::render(
    input = report_filename,
    output_format = "pdf_document",
    output_file = "report.pdf",
    output_dir = tempdir()
  )
  report_filename <- paste0(tempdir(), "/report.pdf")

  # TODO get the text content
  text_content <- "Complete me"

  # Create a Zip of the project
  zip_filename <- paste0(tempdir(), "/project.zip")
  zip::zip(zipfile = zip_filename, directory, flags = "-r")

  # Now we've prepared things, submit to PatentSafe
  response = submit_pdf(
    report_filename,
    text_content = text_content,
    summary = summary,
    metadata = metadata,
    destination = destination,
    attachment_filename = zip_filename,
    url = url,
    author_id = author_id
  )

  # Now open the project
  open_patentsafe_document(response)
}

#' Submit an .Rmd file to PatentSafe. This is the best option for
#' submission because we can extract text etc.
#'
#' @param report_filename Filename of the Report file, defaults to Report.Rmd
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param summary Summary of the experiment, defaults to PatentSafe's
#' automatic calculation
#' @param metadata Metadata for the PatentSafe document, as a
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' submit_rmd(system.file("extdata", 'Report.Rmd', 
#'            package = 'PatentSafeR'),
#'            'https://demo.morescience.com', 
#'            'clarusc')
submit_rmd <- function(report_filename,
                      summary = NULL,
                      metadata = NULL,
                      destination = 'sign',
                      url = Sys.getenv("PATENTSAFE_URL"),
                      author_id = Sys.getenv("PATENTSAFE_USERID"))
{
  # Render the file
  rmarkdown::render(
    input = report_filename,
    output_format = "pdf_document",
    output_file = "report.pdf",
    output_dir = tempdir()
  )

  # TODO make the path work on Windows
  report_filename <- paste0(tempdir(), "/report.pdf")

  text_content <- NULL

  # Now we've prepared things, submit to PatentSafe
  response <- submit_pdf(
    report_filename,
    text_content = text_content,
    summary = summary,
    metadata = metadata,
    destination = destination,
    url = url,
    author_id = author_id
  )

  # Now open the project
  open_patentsafe_document(response)

}


#' Title Open a PatentSafe document in the browser, based on the
#'
#' @param submission_return The return from a PatentSafe submission HTTP call
#' @param base_url The PatentSafe server's URL
#'
#' @return
#' This function isn't exported so there's no @export
#'
#' @importFrom utils browseURL
open_patentsafe_document <- function(submission_return, base_url)
{
  # This will either be OK and a document ID, e.g. "OK:AMPH4500001388"
  # or an error code
  # So extract the components
  return_code <- substring(submission_return, 0, 2)
  doc_id <- substring(submission_return, 4)
  doc_url <-
    paste(base_url,
          "/document/",
          doc_id,
          sep = "",
          collapse = "")

  # So if it starts with OK, redirect the user to sign it
  if (return_code == "OK") {
    browseURL(doc_url)
  } else {
    "Something bad  happened"
  }
}
