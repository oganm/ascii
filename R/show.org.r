##' @keywords internal
##' @param x x
##' @param beauti beauti
beauty.org <- function(x, beauti = c("e", "m", "s")) {
  x[is.na(x)] <- "NA"
  if (beauti == "s") {
    y <- as.logical((regexpr("^ *$", x)+1)/2) | as.logical((regexpr("\\*.*\\*", x)+1)/2) # bold seulement si != de "" et si pas de bold
    if (length(x[!y]) != 0) x[!y] <- sub("(^ *)([:alpha]*)", "\\1\\*\\2", sub("([:alpha:]*)( *$)", "\\1\\*\\2", x[!y]))
    if (length(x[y]) != 0) x[y] <- sub("(^ *$)", "\\1 ", x[y]) # rajouter suffisamment d'espaces lorsque la case est vide pour l'alignement globale
  }
  if (beauti == "e") {
    y <- as.logical((regexpr("^ *$", x)+1)/2) | as.logical((regexpr("/.*/", x)+1)/2) # it seulement si != de "" et si pas de it
    if (length(x[!y]) != 0) x[!y] <-sub("(^ *)([:alpha]*)", "\\1/\\2", sub("([:alpha:]*)( *$)", "\\1/\\2", x[!y]))
    if (length(x[y]) != 0) x[y] <- sub("(^ *$)", "\\1 ", x[y]) # rajouter suffisamment d'espaces lorsque la case est vide pour l'alignement globale
  }
  if (beauti == "m") {
    y <- as.logical((regexpr("^ *$", x)+1)/2) | as.logical((regexpr("=.*=", x)+1)/2) # it seulement si != de "" et si pas de mono
    if (length(x[!y]) != 0) x[!y] <-sub("(^ *)([:alpha]*)", "\\1=\\2", sub("([:alpha:]*)( *$)", "\\1=\\2", x[!y]))
    if (length(x[y]) != 0) x[y] <- sub("(^ *$)", "\\1 ", x[y]) # rajouter suffisamment d'espaces lorsque la case est vide pour l'alignement globale
  }
  return(x)
}

##' @keywords internal
##' @param caption caption
##' @param caption.level caption.level
header.org <- function(caption = NULL, caption.level = NULL) {
  res <- ""
  if (is.null(caption.level))
    caption.level <- ""
  if (!is.null(caption)) {
    if (is.numeric(caption.level) & caption.level > 0) {
      res <- paste(paste(rep("*", caption.level), collapse = ""), caption, "\n")
    } else if (is.character(caption.level) & caption.level %in% c("s", "e", "m")) {
      if (caption.level == "s")
        res <- paste(beauty.org(caption, "s"), "\n", sep = "")
      else if (caption.level == "e")
        res <- paste(beauty.org(caption, "e"), "\n", sep = "")
      else if (caption.level == "m")
        res <- paste(beauty.org(caption, "m"), "\n", sep = "")
    } else if (caption.level == "none")
      res <- paste(caption, "\n", sep = "")
    else
      res <- paste("#+CAPTION: ", caption, "\n", sep = "")
    }
  return(res)
}

##' @keywords internal
##' @param x x
escape.org <- function(x) {
  xx <- gsub("\\|", " \\\\vert ", x)
  xx
}

