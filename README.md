# Update of the GBC Biodata Inventory

### Purpose: Repeat the 2022 GBC Biodata Inventory 

* The GBC Biodata Inventory conducted in 2022 queried articles published in Europe PMC between 2011 and 2021 and used BERT-based methods to classify articles and extract predicted resource names. The pipeline was created with the expectation that the inventory would be updated in future years. 

### Result: 661 New Resources Identified

* The ML pipeline was rerun for years 2022 and 2023 and found 661 new biodata resources were found. This is in addition to the 3112 resources found in the 2022 inventory.

### Analysis: 

* Started with original repo: https://github.com/globalbiodata/inventory_2022
  * Repeated ML pipeline via updating_inventory.ipyn for publication years 2022 and 2023
  * Manually reviewed flagged results and completed post-processing pipeline

* Analyzed countries for 661 new resources via:
  * Author affiliation
  * URL geocoordinates
  * Both known to be tricky; augmented with additional packages/scripts for better coverage
    * as is: new_biodata_resources_2024_unaugmented.csv
    * with additional coverage: new_biodata_resources_2024_augmented.csv
      * Notes on debatable decisions: 
        1) Augmenting means that provision of input files and scripts allows for reproducibility but scripts will not be generalizable for future updates! Data and code must be reviewed/edited to ensure new countries are not missed, etc.
        2) Additionally, there are geopolitical conundrums, e.g., Hong Kong left separate from Chin, but Guadeloupe combined with France
      * Plotted maps (jpegs) using new_biodata_resources_2024_augmented.csv
  
* To do: Analyze updated metadata for 3112 resources identified in 2022 inventory:
  * e.g., changes in citations and URL status
