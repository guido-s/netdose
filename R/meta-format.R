#
# Auxiliary functions to format print output (from R package meta)
#
# Package: netdose
# Author: Guido Schwarzer <guido.schwarzer@uniklinik-freiburg.de>
# License: GPL (>= 2)
#

formatCI <- function(lower, upper,
                     bracket.left = gs("CIbracket"),
                     separator = gs("CIseparator"),
                     bracket.right,
                     justify.lower = "right",
                     justify.upper = justify.lower,
                     lower.blank = gs("CIlower.blank"),
                     upper.blank = gs("CIupper.blank"),
                     ...
                     ) {
  
  # Change layout of CIs
  #
  chkchar(bracket.left, length = 1)
  chkchar(separator, length = 1)
  if (!missing(bracket.right))
    chkchar(bracket.right, length = 1)
  #
  if (missing(bracket.left)) {
    bracktype <- setchar(bracket.left, c("[", "(", "{", ""))
    #
    if (bracktype == "[") {
      bracketLeft <- "["
      bracketRight <- "]"
    }
    else if (bracktype == "(") {
      bracketLeft <- "("
      bracketRight <- ")"
    }
    else if (bracktype == "{") {
      bracketLeft <- "{"
      bracketRight <- "}"
    }
    else if (bracktype == "") {
      bracketLeft <- ""
      bracketRight <- ""
    }
    #
    bracket.left <- bracketLeft
  }
  #
  if (missing(bracket.right))
    bracket.right <- bracketRight
  
  format.lower <- format(lower, justify = justify.lower)
  format.upper <- format(upper, justify = justify.upper)
  #
  if (!lower.blank)
    format.lower <- rmSpace(format.lower)
  if (!upper.blank)
    format.upper <- rmSpace(format.upper)
  #
  if (separator == "-")
    format.upper <-
      paste0(ifelse(substring(format.upper, 1, 1) == "-", " ", ""),
             format.upper)
  #
  res <- ifelse(lower != "NA" & upper != "NA",
                paste0(bracket.left,
                       format.lower,
                       separator,
                       format.upper,
                       bracket.right),
                "")
  #
  res
}

formatN <- function(x, digits = 2, text.NA = "--", big.mark = "",
                    format.whole.numbers = TRUE,
                    monospaced = FALSE) {
  
  outdec <- options()$OutDec  

  if (!monospaced) {
    if (format.whole.numbers) {
      res <- format(ifelse(is.na(x),
                           text.NA,
                           formatC(x, decimal.mark = outdec,
                                   format = "f", digits = digits,
                                   big.mark = big.mark)
                           )
                    )
    }
    else {
      res <- format(ifelse(is.na(x),
                           text.NA,
                    ifelse(is_wholenumber(x),
                           x,
                           formatC(x, decimal.mark = outdec,
                                   format = "f", digits = digits,
                                   big.mark = big.mark)
                           )
                    )
                    )
    }
  }
  else {
    x <- round(x, digits)
    res <- ifelse(is.na(x),
                  text.NA,
                  format(x, decimal.mark = outdec, big.mark = big.mark))
  }
  #
  res <- rmSpace(res, end = TRUE)
  #
  res
}

