## Functions copied over from orderly:

check_symbol_from_str <- function(str, name) {
  assert_scalar_character(str, name)
  dat <- strsplit(str, "::", fixed = TRUE)[[1L]]
  if (length(dat) != 2) {
    stop(sprintf("Expected fully qualified name for %s", name))
  }
  dat
}


check_fields <- orderly3:::check_fields
assert_named <- orderly3:::assert_named
assert_scalar_character <- orderly3:::assert_scalar_character
assert_character <- orderly3:::assert_character
match_value <- orderly3:::match_value
squote <- orderly3:::squote
