# The purpose of this script is to download the FMCSA Census data


# SETUP -------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(glue)
library(arrow)
library(here)


# LOAD RAW ZIP FILES ------------------------------------------------------

# Initialize target date with last complete month
target_date <- Sys.Date() %>% floor_date(unit = "month") %m-% months(1)

# Set URL
url_root <- "https://ai.fmcsa.dot.gov/SMS/files/FMCSA_CENSUS1"
date_suffix <- glue("{year(target_date)}{month(target_date, label = T)}")
url_target <- glue("{url_root}_{date_suffix}.zip")

# Create a temporary folder
dir.create(here("data", "temp_fmcsa_census"), showWarnings = FALSE)

# Download the zip file
download.file(
  url = url_target,
  destfile = here("data", "temp_fmcsa_census", "fmcsa_census.zip")
)

# Unzip the folder
unzip(
  zipfile = here("data", "temp_fmcsa_census", "fmcsa_census.zip"),
  exdir = here("data", "temp_fmcsa_census")
)

# Convert CSV to Parquet
df_census <- read_csv(here("data", "temp_fmcsa_census", glue("FMCSA_CENSUS1_{date_suffix}.txt")))
write_parquet(df_census, here("data", "raw", "fmcsa_census.parquet"))

# Delete the temporary folder
unlink(here("data", "temp_fmcsa_census"), recursive = TRUE)

# SAVE DATA SAMPLE/SUMMARY -------------------------------------------------------

# Sample data
df_census_sample <- df_census %>% sample_n(1000)

# Write sample HTML table
df_census_sample %>%
  kableExtra::kbl() %>%
  kableExtra::kable_styling() %>%
  kableExtra::save_kable(file = here("docs", "data", "sample_fmcsa_census.html"))
  

# Create dataframe summary
st_summary <- summarytools::dfSummary(df_census_sample)
print(st_summary, file = here("docs", "data", "summary_fmcsa_census.html"))
