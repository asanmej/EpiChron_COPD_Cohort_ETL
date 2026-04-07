# Author: Alejandro Santos Mejías
# Date last update: 2026-03-18
# Script name: Create_FEV1_table.R
# Aims: To create FFEV1 table, it contains the value of Forced expiratory volume in 1 second.
# It is used to diagnose pulmonary capacity, very useful in COPD


rm(list = ls())
gc()

source("98_packages.R")

ffev <- append_file(directory = path_data, pattern = "^FFEV.*\\.csv", label = NULL)

fixFechas(ffev)
idToInclude <- fread(paste0(path_output, "PATIENTS.csv"), encoding = "UTF-8", select = "id_redcap")[, id_redcap]
ffev <- ffev[id_redcap %in% idToInclude]

ffev[, codigo_dgp := NULL]
setnames(ffev, c("fecha", "valor"), c("date_of_ffev", "value"))

# TODO set date to YYYY-MM-DD format 

fwrite(ffev[, .(id_redcap, date_of_ffev, value)], file = paste0(path_output, "FEV1.csv"), encoding = "UTF-8")
