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
  db_conn <- DBI::dbConnect(odbc::odbc(), "SQL Server", .connection_string = connection_string)
  return(db_conn)
}

run_db_query <- function(db_conn = NULL, query_text = NULL, renderSql = T, sql_location = NULL, ...) {
  if (is.null(query_text) && is.null(sql_location)) {
    stop("No query argument or file location was passed to function")
  }
  if(is.null(query_text) && !is.null(sql_location)){
    print(paste0("Reading Sql From ", sql_location))
    query_text = readSql(here(sql_location))
  }
  
  rendered_sql_query <- renderSqlText(query_text = query_text, render = renderSql)
  
  sqlResult <- R.utils::withTimeout(
    tryCatch({
      if (!is.null(db_conn)){
        lowSqlResult <- DBI::dbGetQuery(conn = db_conn, statement = rendered_sql_query, immediate = TRUE)
        return(lowSqlResult)
      }
    }, catch = function(err){
        stop(err)
    }), onTimeout = 'error', timeout = 2100)
  return(sqlResult)
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
                                    SCHEMA = SCHEMA,
                                    PERSON_ID_PATID = PERSON_ID_PATID,
                                    BENEFIT = BENEFIT)
  }
  return(query_text)
}

checkJava <- function(downloadDirectory){
  #checks if rJava can be loaded
  javaInstalled <- try(suppressWarnings(library("rJava")), silent=TRUE)
  if(inherits(javaInstalled, "try-error")){
    if(Sys.info()[["machine"]] =="x86"){
      stop("64 bit Java 1.8 or greater is not installed.  Contact your IT department to install the Java runtime environment")
    }
    if (file.exists(file.path(downloadDirectory, "java_runtime", "bin", "java.exe"))){
      Sys.setenv("JAVA_HOME"=file.path(downloadDirectory, "java_runtime"))
      javaInstalled <- try(suppressWarnings(library("rJava")), silent=TRUE)
      if(inherits(javaInstalled, "try-error")){
        stop("64 bit Java 1.8 or greater is not installed.  Contact your IT department to install the Java runtime environment")
      }
    } else {
      download.file("https://github.com/ACCORDSD2VDEV/CODI_HELPER_FILES/raw/main/java-runtime.zip", file.path(downloadDirectory,"java-runtime.zip"))
      unzip(zipfile = "java-runtime.zip", overwrite = T, exdir = "java_runtime")
      Sys.setenv("JAVA_HOME"=file.path(downloadDirectory, "java_runtime"))
      unlink("java-runtime.zip")
    }
  }
}
