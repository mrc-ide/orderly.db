.onLoad <- function(...) {
  # nocov start
  orderly::orderly_plugin_register(
    "orderly.db",
    config = orderly_db_config,
    serialise = orderly_db_serialise,
    deserialise = orderly_db_deserialise,
    cleanup = orderly_db_cleanup,
    schema = "orderly.db.json")
  # nocov end
}
