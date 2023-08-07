.onLoad <- function(...) {
  # nocov start
  orderly2::orderly_plugin_register(
    "orderly.db",
    config = orderly_db_config,
    serialise = orderly_db_serialise,
    cleanup = orderly_db_cleanup,
    schema = "orderly.db.json")
  # nocov end
}
