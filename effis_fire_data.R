#' Process European Forest Fire Data from EFFIS
#'
#' This function processes a downloaded shapefile from the European Forest Fire
#' Information System (EFFIS) and returns a clean, filtered dataset.
#'
#' @param shapefile_path Path to the downloaded EFFIS shapefile
#' @param country_code Optional country code to filter results (e.g., "HR" for Croatia)
#' @param start_date Optional start date for filtering in "YYYY-MM-DD" format
#' @param end_date Optional end date for filtering in "YYYY-MM-DD" format
#' @param min_area_ha Optional minimum fire size in hectares
#'
#' @return An sf object containing the processed fire data
#' @export
#'
#' @examples
#' \dontrun{
#' croatia_fires <- process_effis_fires(
#'   shape_file_path = "path/to/effis_layer/modis.ba.poly.shp",
#'   country_code = "HR",
#'   start_date = "2000-01-01"
#' )
#' }
process_effis_fires <- function(shapefile_path, country_code = NULL,
                                start_date = NULL, end_date = NULL,
                                min_area_ha = NULL) {
    # Check if required packages are installed
    required_packages <- c("sf", "dplyr", "lubridate")
    for (pkg in required_packages) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
            stop("Please install the ", pkg, " package: install.packages('", pkg, "')")
        }
    }

    library(sf)
    library(dplyr)
    library(lubridate)

    # Check if the file exists
    if (!file.exists(shapefile_path)) {
        stop("Shapefile not found at: ", shapefile_path)
    }

    # Read the shapefile
    message("Reading EFFIS burnt areas shapefile...")
    fires <- st_read(shapefile_path, quiet = TRUE)

    # Initial number of records
    initial_count <- nrow(fires)
    message("Loaded ", initial_count, " fire records.")

    # Clean and prepare the data
    fires <- fires %>%
        mutate(
            # Convert date strings to proper date-time objects
            FIREDATE = ymd_hms(FIREDATE),
            LASTUPDATE = ymd_hms(LASTUPDATE),
            # Convert area to numeric
            AREA_HA = as.numeric(AREA_HA),
            # Convert land cover percentages to numeric
            BROADLEA = as.numeric(BROADLEA), # Broadleaf forests
            CONIFER = as.numeric(CONIFER),   # Coniferous forests
            MIXED = as.numeric(MIXED),       # Mixed forests
            SCLEROPH = as.numeric(SCLEROPH), # Sclerophyllous vegetation
            TRANSIT = as.numeric(TRANSIT),   # Transitional woodland
            AGRIAREAS = as.numeric(AGRIAREAS) # Agricultural areas
        )

    # Filter by country if specified
    if (!is.null(country_code)) {
        fires <- fires %>% filter(COUNTRY == country_code)
        message("Filtered for country ", country_code, ": ", nrow(fires), " records.")
    }

    # Filter by start date if specified
    if (!is.null(start_date)) {
        start_date <- ymd(start_date)
        fires <- fires %>% filter(FIREDATE >= start_date)
        message("Filtered for fires after ", start_date, ": ", nrow(fires), " records.")
    }

    # Filter by end date if specified
    if (!is.null(end_date)) {
        end_date <- ymd(end_date)
        fires <- fires %>% filter(FIREDATE <= end_date)
        message("Filtered for fires before ", end_date, ": ", nrow(fires), " records.")
    }

    # Filter by minimum area if specified
    if (!is.null(min_area_ha)) {
        fires <- fires %>% filter(AREA_HA >= min_area_ha)
        message("Filtered for minimum area of ", min_area_ha, " hectares: ", nrow(fires), " records.")
    }

    return(fires)
}

# Example usage

    # This requires manual download of EFFIS data first
    # Visit: https://forest-fire.emergency.copernicus.eu/applications/data-and-services
    # Look for "Download real-time updated Burnt Areas database Shapefile"

    # Process Croatia fires since 2000
    croatia_fires <- process_effis_fires(
        shape_file_path = "path/to/effis_layer/modis.ba.poly.shp",
        country_code = "HR",
        start_date = "2000-01-01"
    )

