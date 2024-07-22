# Update of the GBC Biodata Inventory

## Work-In-Progress!

### Starting with orginal repo: https://github.com/globalbiodata/inventory_2022
* Repeated ML pipeline via updating_inventory.ipyn for publication years 2022 and 2023
* Manually reviewed flagged results and completed post-processing pipeline

### Analyze countries for new resources via:
  * Author affiliation
  * URL geocoordinates
  * Both known to be tricky; augmented with additional packages/scripts for better coverage
    * as is: new_biodata_resources_2024_unaugmented.csv
    * with additional coverage: new_biodata_resources_2024_augmented.csv
  * Notes on debatable decisions: 
    * 1) Hong Kong left separate from China, but Guadeloupe combined with France
    * 2) Augmenting means that provision of input files and scripts allows for reproducibility but scripts will not be generalizable for future updates! Data and code must be reviewed/edited to ensure new countries are not missed, etc. 
  * Plotted maps (jpegs) using new_biodata_resources_2024_augmented.csv
  
### To do: Analyze updated metadata for resources identified in 2022 inventory:
  * e.g., changes in citations and URL status
