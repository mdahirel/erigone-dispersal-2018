library(raster)
library(landscapemetrics)
library(ggspatial)
library(sf)
library(ggtext)
library(tidyverse)
library(here)

options(mc.cores = 4)

map_points<-st_read(here("data","erigone2018_GISlayers.gpkg"),
                    layer="sampling_sites",
                    quiet=TRUE)

sites <- read_csv(here("data","erigone2018_sites.csv"))

raster_pucci <- raster(here("data","erigone2018_raster_pucci_dominant.tif"))

raster_pucci<-extend(raster_pucci,y=200,value=2)
##we extend the raster in the north south direction to ensure buffers don't go beyond the landscape
## we can do it safely, north is sea and south is agricultural land, no favourable habitat there
## so value = 2


points_remapped=map_points %>% 
  st_transform(st_crs("EPSG:3035"))

lmetrics=function(distance,raster_source,sampled,shape,what){
test=sample_lsm(raster_source,
           y=sampled,plot_id=sampled$name,
           what=what,
           shape=shape, ## shape circle may cause problems for clumpy see,https://github.com/r-spatialecology/landscapemetrics/issues/232
           size=distance)%>% 
  filter(class==1) %>% 
  select(-c(level,class)) %>% 
  mutate(patch=plot_id) %>% 
  pivot_wider(names_from=metric)

return(test)

}

test=tibble(dist=c(1:20)*100,index=1:20)  %>% 
  group_by(dist) %>% 
  nest(dist=dist) %>% 
  mutate(pland=map(.x=dist,
                   .f=~.x$dist %>% 
                     lmetrics(distance=., 
                              raster_source=raster_pucci,
                              sampled=points_remapped,
                              what="lsm_c_pland",shape="circle")),
         psize=map(.x=dist,
                   .f=~.x$dist %>% 
                     lmetrics(distance=., 
                              raster_source=raster_pucci,
                              sampled=points_remapped,
                              what=c("lsm_c_area_mn","lsm_c_gyrate_mn"),shape="circle")),
         lmetrics=map(.x=dist,
                      .f=~.x$dist %>% 
                        lmetrics(distance=., 
                                 raster_source=raster_pucci,
                                 sampled=points_remapped,
                                 what="lsm_c_clumpy",shape="square")))
##based on tbale 2 in wang MEE if we want metrics independent from habitat loss
##we can use PAFRAC, the core areas metrics, 
## prox_cv, econ_am or teci, and clumpy
#PAFRAC is a nono because too low number of patches, econm_am or teci not relevant because
## denote edge effects, so need to specify a contrast weight to edge
## prox_cv is defined at the patch level, so problematic when only one small patch alone in the buffer
## core areas: my pixels are 10m, my spider 4mm, not sure how to define a edge depth??
## so seems like clumpy only?? (OK with me)


test %>% 
  unnest(pland) %>% unnest(dist) %>% left_join(sites) %>% 
  mutate(landscape=paste("landscape =", landscape)) %>% 
  mutate(landscape=fct_relevel(factor(landscape),
                               "landscape = west","landscape = east")) %>% 
  filter(is_habitat=="y") %>% 
  ggplot()+
  geom_line(aes(dist,pland,group=patch,col=landscape))+
  geom_point(aes(dist,pland,group=patch,col=landscape)) + 
  scale_x_continuous("distance (buffer radius, m)")+
  scale_y_continuous(" % of favourable habitat")+
  scale_color_manual(values=c("#f1a340","#998ec3"),guide="none")+
  theme_bw()+
  facet_wrap(~landscape)+
  theme(axis.title.y=element_markdown())
  
test %>% 
  unnest(psize) %>% unnest(dist) %>% left_join(sites) %>% 
  mutate(landscape=paste("landscape =", landscape)) %>% 
  mutate(landscape=fct_relevel(factor(landscape),
                               "landscape = west","landscape = east")) %>% 
  filter(is_habitat=="y") %>% 
  ggplot()+
  geom_line(aes(dist,gyrate_mn,group=patch,col=landscape))+ ##area is estimated in ha
  geom_point(aes(dist,gyrate_mn,group=patch,col=landscape)) + 
  scale_x_continuous("distance (buffer radius, m)")+
  scale_y_continuous("average radius of gyration (GYRATE, m)")+
  scale_color_manual(values=c("#f1a340","#998ec3"),guide="none")+
  theme_bw()+
  facet_wrap(~landscape)

test %>% 
  unnest(lmetrics) %>% unnest(dist) %>% left_join(sites) %>% 
  mutate(landscape=paste("landscape =", landscape)) %>% 
  mutate(landscape=fct_relevel(factor(landscape),
                               "landscape = west","landscape = east")) %>% 
  filter(is_habitat=="y") %>% 
  ggplot()+
  geom_line(aes(dist,clumpy,group=patch,col=landscape))+
  geom_point(aes(dist,clumpy,group=patch,col=landscape)) + 
  scale_x_continuous("distance (square side length/2, m)")+
  scale_y_continuous("Clumpiness index (CLUMPY)")+
  scale_color_manual(values=c("#f1a340","#998ec3"),guide="none")+
  theme_bw()+
  facet_wrap(~landscape)

###mention the pixel size in the figure!!!

