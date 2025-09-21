sensor_file <- read.csv("./log/2025-09-12_sensing_soil.csv", header = FALSE)

colnames(sensor_file) <- c("Date", "Soil_Property", "Raw_Value", "Value")

sensor_file$day <- as.Date(sensor_file$Date)

library(tidyverse)
sensor_file_wide <- sensor_file %>%
  select(-Raw_Value) %>%
  group_by(day, Soil_Property) %>%
  mutate(row = row_number()) %>%
  summarise(mean = mean(Value)) %>%
  pivot_wider(names_from = c(Soil_Property), values_from = c(mean)) %>%
  ungroup()

cleaner_data <- sensor_file_wide %>%
  select(day, ec1, moi2, orp1, ph1, tm1)

colnames(cleaner_data) <-
  c("day", "Soil_EC", "Soil_Moisture", "Soil_orp", "Soil_pH", "Soil_Temp")

min_row <- data.frame(
  day = as.Date(c("0000-00-00"),  format = "%Y/%m/%d"),
  Soil_EC = 0,
  Soil_Moisture = 1.28,
  Soil_orp = -2029,
  Soil_pH = 3.76,
  Soil_Temp = 2.8
)

max_row <- data.frame(
  day = as.Date(c("9999-99-99"),  format = "%Y/%m/%d"),
  Soil_EC = 27085,
  Soil_Moisture = 180,
  Soil_orp = 10947,
  Soil_pH = 8,
  Soil_Temp = 29.4
)

pre_scaled_data <- rbind(cleaner_data, min_row, max_row)

library(caret)
preprocess_model <- preProcess(pre_scaled_data, method = c("range"))
scaled_data <- predict(preprocess_model, pre_scaled_data)

#Loading the Soil Property Model
soil_model <- readRDS("./soil_random_forest_model_74.rds")

library(ranger)
soil_predictions <- predict(soil_model, scaled_data)

scaled_data$SOC_prediction <- soil_predictions$predictions
print(scaled_data, n = 10)
