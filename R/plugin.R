orderly_db_config <- function(data, filename) {
  if (length(data) == 0) {
    stop(sprintf("%s:orderly.db must contain at least one database", filename))
  }
  assert_named(data, unique = TRUE, name = sprintf("%s:orderly.db", filename))
  for (nm in names(data)) {
    db <- data[[nm]]
    prefix <- sprintf("%s:orderly.db:%s", filename, nm)
    optional <- c("args", "instances", "default_instance")
    check_fields(db, prefix, "driver", optional)
    driver <- check_symbol_from_str(db$driver, paste0(prefix, ":driver"))
    db$driver <- driver

    is_sqlite <- identical(driver, c("RSQLite", "SQLite"))

    if (is.null(db$instances)) {
      assert_named(db$args, TRUE, paste0(prefix, ":args"))
      if (is_sqlite) {
        db$args <- check_sqlite(db$args, paste0(prefix, ":args"))
      }
      instances <- list(default = db$args)
    } else {
      instances <- list()
      assert_named(db$instances, TRUE, paste0(prefix, ":instances"))
      base <- db$args %||% set_names(list(), character())
      for (i in names(db$instances)) {
        prefix_i <- paste0(prefix, ":instances:", i)
        assert_named(db$instances[[i]], TRUE, prefix_i)
        instances[[i]] <- utils::modifyList(base, db$instances[[i]])
        if (is_sqlite) {
          instances[[i]] <- check_sqlite(instances[[i]], prefix_i)
        }
      }
    }
    db$instances <- instances

    if (is.null(db$default_instance)) {
      db$default_instance <- names(db$instances)[[1]]
    }
    match_value(db$default_instance, names(db$instances),
                paste0(prefix, ":default_instance"))

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


orderly_db_deserialise <- function(data) {
  if (!is.null(data$query)) {
    data$query <- data_frame(
      database = vcapply(data$query, "[[", "database"),
      query = vcapply(data$query, "[[", "query"),
      rows = viapply(data$query, "[[", "rows"),
      cols = I(lapply(data$query, function(x) list_to_character(x$cols))))
  }
  if (!is.null(data$view)) {
    data$view <- data_frame(
      database = vcapply(data$view, "[[", "database"),
      as = vcapply(data$view, "[[", "as"),
      query = vcapply(data$view, "[[", "query"))
  }
  if (!is.null(data$connection)) {
    data$connection <- data_frame(
      database = vcapply(data$connection, "[[", "database"))
  }
  data
}


orderly_db_cleanup <- function() {
  ctx <- orderly2::orderly_plugin_context("orderly.db")
  local_connections_close(ctx$path)
}

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
check_sqlite <- function(x, name) {
  assert_scalar_character(x$dbname, paste0(name, ":dbname"))
  if (!fs::is_absolute_path(x$dbname) && x$dbname != ":memory:") {
    x$dbname <- file.path(getwd(), x$dbname)
  }
  x
}
