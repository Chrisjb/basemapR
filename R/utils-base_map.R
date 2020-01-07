#' Utility functions for base_map.R
sec <- function(x) {
  1 / cos(x)
}

lonlat2xy <- function(lat_deg, lon_deg, zoom) {
  n <- 2^zoom

  x <- (n * (lat_deg + 180)) %/% 360
  lon_rad <- lon_deg * pi / 180
  y <- (n * (1 - log(tan(lon_rad) + sec(lon_rad)) / pi)) %/% 2

  list(x = x, y = y)
}

xy2lonlat <- function(x, y, zoom) {
  n <- 2^zoom

  lon_deg <- x / n * 360.0 - 180.0
  lat_rad <- atan(sinh(pi * (1 - 2 * y / n)))
  lat_deg <- lat_rad * 180.0 / pi

  list(lon_deg = lon_deg, lat_deg = lat_deg)
}

get_tile <- function(url) {

  tmp <- tempfile()

  h <- curl::new_handle()
  curl::handle_setheaders(h, `User-Agent` = "basemapR")

  curl::curl_download(url, destfile = tmp)

  tryCatch(png::readPNG(tmp),
           error = function(e){
             jpeg::readJPEG(tmp)
           })


}
