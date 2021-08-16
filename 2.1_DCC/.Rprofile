rMjrVersion <- version[['major']]
cat(paste0("R version ",rMjrVersion, " detected\n"))
Sys.setenv(RENV_PROFILE = paste0("R", rMjrVersion, sep=''))
options(pkgType="win.binary")
options(install.packages.check.source = "no")
options(install.packages.compile.from.source = "never")
options(install.opts = c("--no-multiarch, --no-lock"))
source("renv/activate.R")
