# ==============================================================================
# Clean and combine comorbidity codelists for CPRD observation mapping
# Produces a single CSV with columns: code (SNOMED CT), disease
# ==============================================================================

library(tidyverse)

codelist_dir <- "./codelists/comorbidities"

# Helper: standardise any dataframe to (code, disease) format
standardise <- function(df, code_col, disease_label) {
  df %>%
    transmute(
      code = as.character({{ code_col }}),
      disease = disease_label
    ) %>%
    filter(!is.na(code), code != "")
}

# ==============================================================================
# LOAD AND CLEAN EACH CODELIST
# ==============================================================================

# --- Phenotype library format (column: code = SNOMED) ---
phenotype_files <- list(
  "Asthma"       = "asthma.csv",
  "Cancer"       = "cancer.csv",
  "COPD"         = "copd.csv",
  "Hypertension" = "htn.csv",
  "Obesity"      = "obesity.csv"
)

phenotype_codes <- map_dfr(names(phenotype_files), function(d) {
  read.csv(file.path(codelist_dir, phenotype_files[[d]]),
           stringsAsFactors = FALSE) %>%
    standardise(code, d)
})

# --- Simple format (columns: code, term) ---
simple_files <- list(
  "Type 1 Diabetes"         = "t1dm.csv",
  "Type 2 Diabetes"         = "t2dm.csv",
  "Congenital Heart Disease" = "congenital.csv"
)

simple_codes <- map_dfr(names(simple_files), function(d) {
  read.csv(file.path(codelist_dir, simple_files[[d]]),
           stringsAsFactors = FALSE) %>%
    standardise(code, d)
})

# --- snomedcode format (with # symbols to remove) ---
snomed_hash_files <- list(
  "Myocardial Infarction"   = "mi.csv",
  "Ischaemic Heart Disease" = "ihd.csv",
  "Heart Failure"           = "hf.csv",
  "Atrial Fibrillation"     = "atrialfibrillation.csv",
  "Rheumatoid Arthritis"    = "rheumatoid.csv"
)

snomed_hash_codes <- map_dfr(names(snomed_hash_files), function(d) {
  read.csv(file.path(codelist_dir, snomed_hash_files[[d]]),
           stringsAsFactors = FALSE) %>%
    mutate(snomedcode = gsub("#", "", as.character(snomedcode))) %>%
    standardise(snomedcode, d)
})

# --- CKD (tab-separated, uses snomedctconceptid) ---
ckd_codes <- read.table(file.path(codelist_dir, "ckd.txt"),
                        header = TRUE, sep = "\t",
                        stringsAsFactors = FALSE) %>%
  standardise(snomedctconceptid, "Chronic Kidney Disease")

# --- Smoking (split by smoking_status) ---
smoking_codes <- read.csv(file.path(codelist_dir, "smoking.csv"),
                          stringsAsFactors = FALSE) %>%
  transmute(
    code = as.character(snomedctconceptid),
    disease = case_when(
      smoking_status == "Current smoker" ~ "Current Smoker",
      smoking_status == "Ex-smoker"      ~ "Ex-smoker",
      smoking_status == "Never smoker"   ~ "Never Smoker",
      TRUE                               ~ "Smoking - Unknown"
    )
  ) %>%
  filter(!is.na(code), code != "")

# --- CPRD Aurum format (medcodeid + snomedctconceptid) ---
anxiety_codes <- read.csv(file.path(codelist_dir, "anxiety.csv"),
                          stringsAsFactors = FALSE) %>%
  standardise(snomedctconceptid, "Anxiety")

depression_codes <- read.csv(file.path(codelist_dir, "depression.csv"),
                             stringsAsFactors = FALSE) %>%
  standardise(snomedctconceptid, "Depression")

# ==============================================================================
# COMBINE AND DEDUPLICATE
# ==============================================================================

all_comorbidity_codes <- bind_rows(
  phenotype_codes,
  simple_codes,
  snomed_hash_codes,
  ckd_codes,
  smoking_codes,
  anxiety_codes,
  depression_codes
) %>%
  distinct(code, disease)

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("Total codes:", nrow(all_comorbidity_codes), "\n\n")

all_comorbidity_codes %>%
  count(disease) %>%
  arrange(desc(n)) %>%
  print()

cat("\nCodes with NA:", sum(is.na(all_comorbidity_codes$code)),
    "\nEmpty codes:",  sum(all_comorbidity_codes$code == ""), "\n")

# ==============================================================================
# SAVE
# ==============================================================================

write.csv(all_comorbidity_codes,
          file.path(codelist_dir, "all_comorbidity_codes.csv"),
          row.names = FALSE)
