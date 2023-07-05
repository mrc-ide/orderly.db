.onLoad <- function(...) {
  # nocov start
  schema <- system.file("orderly.db.json", package = "orderly.db",
                        mustWork = TRUE)
  orderly2::orderly_plugin_register(
    "orderly.db",
    config = orderly_db_config,
    serialise = orderly_db_serialise,
    cleanup = orderly_db_cleanup,
    schema = schema)
  # nocov end
}
