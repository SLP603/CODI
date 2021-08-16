
result <- tryCatch({
  conn <- getNewDBConnection()
  
  if(tolower(PartnerID) == "hfc"){
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts_non_CHORDS_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export_non_CHORDS_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_hfc.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic_hfc.sql"))
  } else if (tolower(PartnerID) == "gotr"){
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts_non_CHORDS.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export_non_CHORDS.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic.sql")) 
  } else {
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_counts.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"enc_test.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"ec_test_latest_loc_date.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort_demographic_age_filter.sql"))
    # Per Ken, all the programs are in so any session record should be included to consideration in the query
    # study_programs_cwmp.sql is not used at this time.
    #run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP, sqlType,"study_programs_cwmp.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_inclusion.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_exclusion.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"recent_well_child.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"encounter_count.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_export.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"cohort.sql"))
    run_db_query(db_conn=conn, sql_location=here("sql", paste0("Step", CODISTEP), sqlType,"study_cohort_demographic.sql"))
  }
  
  sqlResult <- run_db_query_andromeda(conn, "
  SELECT linkid
  	,patid
  	,cast(birth_date AS VARCHAR) birth_date
  	,sex
  	,race
  	,hispanic
  	,yr
  	,encN
  	,cast(loc_start AS VARCHAR) loc_start
  	,cast(most_recent_well_child_visit AS VARCHAR) most_recent_well_child_visit
  	,enc_count
  	,inclusion
  	,exclusion
  FROM #study_cohort_demographic", andromedaTableName = "study_cohort_demographic")
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
