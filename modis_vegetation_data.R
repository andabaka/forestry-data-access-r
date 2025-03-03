#' Download MODIS Vegetation Index Data
#'
#' This function downloads vegetation index data from NASA's MODIS satellite for
#' specified coordinates, ideal for monitoring forest health and productivity.
#'
#' @param lat Latitude of the site
#' @param lon Longitude of the site
#' @param start_date Start date in "YYYY-MM-DD" format (default: 2000-01-01)
#' @param end_date End date in "YYYY-MM-DD" format (default: current date)
#' @param product MODIS product code (default: "MOD13Q1" - 16-day vegetation indices)
#' @param band Band/variable to download (default: "250m_16_days_EVI")
#'
#' @return A data frame with vegetation index time series
#' @export
#'
#' @examples
#' \dontrun{
#' cro_evi <- download_modis_forest_data(lat = 45.56628, lon = 14.52124,
#'                                       start_date = "2018-01-01", end_date = "2023-01-01")
#' }
download_modis_forest_data <- function(lat, lon, start_date = "2000-01-01",
                                       end_date = Sys.Date(),
                                       product = "MOD13Q1",
                                       band = "250m_16_days_EVI") {
    # Check if MODISTools package is installed and load it
    if (!requireNamespace("MODISTools", quietly = TRUE)) {
        stop("Please install the MODISTools package: install.packages('MODISTools')")
    }

    library(MODISTools)

    # Format dates
    start_date <- as.character(start_date)
    end_date <- as.character(end_date)

    # Create site list
    sites <- data.frame(
        site_name = paste0("site_", round(lat, 2), "_", round(lon, 2)),
        lat = lat,
        lon = lon,
        stringsAsFactors = FALSE
    )

    # Download the MODIS data
    message("Downloading MODIS data for coordinates: ", lat, ", ", lon)
    message("This may take a few minutes depending on the date range...")

    modis_data <- MODISTools::mt_batch_subset(
        df = sites,
        product = product,
        band = band,
        start = start_date,
        end = end_date,
        km_lr = 1,
        km_ab = 1,
        internal = TRUE
    )

    # Format the output
    if (nrow(modis_data) == 0) {
        message("No data found for the specified parameters.")
        return(NULL)
    }

    # Calculate the date from MODIS date format
    modis_data$date <- as.Date(modis_data$calendar_date)

    message("Successfully downloaded ", nrow(modis_data), " MODIS observations.")
    return(modis_data)
}

# Helper function to plot time series
plot_vegetation_index <- function(modis_data) {
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
        stop("Please install ggplot2: install.packages('ggplot2')")
    }

    library(ggplot2)

    if (is.null(modis_data) || nrow(modis_data) == 0) {
        stop("No data available to plot")
    }

    # Scale the values appropriately (MODIS EVI is often stored as integers * 10000)
    if (max(modis_data$value, na.rm = TRUE) > 1000) {
        modis_data$scaled_value <- modis_data$value / 10000
    } else {
        modis_data$scaled_value <- modis_data$value
    }

    # Create the plot
    p <- ggplot(modis_data, aes(x = date, y = scaled_value)) +
        geom_line() +
        geom_point() +
        theme_minimal() +
        labs(
            title = paste("Vegetation Index Time Series for", unique(modis_data$site_name)),
            x = "Date",
            y = ifelse(grepl("EVI", unique(modis_data$band)), "EVI", "NDVI"),
            caption = "Data source: NASA MODIS"
        ) +
        scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    return(p)
}

# Example usage

    # Download EVI data for a forest location in Croatia
    cro_evi <- download_modis_forest_data(
        lat = 45.56628,
        lon = 14.52124,
        start_date = "2018-01-01",
        end_date = "2023-01-01"
    )

    # Plot the data
    plot_vegetation_index(cro_evi)
