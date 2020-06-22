#' Base Map
#'
#' fetches a basemap for our map based on the map's bounding box. Includes themes available at: https://leaflet-extras.github.io/leaflet-providers/preview/
#'
#' @param bbox bounding box for out map extents generated using st_bbox() and expanded as necessary using expand_bbox(). Bounding box should be in lat/lng (epsg: 4326).
#' @param increase_zoom the zoom is automatically calculated for the map but we can increase or decrease the zoom by setting an integer value.
#' @param basemap the style of basemap to use. Currently supports 'dark', 'hydda', 'positron', 'voyager', 'wikimedia', 'mapnik', google, google-nobg, google-hybrid, google-terrain, google-satellite, google-road
#' @param nolabels if TRUE, removes labels from the basemap. This is only available for some styles.
#'
#' @return a set of tiles to be added to a ggplot object.
#'
#' @import sf
#' @importFrom purrr map pmap pmap_dfr
#'
#'
#' @examples
#' # get bounding box for our map
#' library(sf)
#' bbox <- st_bbox(localauth_data)
#'
#' # add to ggplot
#' library(ggplot2)
#' ggplot() +
#' base_map(bbox, increase_zoom = 2, basemap = 'google-terrain')+
#' geom_sf(data = localauth_data, fill =NA )  +
#' coord_sf(xlim = c(bbox$xmin, bbox$xmax), ylim = c(bbox$ymin, bbox$ymax), crs = 4326)
#'
#'
#' # add straight to ggplot
#'
#' ggplot() +
#' base_map(st_bbox(localauth_data), increase_zoom = 2) +
#' geom_sf(data = localauth_data, fill = NA)
#'
#' @export


