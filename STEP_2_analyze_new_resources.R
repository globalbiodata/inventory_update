## STEP 2 - Analyze Updated Inventory
## Purpose: 
## Package(s): tidyverse, countrycode, maps, ggplot2, ggmap
## Input file(s): predictions_final_2024-07-12.csv, final_inventory_2022.csv; scripts based on those written by Ken Schackart at https://github.com/globalbiodata/inventory_2022/blob/main/analysis/location_information.R
## Output file(s): url_countries_new_resources_2024.jpeg, 

library(tidyverse)
library(countrycode)
library(maps)
library(ggplot2)
library(ggmap)

i <- read.csv("final_inventory_2022.csv")
ui <- read.csv("predictions_final_2024-07-12.csv")

##==================================================##
######### PART 1: Isolate Newly ID'd Resources ####### 
##==================================================##

## Changes in the IDs (e.g., for those with new publications in 2022/23), URL status, and metadata retrieved from Europe PMC (e.g., citation counts) prevents filtering by an anti_join. Additionally, filtering by just publication date returns resources from the 2022 inventory which have had another paper published in 2022 or 2023 since publication_date lists the newest. So, to find those new to this 2024 inventory update, select just best_name, ID, and publication date to match on best_name, then double check dates.

i2 <- select(i, 1, 14, 2)
i2$publication_date <- as.Date(i2$publication_date) 
ui2 <- select(ui, 1, 14, 2)
ui2$publication_date <- as.Date(ui2$publication_date) 

new <- anti_join(ui2, i2, by = "best_name") 
## two 2022 resources have slightly different names because of the removal of special characters
new <- filter(new, publication_date > "2021-12-31") 
## join back up with remainder of metadata for newly ID'd resources 
new <- left_join(new, ui, by = "ID", suffix=c("",".y"))
new <- select(new, -ends_with(".y"))

## already know via strict matching that they are different; use fuzzy match of best_names as another check,if desired

# ntest <- select(new, 3)
# itest <- select(i, 2)
# 
# fuzzy <- ntest %>%
#   stringdist_join(
#     select(itest, best_name),
#     by = 'best_name',
#     mode = 'inner',
#     method = 'lv',
#     max_dist = 1,
#     ignore_case = TRUE,
#     distance_col = 'distance')

write.csv(new, "new_biodata_resources_2024.csv", row.names = FALSE)

##==============================================================##
######### PART 2: Augment Country from Author Affiliations ####### 
##==============================================================##

## 66 rows empty for author affiliation_countries (~10%); attempt to extract additional countries from affiliation using another package

## patterns to detect
all_country <- countrycode::countryname_dict %>% 
  filter(grepl('[A-Za-z]', country.name.alt)) %>%
  pull(country.name.alt) 
## above still does not catch UK, Iran, or just "Korea" (?!) - add manually
all_country <- c(all_country, "UK", "Iran", "Korea")
pattern <- str_c(all_country, collapse = '|')

## don't want to replace those found via the pipeline, so filter to just those with missing affiliations and string detect

missing <- filter(new, new$affiliation_countries == "")

missing <- missing %>% 
  mutate(affiliation_countries = str_extract_all((affiliation), pattern)) %>%
  unnest(affiliation_countries, keep_empty = TRUE)

## clean up values

missing$affiliation_countries[missing$affiliation_countries == "Russi"] <- "Russia"
missing$affiliation_countries[missing$affiliation_countries == "Masar"] <- "Czech Republic"
missing$affiliation_countries[missing$affiliation_countries == "Norwi"] <- "United Kingdom"
missing$affiliation_countries[missing$affiliation_countries == "Republic of Korea"] <- "South Korea"

## concatenate and dedup

missing <- missing %>% 
  group_by(ID) %>% 
    mutate(affiliation_countries = paste(affiliation_countries, collapse=", "))
missing <- unique(missing)
missing$affiliation_countries[missing$affiliation_countries == "NA"] <- NA

## recombine with rest of update

new2 <- left_join(new, missing, by = "ID", suffix = c(".new", ".y"))
new2$corrected_affiliation_countries <- coalesce(new2$affiliation_countries.y, new2$affiliation_countries.new)
new3 <- new2 %>% select(-ends_with(".y"))
new4 <- select(new3,-20) ## remove original affiliation_countries column 
names(new4) <- names(new4) %>% gsub(".new", "", .) 
new <- new4
new$corrected_affiliation_countries[new$corrected_affiliation_countries == ""] <- NA

new <- new %>%
  mutate(corrected_affiliation_countries = strsplit(corrected_affiliation_countries, ", ")) %>%
  unnest(corrected_affiliation_countries) %>%
  group_by(corrected_affiliation_countries) 

## clean up combined 

