# Utility functions for submitting to PatentSafe

#' Submit this project to PatentSafe as both a PDF and a .zip attachment
#'
#' @param directory The directory to submit. Must contain a .Rmd file
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param report_filename Filename of the Report file, defaults to Report.Rmd
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic
#'                calculation
#' @param metadata Metadata for the PatentSafe document, as a list() of key
#'                 value pairs
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' \dontrun{
#' submit_this_project('.'
#' }
submit_this_project <- function(directory = ".",
                              report_filename = "Writeup.Rmd",
                              summary = NULL,
                              metadata = NULL,
                              destination = "sign",
                              url = Sys.getenv("PATENTSAFE_URL"),
                              author_id = Sys.getenv("PATENTSAFE_USERID")) {

  # Create a Zip of the project
  zip_filename <- file.path(tempdir(), "/project.zip")

  # This makes all the paths relative
  # Get all files within the directory
  file_list <- list.files(directory, full.names = TRUE)

  # Convert absolute paths to relative paths
  relative_file_list <- basename(normalizePath(file_list, mustWork = FALSE))

  # Store the current working directory
  previous_wd <- getwd()

  # Change the working directory to the target directory
  setwd(directory)

  # Zip the directory with relative paths
  zip::zip(zipfile = zip_filename, files = relative_file_list)

  # Restore the original working directory
  setwd(previous_wd)

  # Now call the .Rmd submitter
  response <- submit_rmd(
    report_filename,
    summary = summary,
    metadata = metadata,
    destination = destination,
    attachment_filename = zip_filename,
    url = url,
    author_id = author_id
  )

  # Clean up the Zipfile
  unlink(zip_filename)

  response
}



#' Submit an .Rmd file to PatentSafe. This is the best option for
#' submission because we can extract text etc.
#'
#' @param report_filename Filename of the Report file, defaults to Report.Rmd
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param summary Summary of the experiment, defaults to PatentSafe's
#'                automatic calculation
#' @param metadata Metadata for the PatentSafe document, as a list() of key
#'                 value pairs
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#' @param attachment_filename The filename of an attachment defaults to
#'        no attachment
#'
#' @return Error code or opens PatentSafe in a browser
#' @export
#'
#' @examples
#' \dontrun{
#' submit_rmd('Report.Rmd',
#'            'https://demo.morescience.com',
#'            'clarusc')
#' }
submit_rmd <- function(report_filename = "Writeup.Rmd",
                      summary = NULL,
                      metadata = NULL,
                      destination = "sign",
                      attachment_filename = NULL,
                      url = Sys.getenv("PATENTSAFE_URL"),
                      author_id = Sys.getenv("PATENTSAFE_USERID")) {

  # Render the file as a .html and .pdf
  rmarkdown::render(
    input = report_filename,
    output_format = c("html_document", "pdf_document"),
    output_file = "report",
    output_dir = tempdir()
  )

  # The pathname of the PDF which we will submit to PatentSafe
  report_filename <- file.path(tempdir(), "/report.pdf")

  # Get the text content from the .html file
  # Read the HTML file
  html_content <- rvest::read_html(file.path(tempdir(), "/report.html"))

  # Extract the text from the HTML
  plain_text <- rvest::html_text(html_content)

  # Remove residual whitespace and line breaks and that's what we can
  # use for PatentSafe
  text_content <- gsub("\\s+", " ", plain_text)

  # Now we've prepared things, submit to PatentSafe
  response <- submit_pdf(
    report_filename,
    text_content = text_content,
    summary = summary,
    metadata = metadata,
    destination = destination,
    attachment_filename = attachment_filename,
    url = url,
    author_id = author_id
  )

  response
}


