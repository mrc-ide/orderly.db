orderly2::orderly_parameters(mpg_min = NULL)
orderly.db::orderly_db_query(
  query = "SELECT * FROM mtcars WHERE mpg > ?mpg_min",
  as = "dat")
orderly2::orderly_artefact("Some data", "data.rds")

saveRDS(dat, "data.rds")