formatPT <- function(x, lab = FALSE, labval = "p", noblanks = FALSE,
                     digits = 4, zero = TRUE, scientific = FALSE,
                     lab.NA = "--", big.mark = "",
                     JAMA = FALSE) {
  
  if (is.null(x))
    return("")
  
  outdec <- options()$OutDec
  
  n.zeros <- digits - 1
  n.zeros[n.zeros < 0] <- 0
  
  if (!scientific) {
    if (lab) {
      if (!JAMA)
        res <- format(ifelse(is.na(x) | is.nan(x),
                             paste(labval, "=", lab.NA),
                      ifelse(x == 0,
                             paste(labval, "= 0"),
                      ifelse(x < 1 / 10^digits,
                             paste0(labval, " < 0", outdec,
                                    paste(rep("0",
                                             n.zeros), collapse = ""),
                                    "1"),
                             paste(paste(labval, "="),
                                   formatC(round(x, digits),
                                           decimal.mark = outdec,
                                           big.mark = big.mark,
                                           format = "f", digits = digits)
                                   )
                             )
                      )
                      )
                      )
      else
        res <- format(ifelse(is.na(x) | is.nan(x),
                             paste(labval, "=", lab.NA),
                      ifelse(x < 0.001,
                             paste0(labval, " < 0", outdec,
                                    paste(rep("0", 2), collapse = ""), "1"),
                      ifelse(x >= 0.001 & x < 0.01,
                             paste(paste(labval, "="),
                                   formatC(x,
                                           decimal.mark = outdec,
                                           big.mark = big.mark,
                                           format = "f", digits = 3)),
                      ifelse(x >= 0.01 & x <= 0.99,
                             paste(paste(labval, "="),
                                   formatC(x,
                                           decimal.mark = outdec,
                                           big.mark = big.mark,
                                           format = "f", digits = 2)),
                             paste(paste(labval, ">"),
                                   formatC(0.99,
                                           decimal.mark = outdec,
                                           big.mark = big.mark,
                                           format = "f", digits = 2)))
                      )
                      )
                      )
                      )
      
    }
    else {
      if (!JAMA)
        res <- format(ifelse(is.na(x) | is.nan(x),
                             lab.NA,
                      ifelse(x == 0,
                             0,
                      ifelse(x < 1 / 10^digits,
                             paste0("< 0", outdec,
                                    paste(rep("0", n.zeros), collapse = ""),
                                    "1"),
                             formatC(round(x, digits),
                                     decimal.mark = outdec,
                                     big.mark = big.mark,
                                     format = "f", digits = digits)
                             )
                      )
                      ),
                      justify = "right")
      else
        res <- format(ifelse(is.na(x) | is.nan(x),
                             lab.NA,
                      ifelse(x < 0.001,
                             paste0("< 0", outdec,
                                    paste(rep("0", 2), collapse = ""), "1"),
                      ifelse(x >= 0.001 & x < 0.01,
                             formatC(x,
                                     decimal.mark = outdec,
                                     big.mark = big.mark,
                                     format = "f", digits = 3),
                      ifelse(x >= 0.01 & x <= 0.99,
                             formatC(x,
                                     decimal.mark = outdec,
                                     big.mark = big.mark,
                                     format = "f", digits = 2),
                             paste(">",
                                   formatC(0.99,
                                           decimal.mark = outdec,
                                           big.mark = big.mark,
                                           format = "f", digits = 2)))
                      )
                      )
                      ),
                      justify = "right")
    }
  }
  else {
    if (lab)
      res <- format(ifelse(is.na(x) | is.nan(x),
                           paste(labval, "=", lab.NA),
                           paste(labval, "=",
                                 formatC(x, decimal.mark = outdec,
                                         big.mark = big.mark,
                                         format = "e", digits = digits)
                                 )
                           )
                    )
    else
      res <- formatC(x, decimal.mark = outdec,
                     big.mark = big.mark, format = "e", digits = digits)
  }
  #
  if (noblanks)
    res <- gsub(" ", "", res)
  if (!zero)
    res <- gsub("0\\.", "\\.", res)
  #
  # Treat NaNs as NAs
  #
  res[grep("NaN", res)] <- lab.NA
  
  res
}

pasteCI <- function(lower, upper, digits, big.mark,
                    sign.lower = "", sign.upper = "", text.NA = "NA",
                    unit = "")
  paste0(" ",
         formatCI(paste0(sign.lower,
                         formatN(lower, digits, big.mark = big.mark,
                                 text.NA = text.NA), unit),
                  paste0(sign.upper,
                         formatN(upper, digits, big.mark = big.mark,
                                 text.NA = text.NA), unit)))

rmSpace <- function(x, end = FALSE, pat = " ") {
  
  if (!end) {
    while (any(substring(x, 1, 1) == pat, na.rm = TRUE)) {
      sel <- substring(x, 1, 1) == pat
      x[sel] <- substring(x[sel], 2)
    }
  }
  else {
    last <- nchar(x)
    
    while (any(substring(x, last, last) == pat, na.rm = TRUE)) {
      sel <- substring(x, last, last) == pat
      x[sel] <- substring(x[sel], 1, last[sel] - 1)
      last <- nchar(x)
    }
  }
  
  x
}
