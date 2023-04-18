orderly3.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  as = "dat1",
  database = "db",
  instance = "main")
orderly3.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  as = "dat2",
  database = "db",
  instance = "dev")

orderly3::orderly_artefact("Some data", c("data1.rds", "data2.rds"))

saveRDS(dat1, "data1.rds")
saveRDS(dat2, "data2.rds")
