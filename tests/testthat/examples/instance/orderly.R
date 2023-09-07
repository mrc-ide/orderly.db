dat1 <- orderly.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  database = "db",
  instance = "main")
dat2 <- orderly.db::orderly_db_query(
  query = "SELECT * FROM mtcars",
  database = "db",
  instance = "dev")

orderly2::orderly_artefact("Some data", c("data1.rds", "data2.rds"))

saveRDS(dat1, "data1.rds")
saveRDS(dat2, "data2.rds")
