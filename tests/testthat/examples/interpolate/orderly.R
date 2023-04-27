orderly3::orderly_parameters(mpg_min = NULL)
orderly3.db::orderly_db_query(
  query = "SELECT * FROM mtcars WHERE mpg > ?mpg_min",
  as = "dat")
orderly3::orderly_artefact("Some data", "data.rds")

saveRDS(dat, "data.rds")
