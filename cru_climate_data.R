#' Download Historical Climate Data from CRU
#'
#' This function automates downloading and extracting climate data from the
#' Climatic Research Unit (CRU) of the University of East Anglia.
#'
#' @param variable Climate variable to download (e.g., "pre" for precipitation, "tmp" for temperature)
#' @param start_year Starting year for the data (default: 1901)
#' @param end_year Ending year for the data (default: 2023)
#' @param version CRU TS version (default: "4.08")
#'
#' @return Path to the downloaded and extracted NetCDF file
#' @export
#'
#' @examples
#' \dontrun{
#' precip_file <- download_cru_climate("pre")
#' temp_file <- download_cru_climate("tmp")
#' recent_precip <- download_cru_climate("pre", start_year = 2001, end_year = 2010)
#' }
download_cru_climate <- function(variable, start_year = 1901, end_year = 2023, version = "4.08") {
    # First, we tell our function where to find the data
    base_url <- paste0("https://crudata.uea.ac.uk/cru/data/hrg/",
                       "cru_ts_", version,
                       "/cruts.2406270035.v", version)

    # Now we specify which climate variable we want
    var_url <- file.path(base_url, tolower(variable))

    # Create the exact filename we need
    # This follows CRU's specific naming convention
    filename <- sprintf("cru_ts%s.%d.%d.%s.dat.nc.gz",
                        version, start_year, end_year,
                        tolower(variable))

    # Combine everything to get download link
    download_url <- file.path(var_url, filename)

    # Set up where we'll save the file on computer
    dest_file <- file.path(getwd(), filename)
    dest_file_uncompressed <- gsub("\\.gz$", "", dest_file)

    # Keep us informed about what's happening
    message("Starting to download ", variable, " data")
    message("This might take a while - perfect time to grab a coffee!")

    # Download file (the heavy lifting happens here)
    download.file(download_url, dest_file, mode = "wb", quiet = FALSE)
    message("Download finished - now let's unpack it")

    # Unzip the file (it comes compressed to save space)
    R.utils::gunzip(dest_file, dest_file_uncompressed, remove = FALSE)
    message("All done! Your data is ready to use")

    return(dest_file_uncompressed)
}

# Example usage

    # Increase the download timeout to 10 minutes (600 seconds)
    # Climate data files can be large, so we need to be patient
    options(timeout = 600)

    # Example usage: download precipitation and temperature data
    precip_file <- download_cru_climate("pre")
    temp_file <- download_cru_climate("tmp")

    # For a specific time period:
    recent_precip <- download_cru_climate("pre", start_year = 2001, end_year = 2010)