new$corrected_affiliation_countries[new$corrected_affiliation_countries == "UK"] <- "United Kingdom"
new$corrected_affiliation_countries[new$corrected_affiliation_countries == "Czechia"] <- "Czech Republic"
new$corrected_affiliation_countries[new$corrected_affiliation_countries == "Guadeloupe"] <- "France"
new$corrected_affiliation_countries[new$corrected_affiliation_countries == "Korea"] <- "South Korea"
new$corrected_affiliation_countries[new$corrected_affiliation_countries == "Jersey"] <- "USA"

new <- ungroup(new)

##===============================================================##
######### PART 3: Augment Country from URL Geo-coordinates  ####### 
##===============================================================##

## lat/long revered for some geocoordinates

muc <-filter(new, new$extracted_url_country == "")
muc <-filter(muc, muc$extracted_url_coordinates != "")
muc <- select(muc, 1, 10, 11, 12, 13)
## remove errant "," at starts
muc$extracted_url_coordinates <- sub("^[^\\(]+", "", muc$extracted_url_coordinates)
muc <- muc %>% mutate_all(na_if,"")
## filter again
muc <-filter(muc, muc$extracted_url_coordinates != "")
muc <- separate(data = muc, col = extracted_url_coordinates, into = c("left", "right", "left2", "right2"), sep = ",")
muc <- select(muc, -"left2", -"right2") ## just doing first url
muc$left = as.character(gsub("\\(", "", muc$left))
muc$right = as.character(gsub("\\)", "", muc$right))
# muc$left2 = as.character(gsub(" \\(", "", muc$left2)) ## if doing second
# muc$right2 = as.character(gsub("\\)", "", muc$right2))
muc <- muc %>% mutate(across(where(is.character), str_trim))

t  <- NULL;
for (i in seq_along(muc)) {
  ID <- muc$ID
  org_left <- muc$left  
  org_right <- muc$right
  extracted_url_country <- map.where(database="world", org_right, org_left)
  report <- cbind(ID, org_left, org_right, extracted_url_country)
  t <- rbind(t, report)
  t <- unique(t)
}
t <- as.data.frame(t)
t$extracted_url_country = as.character(gsub(":.*", "", t$extracted_url_country))

## recombine with rest of update
new6 <- left_join(new, t, by = "ID", suffix = c(".new", ".y"))
new6$corrected_extracted_url_country <- coalesce(new6$extracted_url_country.y, new6$extracted_url_country.new)
new6$corrected_extracted_url_country[new6$corrected_extracted_url_country == ""] <- NA
new7 <- new6 %>% select(-ends_with(".y"))
new8 <- select(new7,1:11, 13, 23, 14:20)
new <- new8

##==================================================##
######### PART 4: Analyze Newly ID'd Resources ####### 
##==================================================##

## get location columns

nlocations <- new %>%
  select(corrected_extracted_url_country,
    extracted_url_coordinates,
    corrected_affiliation_countries)

## Author affiliations 

author_country_counts <- nlocations %>%
  select(corrected_affiliation_countries) %>%
  rename(country = corrected_affiliation_countries) %>%
  na.omit()

author_country_counts <- author_country_counts %>%
  mutate(
    country = case_when(
      country == "United States" ~ "USA",
      country == "United Kingdom" ~ "UK",
      country == "Korea" ~ "South Korea",
      country == "Russian Federation" ~ "Russia",
      country == "Czechia" ~ "Czech Republic",
      T ~ country
    ))

author_country_counts  <- author_country_counts %>%
  group_by(country) %>%
  summarize(count = n())

author_countries_joined <-
  left_join(map_data("world"),
    author_country_counts,
    by = c("region" = "country"))

author_plot <- ggplot() +
  geom_polygon(data = author_countries_joined, aes(
    x = long,
    y = lat,
    fill = count,
    group = group
  )) +
  theme_void() +
  labs(fill = "Count")

author_plot

## URLs

url_countries <- nlocations %>%
  select(corrected_extracted_url_country) %>%
  rename(country = corrected_extracted_url_country) %>%
  na.omit()

url_countries <- url_countries %>%
mutate(
  country = case_when(
    country == "United States" ~ "USA",
    country == "United Kingdom" ~ "UK",
    country == "Korea" ~ "South Korea",
    country == "Russian Federation" ~ "Russia",
    country == "Czechia" ~ "Czech Republic",
    T ~ country
  ))

url_countries <- url_countries %>%
  group_by(country) %>%
    summarize(count = n())

url_countries_joined <-
  left_join(map_data("world"), url_countries, by = c("region" = "country"))

url_country_plot <- ggplot() +
  geom_polygon(data = url_countries_joined, aes(
    x = long,
    y = lat,
    fill = count,
    group = group
  )) +
  theme_void() +
  labs(fill = "Count")

url_country_plot
