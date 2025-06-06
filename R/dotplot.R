#' Dot plot for dose-response data
#'
#' @description
#' Generates a dot plot for dose-response data
#'
#' @param x An object created with \code{\link{netdose}}.
#' @param method The method used to create the dot plot. Either,
#'   \code{"dotplot"} to use \code{\link[ggplot2]{geom_dotplot}} or
#'   \code{"point"} to use \code{\link[ggplot2]{geom_point}}; can be
#'   abbreviated.
#' @param drop.single.dose A logical indicating whether to drop the
#'   panel for an agent with a single dose.
#' @param drop.reference.group A logical indicating whether to drop the
#'   panel for the reference group.
#' @param col The color used for the border of dots.
#' @param fill The color used for the background of dots.
#' @param size A single numeric with the size of the dots.
#' @param spacing A single numeric with the space between dots; only considered
#'   if \code{method = "point"}.
#' @param numbers A logical indicating whether to print the number of doses
#'   per agent (only considered if \code{method = "point"}).
#' @param col.numbers The color used for the number of doses.
#' @param size.numbers A single numeric with the size the number of doses.
#' @param ylab A label for the y-axis.
#' @param \dots Additional arguments (ignored).
#'
#' @details
#' The function produces a dot plot of drug doses.
#'
#' Using argument \code{method = "dotplot"}, dots are aligned in on the
#' horizontal axis. However, this function does not produce the same dot size
#' for agents with a single dose. Furthermore, an irrelevant note is triggered
#' regarding the bin width.
#' 
#' Argument \code{method = "point"} can be used to plot the same dot size for
#' agents with a single dose, however, dots are not aligned.
#' 
#' @note For argument \code{method = "dotplot"}, the message
#'   \emph{'Bin width defaults to 1/30 of the range of the data.
#'   Pick better value with `binwidth`.'} is irrelevant as dot sizes should
#'   be identical. Setting the argument 'binwidth' would not result in the
#'   same dot sizes for different drugs.
#' 
#' @return No return value.
#' 
#' @keywords hplot
#' 
#' @seealso \code{\link{netdose}}
#'
#' @author Guido Schwarzer <guido.schwarzer@@uniklinik-freiburg.de>
#'
#' @examples
#' # Use a subset of 5 studies from anesthesia data
#' anesthesia_subset <-
#'   subset(anesthesia, study %in% unique(anesthesia$study)[1:5])
#' 
#' # Prepare data for DR-NMA
#' dat <- pairwise(
#'   agent = list(agent1, agent2, agent3),
#'   event = list(event1, event2, event3),
#'   n = list(n1, n2, n3),
#'   dose = list(dose1, dose2, dose3),
#'   data = anesthesia_subset,
#'   studlab = study,
#'   append = FALSE)
#' 
#' # DR-NMA with linear dose-response function
#' dr1 <- netdose(TE, seTE, agent1, dose1, agent2,
#'   dose2, studlab,
#'   data = dat)
#'
#' # Dose-response plot
#' dotplot(dr1)
#' 
#' @export dotplot

