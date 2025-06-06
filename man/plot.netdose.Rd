% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.netdose.R
\name{plot.netdose}
\alias{plot.netdose}
\title{Dose-response curve plot}
\usage{
\method{plot}{netdose}(
  x,
  pooled = if (x$random) "random" else "common",
  only.direct = TRUE,
  col.direct = if (only.direct) "black" else "green",
  col.indirect = "red",
  agents = NULL,
  ylim = NULL,
  benchmark.threshold = NULL,
  plateau.threshold = NULL,
  col.line = "blue",
  col.bmdl = "purple",
  col.med = "gray40",
  legend = !only.direct,
  ...
)
}
\arguments{
\item{x}{An object of class netdose (mandatory).}

\item{pooled}{A character string indicating whether results for the
common (\code{"common"}) or random effects model
(\code{"random"}) should be plotted.  Abbreviations are allowed.
Defaults to "random" if the input object specifies a random effects model;
otherwise, defaults to "common".}

\item{only.direct}{A logical value indicating whether only the study results
of direct comparisons with the reference agent for the observed data should
be shown in the plot. Defaults to \code{TRUE}.}

\item{col.direct}{The color used for points representing direct comparisons.
By default, \code{"black"} when \code{only.direct = TRUE}; otherwise,
\code{"green"}.}

\item{col.indirect}{The color used for points representing indirect
comparisons. Defaults to \code{"red"}.}

\item{agents}{Optional character vector specifying which agents to include
in the plot. If NULL, all agents will be plotted.}

\item{ylim}{Optional numeric vector of length 2 specifying the y-axis limits.
If NULL, limits are determined automatically.}

\item{benchmark.threshold}{Numeric; benchmark response level (e.g., 0.1 for
10 percent). Used to compute Benchmark Dose Lower Confidence Limit (BMDL).}

\item{plateau.threshold}{Numeric; threshold for identifying the plateau in
the dose-response curve. Defines the minimum absolute change in predicted
response between adjacent dose levels, below which the response is
considered stable (i.e., plateau has been reached). Used to calculate the
Maximum Effective Dose (MED). Default: \code{0.0001}.}

\item{col.line}{Colour for the dose-response line.}

\item{col.bmdl}{Colour for the BMLD line.}

\item{col.med}{Colour for the MED line.}

\item{legend}{A logical value indicating whether to print a legend.}

\item{\dots}{Additional arguments. Currently ignored, but included for
potential future extensions or compatibility with generic plotting
functions.}
}
\value{
No return value, called for side effects (generates a plot).
}
\description{
Generates a dose-response plot based on the results of a dose-response
network meta-analysis (DR-NMA). The plot visualizes predicted dose-response
curves alongside observed responses for easy interpretation of model outputs.
}
\details{
The function plots the dose-response curve alongside the observed responses:

\itemize{
\item The vertical axis represents the dose range, which is defined from 0
  to the maximum observed dose, with 100 evenly spaced points generated
  within this range.
\item The horizontal axis represents the predicted response values,
  calculated using the \code{predict.netdose} function.
}

The plot includes shaded confidence intervals for the predicted dose-response
curve. Observed responses are overlaid for comparison, differentiated into
direct and indirect comparisons with customizable colors.

The function also optionally displays the Benchmark Dose (BMD) and the
Benchmark Dose Lower Confidence Limit (BMDL), based on a user-defined
benchmark response threshold (e.g., 0.01 for 10 percent increase).

If the model indicates that the predicted response stabilizes beyond a
certain dose level, the function estimates and plots the Maximum Effective
Dose (MED) — the smallest dose beyond which the predicted response increases
less than a given threshold (controlled via \code{plateau.threshold}). MED
is shown only if it occurs after the BMDL, ensuring biological and
statistical coherence.
}
\examples{
# Use a subset of 5 studies from anesthesia data
anesthesia_subset <-
  subset(anesthesia, study \%in\% unique(anesthesia$study)[1:5])

# Prepare data for DR-NMA
dat <- pairwise(
  agent = list(agent1, agent2, agent3),
  event = list(event1, event2, event3),
  n = list(n1, n2, n3),
  dose = list(dose1, dose2, dose3),
  data = anesthesia_subset,
  studlab = study,
  append = FALSE
)

# DR-NMA with linear dose-response function
dr1 <- netdose(TE, seTE, agent1, dose1, agent2,
  dose2, studlab,
  data = dat
)

# Dose-response plot
plot(dr1)

}
\author{
Maria Petropoulou <maria.petropoulou@uniklinik-freiburg.de>,
 Guido Schwarzer <guido.schwarzer@uniklinik-freiburg.de>
}
\keyword{hplot}
