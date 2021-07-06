
result <- tryCatch({
  conn <- getNewDBConnection()

  if(tolower(PartnerID) == "hfc"){
    result1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts_non_CHORDS_hfc.sql"))
    result2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test_hfc.sql"))
    result3 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date_hfc.sql"))
    result4 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_hfc.sql"))
    result5 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_hfc.sql"))
    result6 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter_hfc.sql"))
    result8 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_hfc.sql"))
    result9 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion_hfc.sql"))
    result10 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion_hfc.sql"))
    result13 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export_non_CHORDS_hfc.sql"))
    result14 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_hfc.sql"))
    result15 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic_hfc.sql"))
  } else if (tolower(PartnerID) == "gotr"){
    result1 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts_non_CHORDS.sql"))
    result2 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test.sql"))
    result3 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date.sql"))
    result4 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic.sql"))
    result5 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age.sql"))
    result6 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter.sql"))
    result8 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort.sql"))
    result9 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion.sql"))
    result10 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion.sql"))
    result13 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export_non_CHORDS.sql"))
    result14 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort.sql"))
    result15 <- run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic.sql")) 
  } else {
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
  }
  
  sqlResult <- run_db_query_andromeda(conn, "SELECT * FROM #study_cohort_demographic", andromedaTableName = "study_cohort_demographic")
  dir.create(here("output", paste0("Step_", CODISTEP)), showWarnings = F, recursive = T)
  writeOutput_andromeda("study_cohort_demographic", sqlResult, andromedaTableName = "study_cohort_demographic")
  Andromeda::close(sqlResult)
  
}, error = function(err) {
  stop(err)
}, finally = function(){
  tryCatch({
    DBI::dbDisconnect(conn)
    Andromeda::close(sqlResult)
    })
})

message(paste0("CODI Step ", CODISTEP, " done!"))
