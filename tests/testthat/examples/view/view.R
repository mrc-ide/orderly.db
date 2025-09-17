orderly::orderly_artefact(description = "Some data", files = "data.rds")
orderly.db::orderly_db_view(
  as = "thedata",
  query = "SELECT mpg, cyl FROM mtcars")
dat <- orderly.db::orderly_db_query("SELECT * FROM thedata")

saveRDS(dat, "data.rds")
