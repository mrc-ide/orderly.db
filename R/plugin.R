orderly_db_config <- function(data, filename) {
  if (length(data) == 0) {
    stop(sprintf("%s:orderly3.db must contain at least one database", filename))
  }
  assert_named(data, unique = TRUE, name = sprintf("%s:orderly3.db", filename))
  for (nm in names(data)) {
    db <- data[[nm]]
    prefix <- sprintf("%s:orderly3.db:%s", filename, nm)
    check_fields(db, prefix, c("driver", "args"), NULL)
    driver <- check_symbol_from_str(db$driver, paste0(prefix, ":driver"))
    db$driver <- driver

    assert_named(db$args, TRUE, paste0(prefix, ":args"))

    ## There are two things to check with SQLite - first that we don't
    ## use in-memory databases as we'll never reconnect to them. This
    ## is probably not that useful a check but orderly does do it so
    ## we may have added it for some reason.
    ##
    ## The other is more important though, which is is that database
    ## files *should* be presented as relative paths, but these paths
    ## will be interpreted relative to the root. At the point where we
    ## process this configuration we are guaranteed to have the
    ## working directory be the orderly root so we can build an
    ## absolute path at this point.
    ##
    ## Similar checks would be required for other database backends
    ## that use absolute paths, there might be some way to make this
    ## more general.
    if (identical(driver, c("RSQLite", "SQLite"))) {
      assert_scalar_character(db$args$dbname, paste0(prefix, ":args:dbname"))
      if (db$args$dbname == ":memory:") {
        stop("Can't use an in-memory database with orderly3.db")
      }
      if (!fs::is_absolute_path(db$args$dbname)) {
        db$args$dbname <- file.path(getwd(), db$args$dbname)
      }
    }

    data[[nm]] <- db
  }
  data
}


orderly_db_serialise <- function(data) {
  for (nm in c("query", "view", "connection")) {
    for (i in seq_along(data[[nm]])) {
      d <- data[[nm]][[i]]
      j <- names(d) != "cols"
      d[j] <- lapply(d[j], jsonlite::unbox)
      data[[nm]][[i]] <- d
    }
  }
  jsonlite::toJSON(data, auto_unbox = FALSE, pretty = FALSE, na = "null",
                   null = "null")
}
