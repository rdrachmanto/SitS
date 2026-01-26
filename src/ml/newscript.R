suppressPackageStartupMessages({
  library(tidyverse)
  library(caret)
  library(ranger)
})

# ---------------------------
# Config
# ---------------------------
log_dir   <- "./logs"
model_rds <- "./soil_random_forest_model_74.rds"
outfile   <- "./daily_soil_predictions.csv"

sensing_ext <- "log"

# Yesterday in local timezone
yday <- Sys.Date() - 1
date_prefix <- format(yday, "%Y-%m-%d")

# Ensure output directory exists
dir.create(dirname(outfile), showWarnings = FALSE, recursive = TRUE)

# ---------------------------
# if yesterday already predicted, quit
# ---------------------------
if (file.exists(outfile)) {
  existing <- tryCatch(read.csv(outfile, stringsAsFactors = FALSE), error = function(e) NULL)

  if (!is.null(existing) && "day" %in% names(existing)) {
    existing$day <- as.Date(existing$day)
    if (any(existing$day == yday, na.rm = TRUE)) {
      message("Prediction for ", date_prefix, " already exists in ", outfile, " — skipping.")
      quit(status = 0)
    }
  }
}

# ---------------------------
# Find all sensor files for yesterday
# Example name: 2025-12-31_22:42:55_sensing_soil.log
# ---------------------------
pattern <- paste0("^", date_prefix, "_.*_sensing_soil\\.", sensing_ext, "$")

files <- list.files(
  path = log_dir,
  pattern = pattern,
  full.names = TRUE
)

if (length(files) == 0) {
  stop("No sensor files found for ", date_prefix, " in ", log_dir)
}

message("Found ", length(files), " file(s) for ", date_prefix)

# ---------------------------
# Read & combine all files (treat them as one table)
# ---------------------------
sensor_file <- files %>%
  set_names() %>%
  map_dfr(~ read.csv(.x, header = FALSE), .id = "source_file")

# Expecting: Date, Soil_Property, Raw_Value, Value
colnames(sensor_file) <- c("source_file", "Date", "Soil_Property", "Raw_Value", "Value")

# Parse day from datetime string
sensor_file$day <- as.Date(sensor_file$Date)

# Safety: keep only yesterday rows (in case a file crosses midnight)
sensor_file <- sensor_file %>% filter(day == yday)

if (nrow(sensor_file) == 0) {
  stop("After filtering to day==", date_prefix, ", no rows remain. Check your Date format.")
}

sensor_file_wide <- sensor_file %>%
  select(-source_file, -Raw_Value) %>%
  group_by(day, Soil_Property) %>%
  summarise(mean = mean(Value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Soil_Property, values_from = mean)

cleaner_data <- sensor_file_wide %>%
  select(day, ec2, orp2, ph1, tm1)  # Customize here

# Now that we have actual moisture data we can turn the simulation off
# cleaner_data <- cleaner_data %>%
#   mutate(Soil_Moisture = moi_default)

# This has to have the correct order based on cleaner_data select() fun
colnames(cleaner_data) <- c("day", "Soil_EC", "Soil_orp", "Soil_pH", "Soil_Temp", "Soil_Moisture")

if (nrow(cleaner_data) != 1) {
  warning("Expected 1 row for the day; got ", nrow(cleaner_data), ". Proceeding anyway.")
}

min_row <- data.frame(
  day = as.Date("1900-01-01"),
  Soil_EC = 0,
  Soil_Moisture = 1.28,
  Soil_orp = -2029,
  Soil_pH = 3.76,
  Soil_Temp = 2.8
)

max_row <- data.frame(
  day = as.Date("2100-01-01"),
  Soil_EC = 27085,
  Soil_Moisture = 180,
  Soil_orp = 10947,
  Soil_pH = 8,
  Soil_Temp = 29.4
)

pre_scaled_data <- bind_rows(cleaner_data, min_row, max_row)

preprocess_model <- preProcess(pre_scaled_data, method = c("range"))
scaled_data <- predict(preprocess_model, pre_scaled_data)

soil_model <- readRDS(model_rds)
soil_predictions <- predict(soil_model, scaled_data)

scaled_data$SOC_prediction <- soil_predictions$predictions

daily_prediction <- scaled_data %>%
  filter(day == yday) %>%
  select(day, SOC_prediction)

if (nrow(daily_prediction) != 1) {
  stop("Expected exactly 1 prediction row for ", date_prefix, " but got ", nrow(daily_prediction))
}

message("Daily prediction:")
print(daily_prediction)

write.table(
  daily_prediction,
  outfile,
  sep = ",",
  row.names = FALSE,
  col.names = !file.exists(outfile),
  append = file.exists(outfile)
)

message("Appended to: ", outfile)
