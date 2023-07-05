orderly.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  as = "dat1")
orderly2::orderly_artefact("Some data", "data.rds")

saveRDS(dat1, "data.rds")
