#' Download Tree Species Occurrence Data from GBIF
#'
#' This function retrieves species occurrence data from the Global Biodiversity
#' Information Facility (GBIF) for forestry research.
#'
#' @param scientific_name Scientific name of the species (e.g., "Fagus sylvatica")
#' @param country Optional country code to filter results (e.g., "HR" for Croatia)
#' @param limit Maximum number of records to return (default: 10000)
#' @param forest_only If TRUE, tries to filter for forest habitats only (default: TRUE)
#'
#' @return A data frame containing occurrence records
#' @export
#'
#' @examples
#' \dontrun{
#' beech_data <- download_tree_occurrences("Fagus sylvatica", country = "HR")
#' }
download_tree_occurrences <- function(scientific_name, country = NULL,
                                      limit = 10000, forest_only = TRUE) {
    # Check if rgbif package is installed and load it
    if (!requireNamespace("rgbif", quietly = TRUE)) {
        stop("Please install the rgbif package: install.packages('rgbif')")
    }
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
        stop("Please install the ggplot2 package: install.packages('ggplot2')")
    }
    if (!requireNamespace("maps", quietly = TRUE)) {
        stop("Please install the maps package: install.packages('maps')")
    }

    library(rgbif)

    # Validate input
    if (!is.character(scientific_name) || length(scientific_name) == 0) {
        stop("Please provide a valid scientific name")
    }

    # Build query parameters
    query_params <- list(
        scientificName = scientific_name,
        limit = limit,
        hasCoordinate = TRUE,
        hasGeospatialIssue = FALSE
    )

    # Add country filter if specified
    if (!is.null(country)) {
        query_params$country <- country
    }

    # Perform the GBIF search
    message("Searching GBIF for: ", scientific_name)
    gbif_data <- occ_search(
        scientificName = scientific_name,
        limit = limit,
        hasCoordinate = TRUE,
        hasGeospatialIssue = FALSE,
        country = country
    )

    # Extract the data frame from the results
    occurrences <- gbif_data$data

    # Check if we got any results
    if (nrow(occurrences) == 0) {
        message("No occurrences found for: ", scientific_name)
        return(NULL)
    }

    message("Found ", nrow(occurrences), " occurrences for: ", scientific_name)

    # Filter for forest habitats if requested
    if (forest_only && "habitat" %in% colnames(occurrences)) {
        forest_keywords <- c("forest", "woodland", "woods", "silv", "timberland")
        forest_pattern <- paste(forest_keywords, collapse = "|")

        # Keep records with forest-related habitat or NULL habitat
        forest_occurrences <- occurrences[grepl(forest_pattern, occurrences$habitat,
                                                ignore.case = TRUE) |
                                              is.na(occurrences$habitat), ]

        message("Filtered to ", nrow(forest_occurrences), " forest-related occurrences")
        return(forest_occurrences)
    }

    return(occurrences)
}

# Example visualization function
plot_occurrences <- function(occurrences, region = NULL) {
    if (!requireNamespace("ggplot2", quietly = TRUE) ||
        !requireNamespace("maps", quietly = TRUE)) {
        stop("Please install required packages: install.packages(c('ggplot2', 'maps'))")
    }

    library(ggplot2)
    library(maps)

    # Get map data
    if (is.null(region)) {
        # Try to determine region from the data
        if ("countryCode" %in% names(occurrences) && length(unique(occurrences$countryCode)) == 1) {
            region <- occurrences$countryCode[1]
        } else {
            # Default to world map
            region <- "world"
        }
    }

    # Get map data
    map_data <- maps::map_data(ifelse(region == "world", "world", "world"),
                               region = ifelse(region == "world", NULL, region))

    # Plot occurrences on map
    p <- ggplot() +
        geom_polygon(data = map_data, aes(x = long, y = lat, group = group),
                     fill = "white", color = "gray50") +
        geom_point(data = occurrences, aes(x = decimalLongitude, y = decimalLatitude),
                   color = "darkgreen", alpha = 0.6) +
        coord_fixed(1.3) +
        theme_minimal() +
        labs(title = paste0("Distribution of ", unique(occurrences$scientificName)))

    return(p)
}

# Example usage

    # Download occurrence data for European beech in Croatia
    beech_data <- download_tree_occurrences("Fagus sylvatica", country = "HR")

    # Plot the occurrences
    plot_occurrences(beech_data, region = "Croatia")

