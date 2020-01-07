basemapR
================
07/01/2020

## Installing basemapR

Install from github using devtools:

``` r
library(devtools)
install_github('Chrisjb/basemapR')
```

    ## Downloading GitHub repo Chrisjb/basemapR@master

    ##   
       checking for file ‘/private/var/folders/3v/3nkd8rwx2hzf33znl6f5qw6r0000gn/T/RtmpJuG9WI/remotes412653ffdb9b/Chrisjb-basemapR-e115934/DESCRIPTION’ ...
      
    ✔  checking for file ‘/private/var/folders/3v/3nkd8rwx2hzf33znl6f5qw6r0000gn/T/RtmpJuG9WI/remotes412653ffdb9b/Chrisjb-basemapR-e115934/DESCRIPTION’ (398ms)
    ## 
      
    ─  preparing ‘basemapR’:
    ## 
      
       checking DESCRIPTION meta-information ...
      
    ✔  checking DESCRIPTION meta-information
    ## 
      
    ─  checking for LF line-endings in source and make files and shell scripts
    ## 
      
    ─  checking for empty or unneeded directories
    ## ─  looking to see if a ‘data/datalist’ file should be added
    ## 
      
         NB: this package now depends on R (>= 3.5.0)
    ## 
      
         WARNING: Added dependency on R >= 3.5.0 because serialized objects in  serialize/load version 3 cannot be read in older versions of R.  File(s) containing such objects: 'basemapR/data/localauth_data.RData'
    ## ─  building 'basemapR_0.1.0.tar.gz'
    ## 
      
       
    ## 

## Adding a basemap to ggplot2

the `base_map` function can be added to a ggplot2 call as follows:

``` r
library(ggplot2)
library(sf)
```

    ## Linking to GEOS 3.6.1, GDAL 2.1.3, PROJ 4.9.3

``` r
library(basemapR)

ggplot() +
  base_map(st_bbox(localauth_data), increase_zoom = 2) +
  geom_sf(data = localauth_data, fill = NA)
```

    ## attribution: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>

![](readme_files/figure-gfm/basemap_ggplot-1.png)<!-- -->

#### bbox

A bounding box created using `st_bbox` or the basemapR function
`expand_bbox` (see below). The bounding box defines the extents over
which we want the base map to be returned.

This will normally be the largest layer on our map. Sometimes we will
have two distinct layers neither of which covers the full extent of the
map on their own. For example:

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(basemapR)
library(sf)


camden <- localauth_data %>% 
  filter(Name  == 'Camden')

wandsworth <- localauth_data %>% 
  filter(Name  == 'Wandsworth')


ggplot() +
  geom_sf(data = camden) +
  geom_sf(data = wandsworth)
```

![](readme_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

We need to create a bbox that combines both layers for the base map to
cover the full extents of the
canvas:

``` r
# create bbox polygons for each and union and then convert back to bbox object
my_bbox <- st_bbox(camden) %>%
  st_as_sfc() %>%
  st_union(st_as_sfc(st_bbox(wandsworth))) %>%
  st_bbox()
```

``` r
ggplot() +
  base_map(bbox = my_bbox, basemap = 'hydda', increase_zoom = 2) +
  geom_sf(data = camden, fill = NA) +
  geom_sf(data = wandsworth, fill = NA) +
  ggthemes::theme_map()
```

    ## attribution: Tiles courtesy of http://openstreetmap.se/ OpenStreetMap Sweden; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors

![](readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

#### increase\_zoom

The zoom parameter is calculated automatically. It can be increased by
setting increase\_zoom to an integer value. In the first example we set
`increase_zoom = 2`. We can play around with this value as per our
desired aesthetic.

#### basemap

Various options for base maps. The attribution for the base layer should
be included on the maps and is returned as a message from the function.

**dark** attribution: ©
<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>
contributors © <a href="https://carto.com/attributions">CARTO</a>

**hydda**

**positron**

**voyager**

**wikimedia**

**mapnik**

**neighbourhood**
