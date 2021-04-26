renv::restore()

library("RODBC")
library("here")
library("SqlRender")

source(here("Setup.r"))
source(here("R", "functions.r"))

conn <- getNewDBConnection()
tryCatch({
  
  result1 <- run_db_query(conn, readSql(here("sql", "enc_counts.sql")))
  result2 <- run_db_query(conn, readSql(here("sql", "enc_test.sql")))
  result3 <- run_db_query(conn, readSql(here("sql", "ec_test_latest_loc_date.sql")))
  result4 <- run_db_query(conn, readSql(here("sql", "cohort_demographic.sql")))
  result5 <- run_db_query(conn, readSql(here("sql", "cohort_demographic_age.sql")))
  result6 <- run_db_query(conn, readSql(here("sql", "cohort_demographic_age_filter.sql")))
  result7 <- run_db_query(conn, readSql(here("sql", "study_programs_cwmp.sql")))
  result8 <- run_db_query(conn, readSql(here("sql", "study_cohort.sql")))
  result9 <- run_db_query(conn, readSql(here("sql", "study_cohort_inclusion.sql")))
  result10 <- run_db_query(conn, readSql(here("sql", "study_cohort_exclusion.sql")))
  result11 <- run_db_query(conn, readSql(here("sql", "study_cohort.sql")))
  result12 <- run_db_query(conn, readSql(here("sql", "encounter_count.sql")))
  result13 <- run_db_query(conn, readSql(here("sql", "study_cohort_export.sql")))
  result14 <- run_db_query(conn, readSql(here("sql", "cohort.sql")))

  sqlResult <- run_db_query(conn, "SELECT * FROM #study_cohort_demographic")
}, error = function(cond){
  stop(cond)
}, finally = {
  tryCatch({RODBC::odbcClose(conn)})
})

write.csv(x = sqlResult, 
          file = paste("study_cohort_demographic_", PartnerID ,sep=''), 
          row.names = F, 
          quote = T, 
          sep = ",")
