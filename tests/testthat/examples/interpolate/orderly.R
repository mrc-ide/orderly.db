orderly2::orderly_parameters(mpg_min = NULL)
dat <- orderly.db::orderly_db_query("SELECT * FROM mtcars WHERE mpg > ?mpg_min")
orderly2::orderly_artefact("Some data", "data.rds")

saveRDS(dat, "data.rds")
