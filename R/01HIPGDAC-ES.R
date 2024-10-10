#   Script Name: 01HIPGDAC-ES.R
#   Description: Historical Population Grids based on HISDAC-ES data set (https://doi.org/10.5194/essd-15-4713-2023)
#                It uses mainly Residential Indoor Area (RES_BIA) & Residential Building Footprint Area (RES_BUFA)
#                Also Building Footprint Area (BUFA) if there is no Residential information.
#                Eventually, it uses buildings from Nomenclator 1888 to mitigate the substitution bias
#                and Capital Municipal coordinates as a last resort in a few cases at the begining of the XX century
#   Created By:  Paco Goerlich.
#   Date:        13/04/2023
#   Last change: 09/10/2024

tictoc::tic("Total time")
library(tidyverse)
library(here)
library(sf)
library(terra)
library(stars)
source(here("fn", "integer.R"))

####################
#   Data reading   #
####################
#  1) Census1900_2011.gpkg --> 8116 municipalities
Census1900_2011 <- read_sf(here("data", "Census1900_2011.gpkg"), layer = "Census1900_2011")

#  2) Census2011.gpkg --> 8131 municipalities
Census2021 <- read_sf(here("data", "Census2021.gpkg"), layer = "Census2021")

#  3) Reference 1km x 1km Grid --> Cells: 511,294
Grid <- read_sf(here("data", "Spain2019_grid_1km_surf_ETRS89_LAEA.gpkg")) |> select(-X_LLC, -Y_LLC)

#  4) Residential Indoor Area files
resbia  <- fs::dir_ls(here("HISDAC-ES")) |> fs::path_filter(glob = "*hisdac_es_evol_resbia_v1_100_*.tif")

#  5) Residential BUFA files
resbufa <- fs::dir_ls(here("HISDAC-ES")) |> fs::path_filter(glob = "*hisdac_es_evol_resbufa_v1_100_*.tif")

#  6) BUFA files
bufa    <- fs::dir_ls(here("HISDAC-ES")) |> fs::path_filter(glob = "*hisdac_es_evol_bufa_v1_100_*.tif")

#  7) template 100m x 100m
template100 <- rast(here("data", "template_epsg3035_100m.tif"))

#  8) template 1km x 1km
template1km <- rast(here("data", "template_epsg3035_1km.tif"))

#  9) Residential buildings from Nomenclator 1888
N1888 <- rast(here("data", "N1888.tif"))

# 10) Coordinates of the municipal capital
CapMuni <- rast(here("data", "CoordenadasCapMuni_ETRS89.tif"))

###########################
#   Storing information   #
###########################
year <- c(str_sub(names(Census1900_2011)[7:18], -4), str_sub(names(Census2021)[7], -4))
data <- tibble(year = as.integer(year), POP = NA_real_, cells = NA_integer_)
data1900_2011 <- st_drop_geometry(Census1900_2011) |> select(1:6) |> mutate(POD = NA_real_, cells = NA_integer_, support = NA_character_)
data2021      <- st_drop_geometry(Census2021)      |> select(1:6) |> mutate(POD = NA_real_, cells = NA_integer_, support = NA_character_)

