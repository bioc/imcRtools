% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/show_cpout_features.R
\name{show_cpout_features}
\alias{show_cpout_features}
\title{Display all features measured by CellProfiler.}
\usage{
show_cpout_features(
  path,
  display = c("cell_features", "image_features"),
  cell_features = "var_cell.csv",
  image_features = "var_Image.csv"
)
}
\arguments{
\item{path}{full path to the CellProfiler output folder}

\item{display}{single character indicating which features to display.
Accepted entries are \code{cell_features} to display extracted single-cell
features or \code{image_features} to display extracted image-level features.}

\item{cell_features}{single character indicating the name of the file storing
the extracted cell features.}

\item{image_features}{single character indicating the name of the file 
storing the extracted image features.}
}
\value{
a \code{\link[DT]{datatable}} object
}
\description{
Searchable datatable object of cell and image features as 
extracted by CellProfiler.
}
\examples{
path <- system.file("extdata/mockData/cpout", package = "imcRtools")

# Display cell features 
show_cpout_features(path)

# Display image features 
show_cpout_features(path, display = "image_features")

}
\seealso{
\code{\link{read_cpout}} for the CellProfiler reader function
}
\author{
Nils Eling (\email{nils.eling@dqbm.uzh.ch})
}
