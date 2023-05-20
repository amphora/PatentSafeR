


#' Title
#'
#' @param url the URL of your PatentSafe Server
#' @param authorId your PatentSafe user ID
#' @param reportFilename filename of your report file (should be a PDF)
#'
#' @return PatentSafe document ID or error code
#' @export
#'
#' @examples
#' submit('https://demo.morescience.com', 'clarusc', 'report.pdf')
submit <- function(url, authorId, reportFilename) {

  # This is the URL of the API endpoint
  submitUrl <- paste(url, "/submit/document.html")

  # text content
  textContent <- ""

  # Any metadata you might want to set
  metadata <- "<metadata> <tag name=\"TAG NAME\">VALUE</tag> </metadata>"

  # Summary of the document
  docSummary <- "This is a summary of the document. Put up to 200 characters here"

  req <- httr2::request(submitUrl)
  httr2::req_options(req, ssl_verifypeer = 0)
  httr2::req_body_multipart(req,
    pdfContent = curl::form_file(reportFilename),
    authorId= authorId,
    summary = docSummary,
    destination = "sign",
    metadata = metadata
  )
  httr2::req_dry_run(req)


}
