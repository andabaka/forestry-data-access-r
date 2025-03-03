#' Download FAO Forestry Production and Trade Data
#'
#' This function downloads the complete FAO Forestry Production and Trade dataset,
#' which includes comprehensive statistics on global forest products since 1961.
#'
#' @return A data frame containing the FAO forestry production and trade data
#' @export
#'
#' @examples
#' \dontrun{
#' forestry_data <- download_forestry_data()
#' croatia_data <- subset(forestry_data, Area == "Croatia")
#' }
download_forestry_data <- function() {
    # Direct download URL for forestry data (this is a direct CSV link to FAOSTAT forestry data)
    download_url <- "https://fenixservices.fao.org/faostat/static/bulkdownloads/Forestry_E_All_Data.zip"

    # Create temporary files
    temp_zip <- tempfile(fileext = ".zip")
    temp_dir <- tempdir()

    # Download the file
    message("Downloading FAO Forestry data...")
    message("This is a large file and may take several minutes...")
    download.file(download_url, temp_zip, mode = "wb")

    # Extract the zip file
    unzip(temp_zip, exdir = temp_dir)

    # Find the CSV file
    csv_files <- list.files(temp_dir, pattern = "\\.csv$", full.names = TRUE)
    if (length(csv_files) == 0) {
        message("No CSV files found in the downloaded package.")
        return(NULL)
    }

    # Read the first CSV file
    forestry_data <- read.csv(csv_files[1], stringsAsFactors = FALSE)
    message("Successfully loaded ", nrow(forestry_data), " rows of forestry data.")

    # Clean up temporary files
    unlink(temp_zip)

    return(forestry_data)
}

# Helper function to filter data by country and analyze trends
analyze_country_forestry <- function(forestry_data, country, product_type = NULL) {
    if (!requireNamespace("dplyr", quietly = TRUE)) {
        stop("Please install dplyr: install.packages('dplyr')")
    }

    library(dplyr)

    # Filter for the specified country
    country_data <- forestry_data %>%
        filter(Area == country)

    if (nrow(country_data) == 0) {
        message("No data found for country: ", country)
        return(NULL)
    }

    # Apply product type filter if specified
    if (!is.null(product_type)) {
        country_data <- country_data %>%
            filter(grepl(product_type, Item, ignore.case = TRUE))

        if (nrow(country_data) == 0) {
            message("No data found for product type: ", product_type)
            return(NULL)
        }
    }

    message("Found ", nrow(country_data), " records for ", country)
    if (!is.null(product_type)) {
        message("Filtered to product type: ", product_type)
    }

    return(country_data)
}

# Example usage

    # Download all FAO forestry data
    forestry_data <- download_forestry_data()

    # Filter for Croatia
    croatia_data <- analyze_country_forestry(forestry_data, "Croatia")

    # Get only roundwood production data for Croatia
    croatia_roundwood <- analyze_country_forestry(forestry_data, "Croatia", "roundwood")

