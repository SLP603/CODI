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

CODISTEP <- 2

options(scipen=999)

if(CODISTEP == 2) {
  
  source(here("R", "Step2.r"))
  
} else {
  
  stop("No valid step was set.  Check you Setup.r file")
  
}