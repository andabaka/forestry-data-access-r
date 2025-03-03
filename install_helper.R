#' Helper function to install required packages
#'
#' This function checks if required packages are installed and installs them if needed.
#'
#' @param packages Character vector of package names to install
#' @param repos Repository to use for package installation
#'
#' @return Logical vector indicating success of package loading
#' @export
install_required_packages <- function(packages, repos = "https://cran.r-project.org") {
    # Function to check if a package is installed
    is_installed <- function(pkg) {
        return(pkg %in% rownames(installed.packages()))
    }

    # Check each package and install if needed
    results <- sapply(packages, function(pkg) {
        if (!is_installed(pkg)) {
            message("Installing package: ", pkg)
            install.packages(pkg, repos = repos, dependencies = TRUE)
            return(require(pkg, character.only = TRUE))
        } else {
            return(TRUE)
        }
    })

    # Report results
    if (all(results)) {
        message("All required packages are installed and loaded.")
    } else {
        failed <- packages[!results]
        warning("Failed to install/load the following packages: ",
                paste(failed, collapse = ", "))
    }

    return(invisible(results))
}

# Example: Install all packages needed for forestry data access
install_packages <- function() {
    required_packages <- c(
        "R.utils",       # For CRU climate data unzipping
        "rgbif",         # For GBIF species data
        "MODISTools",    # For MODIS vegetation indices
        "sf",            # For spatial data handling (EFFIS)
        "dplyr",         # For data manipulation
        "lubridate",     # For date handling
        "ggplot2",       # For plotting
        "maps"           # For map data
    )

    install_required_packages(required_packages)
}
