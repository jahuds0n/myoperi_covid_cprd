# ==============================================================================
# STEP 1: LOAD AND INSPECT YOUR SNOMED CODE LISTS
# ==============================================================================

# Load required package
library(tidyverse)

# Original CSV files
asthma_codes <- read.csv("./comorbidities/code_lists/codelist_asthma.csv", stringsAsFactors = FALSE)
cancer_codes <- read.csv("./comorbidities/code_lists/codelist_cancer.csv", stringsAsFactors = FALSE)
copd_codes <- read.csv("./comorbidities/code_lists/codelist_copd.csv", stringsAsFactors = FALSE)
depression_codes <- read.csv("./comorbidities/code_lists/codelist_depression.csv", stringsAsFactors = FALSE)
htn_codes <- read.csv("./comorbidities/code_lists/codelist_htn.csv", stringsAsFactors = FALSE)
obesity_codes <- read.csv("./comorbidities/code_lists/codelist_obesity.csv", stringsAsFactors = FALSE)
t1dm_codes <- read.csv("./comorbidities/code_lists/codelist_t1dm.csv", stringsAsFactors = FALSE)
t2dm_codes <- read.csv("./comorbidities/code_lists/codelist_t2dm.csv", stringsAsFactors = FALSE)
congenital_codes <- read.csv("./comorbidities/code_lists/codelist_congenital.csv", stringsAsFactors = FALSE)
mi_codes <- read.csv("./comorbidities/code_lists/codelist_mi.csv", stringsAsFactors = FALSE)
ihd_codes <- read.csv("./comorbidities/code_lists/codelist_ihd.csv", stringsAsFactors = FALSE)
hf_codes <- read.csv("./comorbidities/code_lists/codelist_hf.csv", stringsAsFactors = FALSE)
af_codes <- read.csv("./comorbidities/code_lists/codelist_atrialfibrillation.csv", stringsAsFactors = FALSE)
smoking_codes <- read.csv("./comorbidities/code_lists/codelist_smoking.csv", stringsAsFactors = FALSE)
rheumatoid_codes <- read.csv("./comorbidities/code_lists/codelist_rheumatoid.csv", stringsAsFactors = FALSE)
ckd_codes <- read.table("./comorbidities/code_lists/codelist_ckd.txt", 
                        header = TRUE, 
                        sep = "\t", 
                        stringsAsFactors = FALSE)

semi_codes <- read.table("./comorbidities/code_lists/codelist_smi.txt", 
                         header = TRUE, 
                         sep = "\t", 
                         stringsAsFactors = FALSE)
# Myocarditis/Pericarditis
#mpc_codes <- read.table("./comorbidities/code_lists/codelist_mpc.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# ==============================================================================
# STEP 2: STANDARDIZE ALL CODE LISTS TO SAME FORMAT
# ==============================================================================
# ------------------------------------------------------------------------------
# GROUP 1: Already good format - just select needed columns
# ------------------------------------------------------------------------------
asthma_clean <- asthma_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "Asthma",
         code = as.character(code))

cancer_clean <- cancer_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "Cancer",
         code = as.character(code))

copd_clean <- copd_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "COPD",
         code = as.character(code))

depression_clean <- depression_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "Depression",
         code = as.character(code))

htn_clean <- htn_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "Hypertension",
         code = as.character(code))

obesity_clean <- obesity_codes %>%
  select(code, disease = phenotype_name) %>%
  mutate(disease = "Obesity",
         code = as.character(code))

#mpc_clean <- mpc_codes %>%
# mutate(
#  code = as.character(SnomedCTConceptId),
# disease = "Myocarditis/Pericarditis"
#) %>%
#select(code, disease) %>%
#filter(!is.na(code), code != "")

# ------------------------------------------------------------------------------
# GROUP 2: Simple format - just rename columns
# ------------------------------------------------------------------------------