###############
#   Griding   #
###############
n <- length(year)
CensusGrid <- vector("list", n)
#  1) Loop over years
for (i in 1:n){
  cat("Year:", year[i], "\n")
  #  1.0) Select the correct census information given the year
  if (year[i] != 2021){
    Census <- Census1900_2011
    Munis  <- Census1900_2011$CodMuni
    Census_data <- data1900_2011
  } else {
    Census <- Census2021
    Munis  <- Census2021$CodMuni
    Census_data <- data2021
  }
  label <- paste0("POD", year[i])
  Census_data <- mutate(Census_data, year = year[i], .after = Municipio)

  #  1.1) Read RES_BIA: Residential Building Indoor Area
  rebia <- rast(resbia[i])

  #  1.2) Read RES_BUFA: Residential Building Footprint Area
  rebufa <- rast(resbufa[i])

  #  1.3) Read BUFA: Building Footprint Area
  bu <- rast(bufa[i])

  pop100 <- NULL
  #  2) Loop over municipalities
  tictoc::tic("LAU downscaling")
  for (m in Munis){
    cat("Municipality:", m, "\r")

    #   2.1) Select municipality
    Muni <- filter(Census, CodMuni == m) |> select(1:6, any_of(label))

    #   2.2) Extract population
    Pop <- Muni[1, 7] |> st_drop_geometry() |> pull()

    #   2.3) Crop & Mask resbia raster
    rebiam <- crop(rebia, Muni, mask = TRUE, touches = FALSE)

    #   2.4) Crop & Mask resbufa raster
    rebufam <- crop(rebufa, Muni, mask = TRUE, touches = FALSE)

    #   2.5) Crop & Mask bufa raster
    bum <- crop(bu, Muni, mask = TRUE, touches = FALSE)

    #   2.6) Crop & Mask N1888 raster
    N1888m <- crop(N1888, Muni, mask = TRUE, touches = FALSE)

    #   2.7) Crop & Mask Capital Municipality coordinates
    CapMunim <- crop(CapMuni, Muni, mask = TRUE, touches = FALSE)

    #   2.8) Check if Population > 0 --> then redistribute to vector cells
    #        Note: Llanos del Caudillo (13904) has 0 population between 1900 - 1950
    if (Pop > 0){
      if(check.positive(rebiam) & str_sub(m, 1, 2) %out% c("01", "20", "48")){
        bumpop <- raster2pointvector(rebiam, year[i], m, Pop)
        Census_data <- mutate(Census_data, support = replace(support, CodMuni == m, "RES_BIA"))
      } else if(check.positive(rebufam) & str_sub(m, 1, 2) %out% c("20", "48")){
        bumpop <- raster2pointvector(rebufam, year[i], m, Pop)
        Census_data <- mutate(Census_data, support = replace(support, CodMuni == m, "RES_BUFA"))
      } else if(check.positive(bum)){
        bumpop <- raster2pointvector(bum, year[i], m, Pop)
        Census_data <- mutate(Census_data, support = replace(support, CodMuni == m, "BUFA"))
      } else if(check.positive(N1888m)){
        bumpop <- raster2pointvector(N1888m, year[i], m, Pop)
        Census_data <- mutate(Census_data, support = replace(support, CodMuni == m, "N1888"))
      } else {
        bumpop <- raster2pointvector(CapMunim, year[i], m, Pop)       
        Census_data <- mutate(Census_data, support = replace(support, CodMuni == m, "MUNI"))
      }

      Census_data <- mutate(Census_data, POD   = replace(POD,   CodMuni == m, Pop),
                                         cells = replace(cells, CodMuni == m, nrow(bumpop)))

      # 2.9) Storing populated cells
      pop100 <- bind_rows(pop100, bumpop)
    }
  }
  tictoc::toc()
  CensusGrid[[i]] <- Census_data

  #  3) Rasterize to 100m x 100m
  Grid100m <- rasterize(pop100, template100, field = "po", background = 0)
  data[i, "POP"] <- global(Grid100m, "sum")$sum

  #  4) Checking --> tolerance set to integers except for 2011
  pop_lau <- st_drop_geometry(Census)[, label] |> pull()
  if(year[i] != 2011) {
    stopifnot(identical(pull(zonal(Grid100m, vect(Census), fun = "sum")), pop_lau))
    stopifnot(identical(global(Grid100m, "sum")$sum, sum(pop_lau)))
  } else {
    stopifnot(all(near(zonal(Grid100m, vect(Census), fun = "sum"), pop_lau, tol = 1e-4)))
    stopifnot(near(global(Grid100m, "sum")$sum, sum(pop_lau), tol = 1e-4))
  }

  #  5) Save the population raster grid 100m x 100m
  writeRaster(Grid100m, here("HIPGDAC-ES", paste0("hipgdac_es_100_", year[i], ".tif")))

  #  6) Aggregate de population raster grid 100m x 100m to population raster grid 1km x 1km
  Grid1km <- aggregate(Grid100m, fact = 10, fun = "sum", na.rm = TRUE)

  #  7) Save the population raster grid 1km x 1km
  writeRaster(Grid1km, here("HIPGDAC-ES", paste0("hipgdac_es_1km_", year[i], ".tif")))

  #  8) Population raster grid 1km x 1km to population vector grid 1km x 1km
  tictoc::tic("Agreggation 1km x 1km grid")
  Grid <- extract(Grid1km, Grid, fun = "sum", na.rm = TRUE, method = "simple", ID = FALSE) %>%
    bind_cols(Grid, .) %>%
    rename("{label}" := last)
  tictoc::toc()

  data[i, "cells"] <- sum(pull(select(st_drop_geometry(Grid), last_col())) != 0)
}

#  Drop cells that are 0 in all census years
Grid <- relocate(Grid, starts_with("POD"), .after = GRD_ID) %>%
  rowwise() %>%
  mutate(s = sum(c_across(starts_with("POD")))) %>%
  filter(s != 0) %>%
  select(-s) %>%
  ungroup()

########################
#   Save the results   #
########################
writexl::write_xlsx(list(Cells = data,
                         Grid = st_drop_geometry(Grid),
                         Censo1900 = CensusGrid[[1]],
                         Censo1910 = CensusGrid[[2]],
                         Censo1920 = CensusGrid[[3]],
                         Censo1930 = CensusGrid[[4]],
                         Censo1940 = CensusGrid[[5]],
                         Censo1950 = CensusGrid[[6]],
                         Censo1960 = CensusGrid[[7]],
                         Censo1970 = CensusGrid[[8]],
                         Censo1981 = CensusGrid[[9]],
                         Censo1991 = CensusGrid[[10]],
                         Censo2001 = CensusGrid[[11]],
                         Censo2011 = CensusGrid[[12]],
                         Censo2021 = CensusGrid[[13]]), here("out", "01HIPGDAC-ES.xlsx"))

write_sf(Grid, here("HIPGDAC-ES", "HIPGDAC-ES_1km.gpkg"))

#   Tiempo de ejecución
tictoc::toc()
