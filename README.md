# GBC Biodata Inventory Update

### Purpose: Repeat Methods to Provide an Update of the GBC Biodata Inventory

* The GBC Biodata Inventory conducted in 2022 queried articles published in Europe PMC between 2011 and 2021 and used BERT-based methods to classify articles and extract predicted resource names. This update was done with the same methods, including trained models, to identify new biodata resources published in the literature in 2022 and 2023.

### Result: 661 New Resources Identified

* The pipeline was rerun for years 2022 and 2023, with 661 new biodata resources found. These are in addition to the 3112 resources found in the original 2022 inventory.
  * file ***predictions_final_2024-07-12.CSV*** contain all resources, from 2011-2023
* *NOTE* - preliminary result; not yet verified

### Process:

* Started with original repo: https://github.com/globalbiodata/inventory_2022
  * Repeated ML pipeline using Google Colab via updating_inventory.ipyn
  * Manually reviewed flagged results
    * Some revisions were made, notably, removing strings of special characters that prevented the rest of the pipeline from running
    * Changes resulted in a V2 of the "Biodata Inventory Manual Review Process for Updates"
  * Completed post-processing pipeline

### Analysis: 
* Analyzed countries for 661 new resources via:
  * Author affiliation (total occurrences; may be >1 per article)
  * URL geocoordinates
  * Both known to be tricky; augmented with additional packages/scripts for better coverage
    * as is: new_biodata_resources_2024_unaugmented.csv
    * with additional coverage: new_biodata_resources_2024_augmented.csv
      * Top 5 Countries via Author Affiliations:
        * *China (373)* 
        * *USA (92)* 
        * *India (60)* 
        * *Canada (21)* 
        * *UK (20)* 
      * Top 5 Countries via URL Geocoordinates:
        * *China (141)* 
        * *USA (138)* 
        * *India (33)* 
        * *Germany (17)* 
        * *Canada (12)* 
      * Notes on augmentation 
        1) Provision of input files and scripts allows for reproducibility but these scripts will not be generalizable for future updates! Data and code must be reviewed/edited for any future updates to ensure countries are not missed, etc.
      * Plotted maps (jpegs) using new_biodata_resources_2024_augmented.csv
  
* To do: 
  * Analyze updated metadata for 3112 resources identified in 2022 inventory, e.g., changes in citations and URL status?
  * Other analyses? Funders?
  * Deposit updated inventory file and manual review guide in GBC Collection in (as V2s) in Zenodo 
