getConnectionString <- function(){
  
  connectionString <- "Driver={Sql Server};"
  
  if(ServerName == "" || DatabaseName == ""){
    stop("Server name or database name is empty.  Check the Setup.r file")
  }
  
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
  #db_conn <- DBI::dbConnect(odbc::odbc(), "SQL Server", .connection_string = connection_string )
  db_conn <- RODBC::odbcDriverConnect(connection = connection_string, rows_at_time = 1)
  return(db_conn)
}

run_db_query <- function(db_conn = NULL, query_text = NULL, renderSql = T, ...) {
  if (is.null(query_text)) {
    stop("No query argument was passed to function")
  }
  
  rendered_sql_query <- renderSqlText(query_text = query_text, render = renderSql )
  
  result <- R.utils::withTimeout(
    tryCatch({
      result <- RODBC::sqlQuery(channel = db_conn, query = rendered_sql_query, errors = F)
      return(result)
    }, error = function(cond) {
      stop(error)
    }, finally = {
      if (result == -1L){
        error <- RODBC::odbcGetErrMsg(db_conn)
        stop(error)
        RODBC::odbcClearError(db_conn)
      }
    }), onTimeout = 'error', timeout = 2100)
  return(result)
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
                                    DEMOGRAPHICS = DEMOGRAPHICS,
                                    DIAGNOSES = DIAGNOSES,
                                    ENCOUNTERS = ENCOUNTERS,
                                    FAMILY_HISTORY = FAMILY_HISTORY,
                                    IDENTIFIER = IDENTIFIER,
                                    IDENTITY_HASH_BUNDLE = IDENTITY_HASH_BUNDLE,
                                    LAB_RESULTS = LAB_RESULTS,
                                    LINK = LINK,
                                    PRESCRIBING = PRESCRIBING,
                                    PROCEDURES = PROCEDURES,
                                    PROGRAM = PROGRAM,
                                    PROVIDER_SPECIALTY = PROVIDER_SPECIALTY,
                                    REFERRAL = REFERRAL,
                                    SESSION = SESSION,
                                    SESSION_ALERT = SESSION_ALERT,
                                    VITAL_SIGNS = VITAL_SIGNS,
                                    SCHEMA = SCHEMA)
  }
  return(query_text)
}