base_map <- function(bbox, increase_zoom=0, basemap = 'dark', nolabels = F){


  x_len <- bbox["xmax"] - bbox["xmin"]
  y_len <- bbox["ymax"] - bbox["ymin"]

  # calculate the minimum zoom level that is smaller than the lengths
  x_zoom <- sum(x_len < 360 / 2^(0:19)) - 1
  y_zoom <- sum(y_len < 170.1022 / 2^(0:19)) - 1

  zoom <- min(x_zoom, y_zoom)
  zoom <- zoom + increase_zoom

  # get extents of tiles
  corners <- expand.grid(x = bbox[c(1, 3)], y = bbox[c(2, 4)])

  xy <- lonlat2xy(bbox[c("xmin", "xmax")], bbox[c("ymin", "ymax")], zoom)

  tiles <- expand.grid(x = seq(xy$x["xmin"], xy$x["xmax"]),
                       y = seq(xy$y["ymin"], xy$y["ymax"]))



  nw_corners <- purrr::pmap_dfr(tiles, xy2lonlat, zoom = zoom)
  # add 1 to x and y to get the south-east corners
  se_corners <- purrr::pmap_dfr(dplyr::mutate_all(tiles, `+`, 1), xy2lonlat, zoom = zoom)

  names(nw_corners) <- c("xmin", "ymax")
  names(se_corners) <- c("xmax", "ymin")

  tile_positions <- dplyr::bind_cols(nw_corners, se_corners)


  # cartodblayer
  if (basemap == "positron") {
    if (nolabels == F) {
      url <- paste0("https://basemaps.cartocdn.com/light_all/", zoom, "/", tiles$x, "/", tiles$y, ".png") # positron
    } else {
      url <- paste0("https://basemaps.cartocdn.com/light_nolabels/", zoom, "/", tiles$x, "/", tiles$y, ".png")
    }
  } else if (basemap == "hydda") {
    if (nolabels == F) {
      url <- paste0("https://tile.openstreetmap.se/hydda/full/", zoom, "/", tiles$x, "/", tiles$y, ".png") # hydda
    } else {
      url <- paste0("https://tile.openstreetmap.se/hydda/base/", zoom, "/", tiles$x, "/", tiles$y, ".png")
    }
    message('attribution: Tiles courtesy of http://openstreetmap.se/ OpenStreetMap Sweden; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors')

  } else if(basemap == 'voyager') {
    if(nolabels == F) {
      url <- paste0('https://basemaps.cartocdn.com/rastertiles/voyager/',zoom,'/',tiles$x,'/',tiles$y,'.png') # voyager
    } else {
      url <- paste0('https://basemaps.cartocdn.com/rastertiles/voyager_nolabels/',zoom,'/',tiles$x,'/',tiles$y,'.png')
    }
    message('attribution: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>')

  } else if(basemap == 'france'){
    if(nolabels == F) {
      url <- paste0('https://tile.openstreetmap.fr/osmfr/,zoom','/',tiles$x,'/',tiles$y,'.png') # france
    } else {
      url <- paste0('https://tile.openstreetmap.fr/osmfr/,zoom','/',tiles$x,'/',tiles$y,'.png') # france
      message('nolabels not available for basemap: ', basemap, '. returning map with labels.')
    }
    message('attribution: &copy; Openstreetmap France | &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors')


  } else if(basemap == 'dark') {
    if(nolabels == F) {
      url <- paste0('https://basemaps.cartocdn.com/dark_all/',zoom,'/',tiles$x,'/',tiles$y,'.png') # dark
    } else {
      url <- paste0('https://basemaps.cartocdn.com/dark_nolabels/',zoom,'/',tiles$x,'/',tiles$y,'.png') # dark
    }
    message('attribution: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>')

  } else if(basemap == 'neighbourhood') {
    if(nolabels == F) {
      url <- paste0('https://tile.thunderforest.com/neighbourhood/',zoom,'/',tiles$x,'/',tiles$y,'.png') # neighbourhood
    } else {
      url <- paste0('https://tile.thunderforest.com/neighbourhood/',zoom,'/',tiles$x,'/',tiles$y,'.png') # neighbourhood
      message('nolabels not available for basemap: ', basemap, '. returning map with labels.')
    }
    message('attribution: &copy; <a href="http://www.thunderforest.com/">Thunderforest</a>, &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors')

  } else if(basemap == 'mapnik') {
    url <- paste0('https://tile.openstreetmap.org/',zoom,'/',tiles$x,'/',tiles$y,'.png') #osm mapnik
    message('attribution: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors')

    if(nolabels == T){
      message('nolabels not available for basemap: ', basemap, '. returning map with labels.')
    }
  } else if(basemap == 'wikimedia') {
    url <- paste0('https://maps.wikimedia.org/osm-intl/',zoom,'/',tiles$x,'/',tiles$y,'.png') #wikimedia
    message('please see attribution details: https://wikimediafoundation.org/wiki/Maps_Terms_of_Use')

    if(nolabels == T){
      message('nolabels not available for basemap: ', basemap, '. returning map with labels.')
    }

  } else if(basemap == 'esri') {
    url <- paste0('https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/',zoom,'/',tiles$y,'/',tiles$x,'.png') #esri
    message('attribution: Tiles &copy; Esri &mdash; Esri, DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community')
    if(nolabels == T){
      message('nolabels not available for basemap: ', basemap, '. returning map with labels.')
    }
  } else if(basemap == 'esri-imagery') {
    url <- paste0('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/',zoom,'/',tiles$y,'/',tiles$x,'.png')

    message('attribution: Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community')
  } else if(basemap == 'google'){
    url <- paste0('https://mt.google.com/vt/lyrs=m&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please see attribution details: https://wikimediafoundation.org/wiki/Maps_Terms_of_Use')

  } else if(basemap == 'google-road'){
    url <- paste0('https://mt.google.com/vt/lyrs=r&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please cite: map data \uA9 2020 Google')

  } else if(basemap == 'google-nobg'){
    url <- paste0('https://mt.google.com/vt/lyrs=h&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please cite: map data \uA9 2020 Google')
  } else if(basemap == 'google-satellite'){
    url <- paste0('https://mt.google.com/vt/lyrs=s&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please cite: map data \uA9 2020 Google')
  } else if(basemap == 'google-hybrid'){
    url <- paste0('https://mt.google.com/vt/lyrs=y&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please cite: map data \uA9 2020 Google')
  } else if(basemap == 'google-terrain'){
    url <- paste0('https://mt.google.com/vt/lyrs=p&x=',tiles$x,'&y=',tiles$y,'&z=',zoom,'')
    message('please cite: map data \uA9 2020 Google')
  }



  pngs <- purrr::map(url, get_tile)


  args <- tile_positions %>%
    dplyr::mutate(raster = pngs)

  return(purrr::pmap(args,annotation_raster, interpolate = TRUE))
}
