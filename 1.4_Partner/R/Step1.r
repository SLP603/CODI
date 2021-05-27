
suppressWarnings(library("here"))
suppressWarnings(library("SqlRender"))

if (DATAMODEL == "CHORDSVDW") {
	sqlType <- "CHORDSVDW"
} else if (DATAMODEL == "CODIVDW"){
	sqlType <- "CODIVDW"
} else {
	stop("DATAMODEL not found or missing.  Check the DATAMODEL variable in Setup.r")
}
result <- tryCatch({
  conn <- getNewDBConnection()

  result1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts.sql"))
  result2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test.sql"))
  result3 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date.sql"))
  result4 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic.sql"))
  result5 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age.sql"))
  result6 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter.sql"))
  # Per Ken, all the programs are in so any session record should be included to consideration in the query
  # study_programs_cwmp.sql is not used at this time.
  # result7 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP, sqlType,"study_programs_cwmp.sql"))
  result8 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort.sql"))
  result9 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion.sql"))
  result10 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion.sql"))
  result11 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"recent_well_child.sql"))
  result12 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"encounter_count.sql"))
  result13 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export.sql"))
  result14 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort.sql"))
  result15 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic.sql"))

  sqlResult <- run_db_query(conn, "SELECT * FROM #study_cohort_demographic")
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({DBI::dbDisconnect(conn)})
})

dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)
outputFile <- here("output", paste0("Step_", CODISTEP), paste0("study_cohort_demographic_", PartnerID, ".csv"))
print(paste0("Writing Results to outputFile", outputFile))
write.csv(x = sqlResult, 
          file = outputFile, 
          row.names = F, 
          quote = T, na = "NULL")

print(paste0("CODI Step ", CODISTEP, " done"))