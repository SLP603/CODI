renv::restore()

library("RODBC")
library("here")
library("SqlRender")

source(here("Setup.r"))

getConnectionString <- function(){
  
  connectionString <- "Driver={Sql Server};"

  if(nchar(PortNumber) > 0) {
    connectionString <- paste(connectionString, "Server=", ServerName, ",", PortNumber, ";Database=", DatabaseName, ";", sep='')
  }
  else{
    connectionString <- paste(connectionString, "Server=", ServerName, ";Database=", DatabaseName, ";", sep='')
  }

  if(nchar(SQLServerUserName) > 0){
    connectionString <- paste(connectionString, "UID=", SQLServerUserName,";PWD=", SQLServerPassword, ";", sep='' )
  }

  if(nchar(extraSettings) > 0) {
    connectionString <- paste(connectionString, ";", extraSettings, ";", sep='' )
  }
  
  return(connectionString)
}


getNewDBConnection <- function(){
  connection_string <- getConnectionString()
  db_conn <- RODBC::odbcDriverConnect(connection = connection_string, believeNRows = FALSE, rows_at_time = 1)
  return(db_conn)
}

run_db_query <- function(db_conn = NULL, query_text = NULL, renderSql = T, ...) {
  if (is.null(db_conn)){
    db_conn <- getNewDBConnection()
    disconnect <- T
  }
  else{
    disconnect <- F
  }
  
  if (is.null(query_text)) {
    stop("No query argument was passed to function")
  }
  
  rendered_sql_query <- renderSqlText(query_text = query_text, render = renderSql )
  
  tryCatch(
    {
      result <- R.utils::withTimeout(sqlQuery(channel = db_conn, query = rendered_sql_query, ...), timeout = 4000)
      return(result)
    },
    error = function(cond){
      queryError <- cond
      stop(cond)
    }, finally = {
      if (disconnect){
        RODBC::odbcClose(db_conn)
      }
    }
  )
}

renderSqlText <- function(query_text, render=T){
  query_text <- paste("SET NOCOUNT ON;", query_text, sep="\r\n")
  if (render){
    query_text <- SqlRender::render(sql = query_text,
                                    warnOnMissingParameters = FALSE,
                                    ALERT = ALERT,
                                    ASSET_DELIVERY = ASSET_DELIVERY,
                                    CENSUS_DEMOG = CENSUS_DEMOG,
                                    CENSUS_LOCATION = CENSUS_LOCATION,
                                    COST = COST,
                                    CURRICULUM_COMPONENT = CURRICULUM_COMPONENT,
                                    DEMOGRAPHIC = DEMOGRAPHIC,
                                    DIAGNOSIS = DIAGNOSIS,
                                    ENCOUNTER = ENCOUNTER,
                                    FAMILY_HISTORY = FAMILY_HISTORY,
                                    IDENTIFIER = IDENTIFIER,
                                    IDENTITY_HASH_BUNDLE = IDENTITY_HASH_BUNDLE,
                                    LAB_RESULT_CM = LAB_RESULT_CM,
                                    LINK = LINK,
                                    PRESCRIBING = PRESCRIBING,
                                    PROCEDURES = PROCEDURES,
                                    PROGRAM = PROGRAM,
                                    PROVIDER = PROVIDER,
                                    REFERRAL = REFERRAL,
                                    SESSION = SESSION,
                                    SESSION_ALERT = SESSION_ALERT,
                                    VITAL = VITAL)
  }
  return(query_text)
}

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

sqlResult <- sqlQuery(conn, "SELECT * FROM #study_cohort_demographic")

dbDisconnect(conn)

write.csv(x = sqlResult, 
          file = paste("study_cohort_demographic_", PartnerID ,sep=''), 
          row.names = F, 
          quote = T, 
          sep = ",")

