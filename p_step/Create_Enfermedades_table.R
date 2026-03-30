# Author: Alejandro Santos Mejías
# Date last update: 2026-03-30
# Script name: Create_Enfermedades_table.R
# Aims: To create Enfermedades table, the table contains information of 
# diagnosis of people recruited prior and during the study period
# 
# Comment: You must be connected to Y: (EpiChron's server) to access the dictionaries
# and mapping functions.

rm(list = ls())
gc()

# Load functions
source("98_packages.R")
source("Y:/BIBLIOGRAFIA Y DOCUMENTACIÓN/R_script_mapeo_ciap_cie9/mapping_ciap_bifap_cie9_v3.0.R")
# Dictionary path for CCS 1 level:
dic_ccs <- fread("Y:/BIBLIOGRAFIA Y DOCUMENTACIÓN/R_mapeo_cie9_ccs/ccs_icd9_dic.csv", encoding = "UTF-8")
dic_cci <- fread("Y:/BIBLIOGRAFIA Y DOCUMENTACIÓN/R_mapeo_cie9_ccs/cci2015.csv", encoding = "UTF-8")
dic_body_system <- fread("Y:/BIBLIOGRAFIA Y DOCUMENTACIÓN/R_mapeo_cie9_ccs/body_systems_cci.csv", encoding = "UTF-8")

# Load data:
enf <- append_file(directory = path_data, pattern = "^diagnosticos_ap.csv", label = NULL)

# Transform ICPC to ICD9:
enf_icd9 <- map_cie9(
  diagnosis = enf,
  patient_id = "id_redcap",
  diag_cd = "codigo_diagnostico",
  diag_st = "descriptor"
)
  
# Transform ICD9 to CCS
fixBlankSpaces(enf_icd9)
enf_icd9 <- enf_icd9[!is.na(CIE9)]
enf_icd9[, CIE9nodot := gsub("\\.", "", CIE9)]
# Fix wrong code 491 to 491.0
enf_icd9[CIE9nodot == 491, CIE9nodot := 4910]
enf_ccs <- merge(enf_icd9, dic_ccs, by.x = "CIE9nodot", by.y = "cie9_no_dot", all.x = T)
enf_cci <- merge(enf_ccs, dic_cci[, .(cie9_no_dot, chronic_bool, body_system)], by.x = "CIE9nodot", by.y = "cie9_no_dot", all.x = T)
enf_cci <- merge(enf_cci, dic_body_system, by = "body_system")
fwrite(enf_cci,paste0(path_tmp, "diagnosticos_ccs_cci.csv"), encoding = "UTF-8")

enf_cci <- enf_cci[, .(patient_id, fecha_diagnostico, ccs_epichron_code, ccs_label, CIE9, ETIQUETA_CIE9, chronic_bool, body_system, body_label)]
setnames(enf_cci, c("id_redcap", "date_of_disease", "ccs_code", "ccs_label", "icd9_code", "icd9_label", "chronic_bool", "body_system", "body_system_label"))
fwrite(enf_cci, paste0(path_output, "DISEASE.csv"), encoding = "UTF-8")
