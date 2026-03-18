# Author: Alejandro Santos Mejías
# Date last update: 2026-03-16
# Script name: 98_packages.R
# Aims: To load all dependencies, pathing and ad hoc functions
# 
##### PACKAGES
pkg <- c(
  # TODO use rev approach for package versions  
  # "renv", 
  "tidyverse",
  "arrow",
  "data.table",
  "lubridate"
)

lapply(pkg, function (x){if(!require(x, character.only = T)){install.packages(x , character.only = T)}})
rm(pkg)

# PATHING
source("99_path.R")

# FUNCTIONS 
functions <- list.files(path = path_funct, pattern = "\\.R$", full.names = TRUE, ignore.case = TRUE)
sapply(functions, source)