t1dm_clean <- t1dm_codes %>%
  select(code, term) %>%
  mutate(disease = "Type 1 Diabetes",
         code = as.character(code)) %>%
  select(code, disease)

t2dm_clean <- t2dm_codes %>%
  select(code, term) %>%
  mutate(disease = "Type 2 Diabetes",
         code = as.character(code)) %>%
  select(code, disease)


congenital_clean <- congenital_codes %>%
  select(code, term) %>%
  mutate(disease = "Congenital Heart Disease",
         code = as.character(code)) %>%
  select(code, disease)

smoking_clean <- smoking_codes %>%
  select(code = snomedctconceptid, term, smoking_status) %>%  # Keep smoking_status!
  mutate(
    code = as.character(code),
    # Create disease name with category
    disease = case_when(
      smoking_status == "Current smoker" ~ "Current Smoker",
      smoking_status == "Ex-smoker" ~ "Ex-smoker",
      smoking_status == "Never smoker" ~ "Never Smoker",
      TRUE ~ "Smoking - Unknown"  # Catch any unexpected categories
    )
  ) %>%
  select(code, disease)


# ------------------------------------------------------------------------------
# GROUP 4: NEW Complex CSV files with MedCodeId - need to remove "#" symbols
# ------------------------------------------------------------------------------
mi_clean <- mi_codes %>%
  mutate(
    code = as.character(snomedcode),
    code = gsub("#", "", code),  # Remove the "#" symbols
    disease = "Myocardial Infarction"
  ) %>%
  select(code, disease)

ihd_clean <- ihd_codes %>%
  mutate(
    code = as.character(snomedcode),
    code = gsub("#", "", code),  # Remove the "#" symbols
    disease = "Ischaemic Heart Disease"
  ) %>%
  select(code, disease)

hf_clean <- hf_codes %>%
  mutate(
    code = as.character(snomedcode),
    code = gsub("#", "", code),  # Remove the "#" symbols
    disease = "Heart Failure"
  ) %>%
  select(code, disease)

af_clean <- af_codes %>%
  mutate(
    code = as.character(snomedcode),
    code = gsub("#", "", code),  # Remove the "#" symbols
    disease = "Atrial Fibrillation"
  ) %>%
  select(code, disease)

rheumatoid_clean <- rheumatoid_codes %>%
  mutate(
    code = as.character(snomedcode),
    code = gsub("#", "", code),  # Remove the "#" symbols
    disease = "Rheumatoid Arthritis"
  ) %>%
  select(code, disease)

# ------------------------------------------------------------------------------
# COMBINE ALL CODE LISTS
# ------------------------------------------------------------------------------

all_comorbidity_codes <- bind_rows(
  # Original comorbidities
  asthma_clean,
  cancer_clean,
  copd_clean,
  depression_clean,
  htn_clean,
  obesity_clean,
  t1dm_clean,
  t2dm_clean,
  ckd_clean,
  semi_clean,
  congenital_clean,
  smoking_clean,
  rheumatoid_clean,
  mi_clean,
  ihd_clean,
  hf_clean,
  af_clean,
  #mpc_clean
)

# Remove any duplicates (same code appearing in multiple disease lists)
all_comorbidity_codes <- all_comorbidity_codes %>%
  distinct(code, disease, .keep_all = TRUE)
# Summary
print(paste("Total codes:", nrow(all_comorbidity_codes)))
disease_summary <- all_comorbidity_codes %>% 
  count(disease) %>% 
  arrange(desc(n))
print(disease_summary)

# Check for any missing or invalid codes
print("\nChecking for issues:")
print(paste("Codes with NA:", sum(is.na(all_comorbidity_codes$code))))
print(paste("Empty codes:", sum(all_comorbidity_codes$code == "")))


# ------------------------------------------------------------------------------
# SAVE THE FINAL COMBINED CODE LIST
# ------------------------------------------------------------------------------

write.csv(all_comorbidity_codes, 
          "./comorbidities/code_lists/all_comorbidity_codes.csv", 
          row.names = FALSE)