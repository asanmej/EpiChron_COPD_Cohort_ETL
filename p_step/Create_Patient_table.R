# Author: Alejandro Santos Mejías
# Date last update: 2026-03-17
# Script name: Create_Patient_table.R
# Aims: To create Sociodemografico table, the table contains information of 
# sociodemografic variables of people recruited at baseline


rm(list = ls())
gc()

source("98_packages.R")

# First extraction: 20260223
# Data from BDU
bdu <- append_file(directory = path_data, pattern = "^demograficos.*\\.csv$")
# Data from the RedCap survey
survey <- append_file(directory = path_data, pattern = "^REDCAP.*\\.csv$", sep = ",", label = NULL)
# survey[, date_sociodemographic]
# Data from diagnosis EHR
copd <- append_file(directory = path_data, pattern = "^diagnosticos_EPOC\\.csv$", label = NULL)

# Fix blank spaces
lapply(list(bdu, survey, copd), fixBlankSpaces)

# Id not present in both dataset, ignore for the moment
survey <- survey[record_id %in% bdu$id_redcap]
bdu <- bdu[id_redcap %in% survey$record_id]

# Keep first not empty value, it is not very well made
# TODO improve
# Merge to survey to check duplicated info
bdu_enriched <- merge(bdu, survey[, .(record_id, date_sociodemographic)], by.x = "id_redcap", by.y = "record_id")
cols <- colnames(bdu)[-which(colnames(bdu) %in% c("label_file"))]
bdu_enriched <- unique(bdu_enriched, by = cols)[order(as.numeric(id_redcap))]
fixBlankSpaces(bdu_enriched)
bdu_enriched[, date_sociodemographic := year(as.Date(date_sociodemographic))]

# Create base data.table
patient <- data.table( 
  id_redcap = unique(survey[, record_id])
)

# Reorder only with variable needed 
bdu_enriched <- bdu_enriched[, .(id_redcap, sexo, anyo_nac, fecha_fallecimiento, pais_nacimiento, nacionalidad, tsi)]
cols <- setdiff(names(bdu_enriched), "id_redcap")
# Next Observation carried backward imputation
bdu_enriched[, (cols) := lapply(.SD, function(x){zoo::na.locf(x, na.rm = F, fromLast = T)}), .SDcols = cols, by = id_redcap]
bdu_clean <- unique(bdu_enriched, by = "id_redcap")

patient[bdu_clean,
        c("sex", 
          "year_of_birth", 
          "date_of_death", 
          "country_of_birth", 
          "nationality", 
          "anual_income") := mget(paste0("i.", cols)),
        on = "id_redcap" 
        ]

# Select variables needed for PATIENTS table, check CODEBOOK for meaning
survey <- survey[, .(record_id, 
                     height, 
                     weight,
                     imc, 
                     money_1, 
                     loneliness_level, 
                     tsi_level, 
                     civil_status, 
                     smoking_status, 
                     smoking_status_partner, 
                     disnea_level, 
                     education_level, 
                     profession_level,
                     house_lift, 
                     house_temperature_status, 
                     house_meter, 
                     house_people, 
                     oss_result, 
                     private_hospital_visit, 
                     private_urgency_visit, 
                     date_sociodemographic
                     )]
setnames(survey, "record_id", "id_redcap")

# Merge and update variables by position, tsi_level has to have same name as anual_income
# TODO assign explicitly in the future
cols <- setdiff(names(survey), c("id_redcap"))
patient[survey,
        c("height", 
          "weight", 
          "bmi", 
          "money_issue_baseline", 
          "loneliness_issue_baseline", 
          "anual_income", 
          "marital_status", 
          "smoking_status", 
          "partner_smoking_status",
          "disnea_level", 
          "education_level",
          "job_level",
          "lift_status_household",
          "temperature_issue_household",
          "meter2_household",
          "n_household",
          "oslo_score",
          "private_hospital_visits",
          "private_emergency_visits",
          "date_start_followup") := mget(paste0("i.", cols)),
        on = "id_redcap" 
]

# Add COPD
patient[copd, c("date_of_copd") := i.fecha_diagnostico, on = "id_redcap"]

fwrite(patient , paste0(path_output, "PATIENTS.csv"))
