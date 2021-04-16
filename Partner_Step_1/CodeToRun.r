renv::restore()

library("RODBC")
library("here")
library("SqlRender")

source(here("Setup.r"))
source(here("R", "functions.r"))

tryCatch({
	conn <- getNewDBConnection()

	run_db_query(conn, readSql(here("sql", "enc_counts.sql")))
	run_db_query(conn, readSql(here("sql", "cohort_demographic.sql")))
	run_db_query(conn, readSql(here("sql", "cohort_demographic_age.sql")))
	run_db_query(conn, readSql(here("sql", "cohort_demographic_age_filter.sql")))
	run_db_query(conn, readSql(here("sql", "study_programs.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort.sql")))
	run_db_query(conn, readSql(here("sql", "study_sample.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort_inclusion.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort_exclusion.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort.sql")))
	run_db_query(conn, readSql(here("sql", "encounter_count.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort_export.sql")))
	run_db_query(conn, readSql(here("sql", "cohort.sql")))
	run_db_query(conn, readSql(here("sql", "study_cohort_demographic.sql")))
	
	sqlResult <- run_db_query(conn, "SELECT * FROM #study_cohort_demographic")
	
},error = function(cond){
    stop(cond)
	
}, finally = {
	RODBC::odbcClose(conn)
	
})

write.csv(x = sqlResult, 
          file = paste("study_cohort_demographic_", PartnerID ,sep=''), 
          row.names = F, 
          quote = T, 
          sep = ",")