#' Submit a PDF
#'
#' @param report_filename filename of your report file (should be a PDF)
#' @param url the URL of your PatentSafe Server defaults to PATENTSAFE_USERID
#' @param author_id your PatentSafe user ID defaults to PATENTSAFE_URL
#' @param text_content Textual content of the PDF, defaults to PatentSafe's
#'                     automatic extraction
#' @param summary Summary of the experiment, defaults to PatentSafe's automatic
#'                calculation
#' @param metadata Metadata for the PatentSafe document, as a list() of key
#'                 value pairs
#' @param destination PatentSafe queue to submit to, defaults to "sign"
#' @param attachment_filename The filename of an attachment defaults to
#'                 no attachment
#'
#' @return PatentSafe document ID or error code
#' @export
#'
#' @examples
#' \dontrun{
#' submit_pdf(test.pdf,
#'            url = "https://demo.morescience.com",
#'            author_id = "clarusc")
#' }
submit_pdf <- function(report_filename,
                      text_content = NULL,
                      summary = NULL,
                      metadata = NULL,
                      destination = "sign",
                      attachment_filename = NULL,
                      url = Sys.getenv("PATENTSAFE_URL"),
                      author_id = Sys.getenv("PATENTSAFE_USERID")) {

  # Clean up the URL
  clean_url <- create_valid_url(url)

  # This is the URL of the API endpoint
  submit_url <- paste(clean_url, "/submit/document.html", 
                      sep = "", collapse = "")

  # Any metadata you might want to set
  metadata <- create_metadata_xml(metadata)

  # If and only if there is an attachment
  if (is.null(attachment_filename)) {
    attachment <- NULL
  } else {
    attachment <- curl::form_file(attachment_filename)
  }

  req <- httr2::request(submit_url)
  req <- httr2::req_options(req, ssl_verifypeer = 0)

  req <- httr2::req_body_multipart(
    req,
    pdfContent = curl::form_file(report_filename),
    attachment = attachment,
    authorId = author_id,
    summary = summary,
    destination = destination,
    text_content = text_content,
    summary = summary,
    metadata = metadata,
    source = "PatentSafeR"
  )

  # Perform the HTTP call
  resp <- httr2::req_perform(req)
  # Return the response as a string
  response <- httr2::resp_body_string(resp)


  status_code <- httr2::resp_status(resp)
  if (status_code == 200) {
    # It worked so send the user to PatentSafe
    open_patentsafe_document(response, clean_url)
  } else {
    # It didn't work so stop
    warning("Status code wasn't 200")
    stop("Call to PatentSafe failed")
  }

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
open_patentsafe_document <- function(submission_return, base_url) {
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
  # TODO possibly only if this was into the sign queue
  if (return_code == "OK") {
    browseURL(doc_url)
  } else {
    stop("PatentSafe Rejected the submission")
  }
}


# Create a Metadata XML packet
# Take an R list of key value pairs of metadata items
# Returns the metadata XML for PatentSafe submission
create_metadata_xml <- function(named_list) {
  # Bail out if there's nothing in the list
  if (is.null(named_list) || length(named_list) == 0) {
    return(NULL)
  }

  # Create an empty XML node for 'metadata'
  metadata <- XML::newXMLNode("metadata")

  # Iterate over the keys in the named list
  for (key in names(named_list)) {
    # Create a new 'tag' node and set the 'name' attribute
    tag_node <- XML::newXMLNode("tag", parent = metadata)
    XML::xmlAttrs(tag_node) <- c(name = key)

    # Get the value and escape it
    value <- as.character(named_list[[key]])

    # Set the value as the content of the 'tag' node
    XML::xmlValue(tag_node) <- value
  }

  # Convert the 'metadata' node to an XML string
  xml_string <- XML::saveXML(metadata)
  return(xml_string)
}


# Clean up the URL, which might come in as:
# test.morescience.com, http://test.morescience.com,
#   https://test.morescience.com
create_valid_url <- function(url) {
  if (!startsWith(url, "https://")) {
    if (startsWith(url, "http://")) {
      url <- gsub("http://", "https://", url)
    } else {
      url <- paste0("https://", url)
    }
  }
  return(url)
}