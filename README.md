# GBC Biodata Inventory Update

### Purpose: Repeat Methods to Provide an Update of the GBC Biodata Inventory

* The GBC Biodata Inventory conducted in 2022 queried articles published in Europe PMC between 2011 and 2021 and used BERT-based methods to classify articles and extract predicted resource names. This update was done with the same methods, including trained models, to identify new biodata resources published in the literature in 2022 and 2023.

### Result: 661 New Resources Identified

* The pipeline was rerun for years 2022 and 2023, with 661 new biodata resources found. These are in addition to the 3112 resources found in the original 2022 inventory.

### Process:

* Started with original repo: https://github.com/globalbiodata/inventory_2022
  * Repeated ML pipeline using Google Colab via updating_inventory.ipyn
  * Manually reviewed flagged results
    * Some revisions were made, notably, removing strings of special characters that prevented the rest of the pipeline from running
    * Changes resulted in a V2 of the "Biodata Inventory Manual Review Process for Updates"
  * Completed post-processing pipeline

### Analysis: 
* Analyzed countries for 661 new resources via:
  * Author affiliation
  * URL geocoordinates
  * Both known to be tricky; augmented with additional packages/scripts for better coverage
    * as is: new_biodata_resources_2024_unaugmented.csv
    * with additional coverage: new_biodata_resources_2024_augmented.csv
      * Notes on debatable decisions: 
        1) Provision of input files and scripts allows for reproducibility but these scripts will not be generalizable for future updates! Data and code must be reviewed/edited for any future updates to ensure countries are not missed, etc.
        2) Geopolitical challenges should be reconsidered, e.g., Guadeloupe combined with France given it's status as a department/region; perhaps the same should be done for Hong Kong
      * Plotted maps (jpegs) using new_biodata_resources_2024_augmented.csv
  
* To do: 
  * Analyze updated metadata for 3112 resources identified in 2022 inventory, e.g., changes in citations and URL status
  * Other? Funders?
