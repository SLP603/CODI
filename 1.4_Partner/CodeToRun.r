if (Sys.getenv("RENV_PROFILE") == ''){
  rMjrVersion <- version[['major']]
  cat(paste0("R version ",rMjrVersion, " detected\n"))
  Sys.setenv(RENV_PROFILE = paste0("R", rMjrVersion, sep=''))
  options(pkgType="win.binary")
  options(install.packages.check.source = "no")
  options(install.packages.compile.from.source = "never")
  source("renv/activate.R")
}

renv::restore()
library("here")

options(scipen=999)

source(here("Setup.r"))
source(here("R", "functions.r"))

if (DATAMODEL == "CHORDSVDW") {
  sqlType <- "CHORDSVDW"
} else if (DATAMODEL == "CODIVDW"){
  sqlType <- "CODIVDW"
} else {
  stop("DATAMODEL not found or missing.  Check the DATAMODEL variable in Setup.r")
}

if(!exists("CODISTEP")){
  stop("No step is set.  Check you Setup.r file")
} else{
  CODISTEP <- as.numeric(CODISTEP)
}

baseDir <- here()

if(CODISTEP == 1) {
  
  source(here("R", "Step1.r"))
  
} else if(CODISTEP == 3) {
  
  source(here("R", "Step3.r"))
  
} else {
  
  stop("No valid step was set.  Check you Setup.r file")
  
}