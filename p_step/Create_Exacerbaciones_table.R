# Author: Alejandro Santos Mejías
# Date last update: 2026-03-18
# Script name: Create_N_Exacerbations_table.R
# Aims: To create N_EXACERBATIONS table, the table contains number of 
# COPD exacerbations in each event date


rm(list = ls())
gc()

source("98_packages.R")

cols <- c("record_id", "redcap_event_name", "exacerbaciones_check_date", paste0("exac_date_", 1:51))
exacerbations <- append_file(directory = path_data, pattern = "^REDCAP_Epichron.*\\.csv", label = NULL, sep = ",", select = cols)
setnames(exacerbations, c("record_id", "redcap_event_name", "exacerbaciones_check_date"), c("id_redcap", "event_name", "event_end_date"))

# Fix and amend
fixBlankSpaces(exacerbations)
idToInclude <- fread(paste0(path_output, "PATIENTS.csv"), encoding = "UTF-8", select = "id_redcap")[, id_redcap]
exacerbations <- exacerbations[id_redcap %in% idToInclude]

# Set up range of date for each event
exacerbations[, event_name := factor(event_name, levels = c("basal_arm_1", "ao_1_arm_1", "ao_2_arm_1", "ao_3_arm_1", "ao_4_arm_1", "ao_5_arm_1"))]
exacerbations[, event_end_date := ymd(event_end_date)]
exacerbations[, event_start_date := shift(event_end_date, type = "lag"), by = c("id_redcap", "event_name")]
exacerbations[is.na(event_start_date) & event_name == "basal_arm_1", event_start_date := ymd("2022-12-01")]

suppressWarnings(exacerbations <- melt.data.table(data = exacerbations, measure.vars = grep("^exac_date", cols, value = T), variable.name = "order",value.name = "date_of_exacerbations"))
exacerbations <- exacerbations[!is.na(date_of_exacerbations)]

fixFechas(exacerbations, cols = "date_of_exacerbations")
setorder(exacerbations, id_redcap, date_of_exacerbations)

exacerbations[, order := as.integer(order)][, order := seq_len(.N), by = c("id_redcap", "event_name")]

fwrite(exacerbations[, .(id_redcap, event_name, event_start_date, event_end_date, order, date_of_exacerbations)], file = paste0(path_output, "EXACERBATIONS.csv"), encoding = "UTF-8")
