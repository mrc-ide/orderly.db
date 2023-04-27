`%||%` <- function(x, y) { # nolint
  if (is.null(x)) y else x
}


set_names <- function(x, nms) {
  names(x) <- nms
  x
}


sql_str_sub <- function(s, data) {
  vapply(s, function(s) DBI::sqlInterpolate(DBI::ANSI(), s, .dots = data), "",
         USE.NAMES = FALSE)
}
