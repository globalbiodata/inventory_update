## STEP 1 - Pre-Check Manually Reviewed Values
## Purpose: Check that all flagged IDs have been reviewed with appropriate values
## Package(s): tidyverse
## Input file(s): [NAME OF FILE].csv (e.g., predictions_v6.csv)
## Output file(s): predictions.csv

library(tidyverse)

p_mr <- read.csv("predictions_v6.csv")

## check counts (optional)

l <- p_mr %>% count(low_prob)
lr <- p_mr %>% count(review_low_prob)

n <- p_mr %>% count(duplicate_names)
nr <- p_mr %>% count(review_dup_names)

u <- p_mr %>% count(duplicate_urls)
ur <- p_mr %>% count(review_dup_urls)

## check cell values

checks <- p_mr %>%
  group_by(ID) %>%
  mutate(check_prob = ifelse(test = (low_prob != "low_prob_best_name" & (str_length(review_low_prob)<1)), 
    yes = "pass",
    no = ifelse(test = (low_prob == "low_prob_best_name" & (review_low_prob == "remove" | review_low_prob == "do not remove")),
      yes = "pass",
      no = "fail"))) %>%
      mutate(check_names = ifelse(test = ((str_length(duplicate_names)<1) & (str_length(review_dup_names)<1)), 
        yes = "pass",
        no = ifelse(test = ((str_length(duplicate_names)>1) & (review_dup_names == "conflicting record(s) to be removed" | review_dup_names == "do not merge" | review_dup_names == "merge all \"dup name\" IDs")),
          yes = "pass",
          no = ifelse(test = ((str_length(duplicate_names)>1) & (review_dup_names == "merge only:") & (str_length(review_notes_dup_names)>1)),
            yes = "pass",
            no = "fail")))) %>%
              mutate(check_urls = ifelse(test = ((str_length(duplicate_urls)<1) & (str_length(review_dup_urls)<1)), 
                yes = "pass",
                no = ifelse(test = ((str_length(duplicate_urls)>1) & (review_dup_urls == "conflicting record(s) to be removed" | review_dup_urls == "do not merge" | review_dup_urls == "merge on record with best name prob")),
                  yes = "pass",
                  no = "fail")))
  
## check for failures

failed_urls <- filter(checks, check_urls == "fail")
failed_names <- filter(checks, check_names == "fail")
failed_low_pro  <- filter(checks, check_prob == "fail")

## if any checks fail, correct in Excel, save CSV, and test again
## once passes all checks, do not save file with new columns, but do save original file via R to prevent other Apple OS/Excel formatting quirks that may throw errors
## place in My Drive/github/inventory_2022/out/new_query/manually_reviewed for downstream post-review processing

write.csv(p_mr, "predictions_v6c.csv", row.names = FALSE)

## FOR DEBUGGING
## if need to add empty url columns 

p_mr[ , 'extracted_url_status'] = NA
p_mr[ , 'extracted_url_country'] = NA
p_mr[ , 'extracted_url_coordinates'] = NA
p_mr[ , 'wayback_url'] = NA
