# Author: Alejandro Santos Mejías
# Date last update: 2026-03-18
# Script name: Create_Visits_table.R
# Aims: To create Visits table, it contains number of visit to each health service


rm(list = ls())
gc()

source("98_packages.R")

# Redcap id
survey_id <- append_file(directory = path_data, pattern = "^REDCAP_Epichron.*\\.csv", label = NULL, sep = ",")[, record_id]
survey_date <- append_file(directory = path_data, pattern = "^REDCAP_Epichron.*\\.csv", label = NULL, sep = ",")[, .(record_id, redcap_event_name, exacerbaciones_check_date)]
# Prepare range of dates for each id and event
survey_date[, redcap_event_name := factor(redcap_event_name, levels = c("basal_arm_1", "ao_1_arm_1", "ao_2_arm_1", "ao_3_arm_1", "ao_4_arm_1", "ao_5_arm_1"))]
survey_date[, exacerbaciones_check_date := ymd(exacerbaciones_check_date)]
setorder(survey_date, record_id, redcap_event_name)
survey_date[, fecha_previa := shift(exacerbaciones_check_date, type = "lag"), by = record_id]
survey_date[is.na(fecha_previa), fecha_previa := ymd("2022-12-01")]
setnames(survey_date, "record_id", "id_redcap")

# Load health servicies
hosp <- append_file(directory = path_data, pattern = "^datos_cmbd.*\\.csv", label = NULL)
urg <- append_file(directory = path_data, pattern = "^datos_urgencias.*\\.csv",label = NULL)
ap <- append_file(directory = path_data, pattern = "^visitas_medicina_familia.*\\.csv", label = NULL)

lapply(list(hosp, urg, ap), fixBlankSpaces)
lapply(list(hosp, urg, ap), fixFechas)

# Ensure there is no extra patient
hosp <- hosp[id_redcap %in% survey_id]
urg <- urg[id_redcap %in% survey_id]
ap <- ap[id_redcap %in% survey_id]

# Fix empty dates if possible
hosp[is.na(fecha_ingreso), fecha_ingreso := fecha_alta]

# Calculate hospital visits
result <- hosp[survey_date,
               .(hospitalisation = .N, event_name = i.redcap_event_name),
               on = .(id_redcap, 
                      fecha_ingreso > fecha_previa, 
                      fecha_ingreso <= exacerbaciones_check_date), 
               by = .EACHI]

cols <- setdiff(colnames(result), "fecha_ingreso")
result <- result[, ..cols, with = F]

# Calculate primary care visits
tmp <- ap[survey_date,
          .(primary_care = .N, event_name = i.redcap_event_name),
          on = .(id_redcap, 
                 fecha_visita > fecha_previa, 
                 fecha_visita <= exacerbaciones_check_date), 
          by = .EACHI]


result <- result[tmp[, .(id_redcap, event_name, primary_care)], on = c("id_redcap", "event_name")]

# Calculate emergency room
tmp <- urg[survey_date,
          .(emergency_room = .N, event_name = i.redcap_event_name),
          on = .(id_redcap, 
                 fecha_llegada > fecha_previa, 
                 fecha_llegada <= exacerbaciones_check_date), 
          by = .EACHI]


result <- result[tmp[, .(id_redcap, event_name, emergency_room)], on = c("id_redcap", "event_name")]

# Collect starting and end date of each event 
setnames(survey_date, "redcap_event_name", "event_name")
result <- result[survey_date[, .(id_redcap, event_name, fecha_previa, exacerbaciones_check_date)], 
                 `:=`(event_start_date = i.fecha_previa,
                      event_end_date = i.exacerbaciones_check_date),
                 on = c("id_redcap", "event_name")]

result <- result[, .(id_redcap, event_name, event_start_date, event_end_date, primary_care, hospitalisation, emergency_room)]

fwrite(result, paste0(path_output, "VISITS.csv"), encoding = "UTF-8")
