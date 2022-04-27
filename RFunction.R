library('move')
library('sp')
library('sf')
library('ggplot2')
library('adehabitatLT')
library('geosphere')

rFunction <- function(data)
{
  Sys.setenv(tz="UTC")
  
  roads <- st_read("GRIP_roads_NASAY2Y/GRIP_roads_NASAY2Y.shp")
  
  data_ltraj <-as(data,"ltraj")
  data_spdf <- ltraj2sldf(data_ltraj,byid=TRUE)
  
  data_sf <- st_as_sf(data_spdf)
  st_crs(data_sf) <- st_crs(roads)
  
  bb <- st_bbox(data_sf)
  roads_crop <- st_crop(roads,bb)
  
  crss <- st_intersection(roads_crop,data_sf) 
  dimcrss <- dim(crss)
  crss <- st_cast(crss,to="MULTIPOINT") #change object type,else error in merge() below
  
  if (dimcrss[1]==0) 
  {
    logger.info("There is no intersection of your track(s) with any road in the Y2Y region. Returning input data set.")
    result <- data
  } else
  {
    map <- ggplot(roads_crop) + 
      geom_sf(aes(col=GP_RTP),size=2) +
      geom_sf(data=data_sf,colour="brown",aes()) +
      geom_sf(data=crss,aes(),colour="orange")
    
    
    crss_df <- data.frame("roadID"=1:dimcrss[1],data.frame(crss)[,1:(dimcrss[2]-1)])
    
    crss_detail <- merge(crss_df,st_coordinates(crss),by.x="roadID",by.y="L1")
    names(crss_detail)[names(crss_detail)=="id"] <- "animalID"
    names(crss_detail)[names(crss_detail)=="X"] <- "location.long"
    names(crss_detail)[names(crss_detail)=="Y"] <- "location.lat"
    
    # add timestamp when animal was closest to each intersection
    data.split <- move::split(data)
    
    len <- dim(crss_detail)[1]
    
    logger.info(paste("The algorithm has detected", len, "intersections of your tracks(s) with", dimcrss[1],"roads in the Y2Y region."))
    
    timestamp_near <- species <- sensor <- character(len)
    long_near <- lat_near <- numeric(len)
    for (i in seq(along=crss_detail[,1]))
    {
      #print(i)
      datai <- data.split[[which(names(data.split)==crss_detail$animalID[i])]]
      #dists2crssi <- distVincentyEllipsoid(coordinates(datai),crss_detail[i,c("location.long","location.lat")]) #takes too long
      dists2crssi <- distGeo(coordinates(datai),crss_detail[i,c("location.long","location.lat")])
      timestamp_near[i] <- as.character(timestamps(datai)[min(which(dists2crssi==min(dists2crssi)))])
      loc_neari <- coordinates(datai)[min(which(dists2crssi==min(dists2crssi))),]
      long_near[i] <- loc_neari[1]
      lat_near[i] <- loc_neari[2]
      species[i] <- idData(datai)$taxon_canonical_name
      sensor[i] <- as.character(sensor(datai))[1]
    }
    
    crss_detail <- data.frame(crss_detail,timestamp_near,long_near,lat_near,species,sensor)
    
    write.csv(crss_detail,file=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"road_crossings_table.csv"),row.names=FALSE)
    ggsave(map, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"road_crossings_map.png"),width=8, height=8)
    
    zeit <- as.POSIXct(crss_detail$timestamp_near,tz="UTC") + c(1:len)
    o <- order(zeit)
    roadcross <- move(x=crss_detail$location.long[o],y=crss_detail$location.lat[o],time=zeit[o], data = crss_detail[o,], proj=projection(data), animal <- "road_crossing")
    
    result <- moveStack(data,roadcross,forceTz="UTC")
  }
  
  return(result)
}

