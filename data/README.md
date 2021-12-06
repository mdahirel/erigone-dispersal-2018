# erigone-dispersal-2018/data
 
 (see the preprint and the comments in the analysis code in `R` for more information)
 
 - `cocoons` contain data about each egg-sac (who laid it? how many spiderlings?)
 - `females` and `males` contain individual-level information about each adult spider kept for the experiment
 - `pairings` is a list of every male-female reproductive pair created for this experiment
 - `pedigree` gives the, well, pedigree of each adult used in the experiment, i.e. the ID of both its parents
 - the `GISlayers` geopackage contains vector layers for the sampling sites and for the land cover as seen from the spider perspective (favourable habitat or not)
 - the `raster_pucci` files are rasterizations of this land cover layer using two discretisations: either "habitat dominated by *Puccinellia maritima* versus all others" or "habitat where *Puccinellia* is present even if not dominant versus others"
 -  `sites` is a table summarising information about each sampling site, including sampling effort and number of spider caught
 -  the `weather_data` folder contains a copy of open source weather data for the nearest weather station; see details in there
