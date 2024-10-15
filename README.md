# HIPGDAC-ES
Replication files for HIPGDAC-ES submited to [_Scientific Data_](https://www.nature.com/sdata/).

The Historical Population Grid Data Compilation for Spain (HIPGDAC-ES) contains gridded population surfaces in GeoTIFF format for all census years from 1900 to 2021 in 100m x 100m and 1km x 1km resolutions. Grids at 1km x 1km resolution are also offered in vector format as a GeoPackage database.

The data set is available at [GitHub](https://github.com/fgoerlich/HIPGDAC-ES) and [zenodo](https://doi.org/10.5281/zenodo.13916658) repositories in the HIPGDAC-ES folder.

The _R_ code that reproduces the results is `01HIPGDAC-ES.R`, in the R folder, using selected layers from the Historical Settlement Data Compilation for Spain (HISDAC-ES), available in the HISDAC-ES folder, as well as other auxiliary information and census population data at municipal level in the data folder. This script also generates an auxiliary file, `01HIPGDAC-ES.xlsx`, stored in the out folder, with the population support information for each year and municipality, which can be used for quality control in certain cases.

This work is licensed under [Creative Commons Attribution-NonComercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13916658.svg)](https://doi.org/10.5281/zenodo.13916658)