dotplot <- function(x,
                    method = "dotplot",
                    drop.single.dose = FALSE,
                    drop.reference.group = TRUE,
                    #
                    col = "black", fill = "steelblue",
                    size = 2, spacing = 0.1,
                    numbers = FALSE,
                    col.numbers = "black", size.numbers = 2,
                    ylab = "Dose", ...) {
  # Check class
  chkclass(x, "netdose")
  #
  if (is.null(x$data))
    stop("Data set missing due to using netdose() with ",
         "argument 'keepdata = FALSE'.",
         call. = FALSE)
  #
  method <- setchar(method, c("dotplot", "point"))
  chklogical(drop.single.dose)
  chklogical(drop.reference.group)
  #
  chkcolor(col, length = 1)
  chkcolor(fill, length = 1)
  chknumeric(size, min = 0, zero = TRUE, length = 1)
  chknumeric(spacing, min = 0, zero = TRUE, length = 1)
  #
  chklogical(numbers)
  chkcolor(col.numbers, length = 1)
  chknumeric(size.numbers, min = 0, zero = TRUE, length = 1)
  #
  chkchar(ylab, length = 1)
  
  # Get rid of warnings "no visible binding for global variable"
  #
  studlab <- agent <- .agent <- .agent1 <- .agent2 <-
    dose <- .dose <- .dose1 <- .dose2 <- dose_norm <-
    dmin <- dmax <- range_min <- range_max <-
    stack <- n_stack <- offset <- x_pos <-
    x_label <- y_label <- NULL
  
  # Convert data set to long-arm format
  #
  dat <- x$data %>%
    pivot_longer(cols = c(.agent1, .agent2, .dose1, .dose2),
                 names_to = c(".value", "number"),
                 names_pattern = "(.agent|.dose)([12])") %>%
    select(studlab, .agent, .dose) %>%
    distinct() %>%
    rename(agent = .agent, dose = .dose)
  #
  if (drop.reference.group) {
    dat <- dat %>%
      filter(agent != x$reference.group)
  }
  #
  if (drop.single.dose) {
    sel.to.drop <- dat %>%
      group_by(agent) %>%
      filter(n_distinct(dose) == 1) %>%
      pull(agent) %>%
      unique()
    #
    dat <- dat %>% filter(!agent %in% sel.to.drop)
  }
  #
  if (method == "dotplot") {
    dat <- dat %>%
      mutate(dose_norm = dose)
  }
  else {
    # Normalize dose per agent
    #
    dose_ranges <- dat %>%
      group_by(agent) %>%
      summarise(
        dmin = min(dose),
        dmax = max(dose),
        n = n_distinct(dose),
        .groups = "drop"
      ) %>%
      mutate(
        range_min = if_else(n == 1, dmin - 1, dmin),
        range_max = if_else(n == 1, dmax + 1, dmax)
      )
    
    dat <- dat %>%
      left_join(dose_ranges, by = "agent") %>%
      mutate(
        dose_norm = (dose - range_min) / (range_max - range_min)
      )
    
    # Stack, center, equidistant points
    #
    dat <- dat %>%
      group_by(agent, dose) %>%
      mutate(
        stack = row_number(),
        n_stack = n(),
        # Centered stack index: -floor(n/2), ..., 0, ..., floor(n/2)
        offset = stack - (n_stack + 1) / 2,
        # Spread factor to scale to desired width across any count
        x_pos = 1 + offset * spacing
      ) %>%
      ungroup()
    
    # Per-facet axis labels
    #
    y_breaks_labels <- dat %>%
      distinct(agent, dose, dose_norm)
    #
    facet_levels <- levels(factor(dat$agent))
    #
    y_scales <- lapply(facet_levels, function(x) {
      df <- y_breaks_labels %>% filter(agent == x)
      scale_y_continuous(breaks = df$dose_norm, labels = df$dose,
                         guide = guide_axis(check.overlap = TRUE))
    })
    #
    if (numbers) {
      dose_counts <- dat %>%
        count(agent, dose) %>%
        left_join(
          dat %>% distinct(agent, dose, dose_norm),
          by = c("agent", "dose")
        ) %>%
        mutate(
          x_label = 1.7,
          y_label = dose_norm
        )
    }
    #
    # Drop points outside the print range to get rid of warning
    #
    dat <- dat %>%
      filter(x_pos >= 0.5 & x_pos <= 1.5)
  }
  
  
  # Create plot
  #
  if (method == "dotplot") {
    p <- ggplot(dat, aes(x = 1, y = dose_norm)) +
      geom_dotplot(binaxis = "y",
                   stackdir = "center",
                   method = "histodot",
                   dotsize = size, fill = fill, color = col) +
      facet_wrap(~agent, scales = "free_y")
  }
  else {
    suppressWarnings(
      p <- ggplot(dat, aes(x = x_pos, y = dose_norm)) +
        geom_point(
          size = size,
          shape = 21,
          fill = fill,
          color = col,
          stroke = 0.5
        ) +
        facet_wrap2(~agent, scales = "free_y") +
        facetted_pos_scales(y = y_scales) +
        scale_x_continuous(breaks = NULL)
    )
  }
  #
  p <- p +
    labs(x = "", y = ylab) +
    theme_minimal() +
    theme(plot.title = element_text(size = 10),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          #
          strip.background = element_rect(fill = "gray80", color = NA),
          #
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank())
  #
  if (method == "point") {
    p <- p + theme(panel.grid.minor.y = element_blank())
    #
    # Add dose count per agent and dose to plot
    #
    if (numbers) {
      p <- p +
        geom_text(
          data = dose_counts,
          aes(x = x_label, y = y_label, label = n),
          check_overlap = TRUE,
          color = col.numbers,
          size = size.numbers,
          hjust = 1) +
        coord_cartesian(xlim = c(0.4, 1.6), clip = "off")
    }
    else
      p <- p + coord_cartesian(xlim = c(0.5, 1.5))
  }
  #
  p
}
