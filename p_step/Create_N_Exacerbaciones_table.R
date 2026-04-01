# Author: Alejandro Santos Mejías
# Date last update: 2026-03-18
# Script name: Create_N_Exacerbations_table.R
# Aims: To create N_EXACERBATIONS table, the table contains number of 
# COPD exacerbations in each event date


rm(list = ls())
gc()

source("98_packages.R")

survey_date <- append_file(directory = path_data, pattern = "^REDCAP_Epichron.*\\.csv", label = NULL, sep = ",")[, .(record_id, redcap_event_name, exacerbaciones_check_date, n_exacerbaciones)]

fixBlankSpaces(survey_date)
fixFechas(survey_date)
idToInclude <- fread(paste0(path_output, "PATIENTS.csv"), encoding = "UTF-8", select = "id_redcap")[, id_redcap]
survey_date <- survey_date[id_redcap %in% idToInclude]

# Prepare range of dates for each id and event
survey_date[, redcap_event_name := factor(redcap_event_name, levels = c("basal_arm_1", "ao_1_arm_1", "ao_2_arm_1", "ao_3_arm_1", "ao_4_arm_1", "ao_5_arm_1"))]
survey_date[, exacerbaciones_check_date := ymd(exacerbaciones_check_date)]
setorder(survey_date, record_id, redcap_event_name)
survey_date[, fecha_previa := shift(exacerbaciones_check_date, type = "lag"), by = record_id]
survey_date[is.na(fecha_previa), fecha_previa := ymd("2022-12-01")]
setnames(survey_date, "record_id", "id_redcap")

fwrite(survey_date, paste0(path_output, "N_EXACERBACIONES.csv"), encoding = "UTF-8")
