orderly3.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  as = "dat1",
  database = "source")
orderly3::orderly_artefact("Some data", "data.rds")

saveRDS(dat1, "data.rds")
