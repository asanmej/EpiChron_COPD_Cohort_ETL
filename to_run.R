# Author: Alejandro Santos Mejías
# Date last update: 2026-03-30
# Script name: to_run.R
# Aims: To run all ETL process.

rm(list = ls())
gc()

source("98_packages.R")

source(paste0(path_step, "Create_Patient_table.R"))

source(paste0(path_step, "Create_Visits_table.R"))

source(paste0(path_step, "Create_FFEV1_table.R"))

source(paste0(path_step, "Create_N_Exacerbaciones_table.R"))

source(paste0(path_step, "Create_Exacerbaciones_table.R"))

source(paste0(path_step, "Create_Enfermedades_table.R"))