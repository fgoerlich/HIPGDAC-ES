This folder contains Census municipal population and other auxiliary files used in the gridding process:

Census1900_2011.gpkg: Homogeneous census municipal population from 1900 to 2011 with the administrative boundaries of 2011. Vector information.
   Source: https://www.fbbva.es/publicaciones/cambios-en-la-estructura-y-localizacion-de-la-poblacion-una-vision-de-largo-plazo-1842-2011/
   Data:   https://zenodo.org/uploads/11095163

Census2021.gpkg: Census municipal population for 2021 with administrative boundaries. Vector information.
   Source: Instituto Nacional de Estadística (INE) and Instituto Geográfico Nacional (IGN)
   Data:   Population: https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736176992&menu=resultados&idp=1254735572981#_tabs-1254736195813
           Administrative boundaries: https://ropenspain.github.io/LAU2boundaries4spain/

Spain2019_grid_1km_surf_ETRS89_LAEA.gpkg: Reference grid for Spain acording to INSPIRE (2014), D2.8.I.2 Data Specification on Geographical Grid Systems – Technical Guidelines v3.1, especifications. Vector information.
   Source: https://go.uv.es/goerlich/GridStatistics
   Data:   https://zenodo.org/records/12954007

N1888.tif: Residential buildings from Nomenclator 1888. Raster information. Resolution 100m x 100m.
   Source: https://www.esparel.com/

CoordenadasCapMuni_ETRS89.tif: Coordinates of the municipal capital. Raster information. Resolution 100m x 100m.
   Source: Gazetteer of municipalities and population entities. Instituto Geográfico Nacional (IGN)
   Data:   https://centrodedescargas.cnig.es/CentroDescargas/locale?request_locale=en

template_epsg3035_1km.tif: Raster template with the same extend and resolution as the vector layer: Spain2019_grid_1km_surf_ETRS89_LAEA.gpkg

template_epsg3035_100m.tif: Raster template with the same extend as template_epsg3035_1km.tif, and resolution 100m x 100m.

All geographical information is in LAEA projection, Lambert Azimuthal Equal Area (EPSG:3035).