##' @keywords internal
##' @param x x
##' @param include.rownames include.rownames 
##' @param include.colnames include.colnames 
##' @param rownames rownames 
##' @param colnames colnames 
##' @param format format 
##' @param digits digits 
##' @param decimal.mark decimal.mark 
##' @param na.print na.print 
##' @param caption caption 
##' @param caption.level 
##' @param width width 
##' @param frame frame 
##' @param grid grid 
##' @param valign valign 
##' @param header header 
##' @param footer footer 
##' @param align align 
##' @param col.width col.width 
##' @param style style 
##' @param lgroup lgroup 
##' @param n.lgroup n.lgroup 
##' @param lalign lalign 
##' @param lvalign lvalign 
##' @param lstyle lstyle 
##' @param rgroup rgroup 
##' @param n.rgroup n.rgroup 
##' @param ralign ralign 
##' @param rvalign rvalign 
##' @param rstyle rstyle 
##' @param tgroup tgroup 
##' @param n.tgroup n.tgroup 
##' @param talign talign 
##' @param tvalign tvalign 
##' @param tstyle tstyle 
##' @param bgroup bgroup
##' @param n.bgroup n.bgroup 
##' @param balign balign 
##' @param bvalign bvalign 
##' @param bstyle bstyle 
##' @param ... ...
show.org.table <- function(x, include.rownames = FALSE, include.colnames = FALSE, rownames = NULL, colnames = NULL, format = "f", digits = 2, decimal.mark = ".", na.print = "", caption = NULL, caption.level = NULL, width = 0, frame = NULL, grid = NULL, valign = NULL, header = FALSE, footer = FALSE, align = NULL, col.width = 1, style = NULL, lgroup = NULL, n.lgroup = NULL, lalign = "c", lvalign = "middle", lstyle = "h", rgroup = NULL, n.rgroup = NULL, ralign = "c", rvalign = "middle", rstyle = "h", tgroup = NULL, n.tgroup = NULL, talign = "c", tvalign = "middle", tstyle = "h", bgroup = NULL, n.bgroup = NULL, balign = "c", bvalign = "middle", bstyle = "h", ...) {

  x <- escape.org(tocharac(x, include.rownames, include.colnames, rownames, colnames, format, digits, decimal.mark, na.print))
  nrowx <- nrow(x)
  ncolx <- ncol(x)
  
  if (!is.null(style)) {
    style <- expand(style, nrowx, ncolx)
    style[!(style %in% c("s", "e", "m"))] <- ""
    style[style == "s"] <- "*"
    style[style == "e"] <- "/"
    style[style == "m"] <- "="
  } else {
    style <- ""
    style <- expand(style, nrowx, ncolx)
  }
  if (include.rownames & include.colnames) {
    style[1, 1] <- ""
  }
  
  before_cell_content <- after_cell_content <- style
  before_cell_content <- paste.matrix(" ", before_cell_content, sep = "")
  after_cell_content <- paste.matrix(after_cell_content, " ", sep = "")

  if (tstyle == "h")
    tstyle <- "s"
  if (bstyle == "h")
    bstyle <- "s"
  if (rstyle == "h")
    rstyle <- "s"
  if (lstyle == "h")
    lstyle <- "s"

  # groups
  if (!is.null(lgroup)) {
    if (!is.list(lgroup))
      lgroup <- list(lgroup)
    n.lgroup <- groups(lgroup, n.lgroup, nrowx-include.colnames)[[2]]
    linelgroup <- linegroup(lgroup, n.lgroup)
  }
  if (!is.null(rgroup)) {
    if (!is.list(rgroup))
      rgroup <- list(rgroup)
    n.rgroup <- groups(rgroup, n.rgroup, nrowx-include.colnames)[[2]]
    linergroup <- linegroup(rgroup, n.rgroup)
  }
  if (!is.null(tgroup)) {
    if (!is.list(tgroup))
      tgroup <- list(tgroup)
    n.tgroup <- groups(tgroup, n.tgroup, ncolx-include.rownames)[[2]]
    linetgroup <- linegroup(tgroup, n.tgroup)
  }
  if (!is.null(bgroup)) {
    if (!is.list(bgroup))
      bgroup <- list(bgroup)
    n.bgroup <- groups(bgroup, n.bgroup, ncolx-include.rownames)[[2]]
    linebgroup <- linegroup(bgroup, n.bgroup)
  }

  if (!is.null(lgroup)) {
    for (i in 1:length(lgroup)) {
      x <- cbind(c(rep("", include.colnames), beauty.org(linelgroup[[i]], lstyle)), x)
    }
  }
  if (!is.null(rgroup)) {
    for (i in 1:length(rgroup)) {
      x <- cbind(x, c(rep("", include.colnames), beauty.org(linergroup[[i]], rstyle)))
    }
  }
  if (!is.null(tgroup)) {
    for (i in 1:length(tgroup)) {
      x <- rbind(c(rep("", include.rownames + length(lgroup)), beauty.org(linetgroup[[i]], tstyle), rep("", length(rgroup))), x)
    }
  }
  if (!is.null(bgroup)) {
    for (i in 1:length(bgroup)) {
      x <- rbind(x, c(rep("", include.rownames + length(lgroup)), beauty.org(linebgroup[[i]], bstyle), rep("", length(rgroup))))
    }
  }
  
  line_separator <- FALSE
  line_separator_pos <- NULL
  if (is.logical(header) & header)
    header <- 1
  if (header > 0) {
    line_separator_pos <- min(c(header, nrowx)) + length(tgroup)
    line_separator <- TRUE
  }

  csep <- matrix("+", nrowx+1, ncolx+1)
  csep[, 1] <- "|"
  csep[, ncol(csep)] <- "|"
  results <- print.character.matrix(x, line_separator = line_separator, line_separator_pos = line_separator_pos, hsep = "-", vsep = "|", csep = csep, before_cell_content = before_cell_content, after_cell_content = after_cell_content, print = FALSE)

  cat(header.org(caption = caption, caption.level = caption.level))
  cat(results, sep = "\n")
}

##' @keywords internal
##' @param x x
##' @param caption caption
##' @param caption.level caption.level
##' @param list.type list.type
##' @param ... ...
show.org.list <- function(x, caption = NULL, caption.level = NULL, list.type = "bullet", ...) {
  indent.mark <- "  "
  if (list.type == "bullet") mark <- rep("-", length(x))
  if (list.type == "number") mark <- paste(seq(1, length(x), 1), ".", sep = "")
  if (list.type == "none")  { mark <- rep("", length(x)); indent.mark = ""}
  if (list.type == "label") {
    if (is.null(names(x))) {
      namesx <- paste("[ [ ", 1:length(x), " ] ]", sep = "")
    } else {
      namesx <- names(x)
    }
    mark <- paste("- ", namesx, " ::", sep = "")
    indent.mark = "  "
  }
  
  charac.x <- vector("character", length(x))
  for (i in 1:length(x)) {
    tmp <- x[[i]]
    tmp <- gsub('\t|(*COMMIT)(*FAIL)', indent.mark, tmp, perl = TRUE)
    charac.x[i] <- sub("(^ *)", paste("\\1", mark[i], " ", sep = ""), tmp)
  }
  cat(header.org(caption = caption, caption.level = caption.level))
  cat(charac.x, sep = "\n")
}
