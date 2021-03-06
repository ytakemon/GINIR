% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coessential_map.R
\name{coessential_map}
\alias{coessential_map}
\title{Perform co-essentially mapping}
\usage{
coessential_map(
  Input_gene = NULL,
  Input_disease = NULL,
  Input_cell_lines = NULL,
  core_num = NULL,
  output_dir = NULL,
  data_dir = NULL,
  test = FALSE
)
}
\arguments{
\item{Input_gene}{string, A vector containing one Hugo Symbol, Default: NULL}

\item{Input_disease}{string, A vector one or more disease contexts, Will perform pan-cancer analyses
(all cell lines) by default, Default: NULL}

\item{Input_cell_lines}{string, A vector DepMap_IDs for which co-essentiality mapping will be performed on.
Will perform pan-cancer analyses (all cell lines) by default, Default: NULL}

\item{core_num}{integer, Number of cores to run analysis, Default: NULL}

\item{output_dir}{string, Full path to where output file should be saved, Default: NULL}

\item{data_dir}{string Path to GINIR_data}

\item{test}{logical, TRUE/FALSE whether you want to run only a small subset (first 10 genes) to ensure function will run properly
priort to running all 18,333 genes. Default: FALSE.}
}
\value{
A data frame containing Pearson correlation coefficients. A copy is also saved to the
directory defined in \code{output_dir}.
}
\description{
Performs multiple correltion coefficent analysese and determines cut to identify most likely co-essential genes.
}
\details{
Description of output data frame
\itemize{
\item \code{GeneNameID_A} - Hugo symbol with NCBI gene ID of query gene.
\item \code{GeneNameID_B} - Hugo symbol with NCBI gene ID of all genes targeted in the DepMap KO screen.
\item \code{estimate} - Correlation coefficient output from \code{?cor.test}.
\item \code{statistic} - Pearson's correlation statistic. Output from \code{?cor.test}.
\item \code{p.value} - P-value from Pearson's correlation statistic. Output from \code{?cor.test}.
\item \code{parameter} - Degrees of freedom. Output from \code{?cor.test}.
\item \code{conf.low} - Confidence interval low end. Output from \code{?cor.test}.
\item \code{conf.high} - Confidence interval high end. Output from \code{?cor.test}.
\item \code{method} - Type of cor.test used. Output from \code{?cor.test}.
\item \code{alternative} - Alternative hypothesis selected. Output from \code{?cor.test}.
\item \code{Rank} - Rank by correlation coefficient.
\item \code{Padj_BH} - Benjamini-Hochberg adjusted p-value.
}
}
\examples{
\dontrun{

Screen_results <- GINI_screen(
Input_gene = "ARID1A", 
output_dir = "~/Desktop/GINI_test_dir/",
data_dir = "/path/to/DepMap_data/",
test = TRUE) # turn on for shorter test runs

}

}
