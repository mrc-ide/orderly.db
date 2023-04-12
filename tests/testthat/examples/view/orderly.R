orderly3::orderly_artefact("Some data", "data.rds")
orderly3.db::orderly_db_view(
  as = "thedata",
  query = "SELECT mpg, cyl FROM mtcars")
orderly3.db::orderly_db_query(
  as = "dat",
  query = "SELECT * FROM thedata")

saveRDS(dat, "data.rds")
