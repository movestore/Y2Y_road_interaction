library('move')
library('sp')
library('sf')
library('ggplot2')
library('adehabitatLT')
library('geosphere')

# plans for changes: 
# 1. find crossings for each individual separately, make track into multiline (of each 2-pt segment) to have more control of when the crossing took place and have a correct timestamp and closest location (in time)
# 2. have legend indicate also colours black and orange
# 3. add background map (ggmap or leaflet)
# 4. option to get back fallback roads file (MoveApps feature)


rFunction <- function(data,colour_name=NULL,road_files=NULL)
{
  Sys.setenv(tz="UTC")
 
  #roads <- st_read("GRIP_roads_NASAY2Y/GRIP_roads_NASAY2Y.shp")
  roads <- st_read(paste0(getAppFilePath("road_files"),"roads.shp"))
  
  data_lsl <- lapply(move::split(data), function(x){Lines(list(Line(coordinates(x))),ID=namesIndiv(x))})
  data_sldf <- SpatialLinesDataFrame(SpatialLines(data_lsl,proj4string = data@proj4string), data=data.frame(idData(data),"trackId"=unique(trackId(data))) ,match.ID = F)
  
  #data_ltraj <- as(data,"ltraj") #ltraj trows away projection info, thus dont use it!
  #data_spdf <- ltraj2sldf(data_ltraj,byid=TRUE)
  
  data_sf <- st_as_sf(data_sldf)
  #data_sf <- st_as_sf(data)
  #st_crs(data_sf) <- st_crs(roads)
  roads <- st_transform(roads,st_crs(data_sf))
  
  bb <- st_bbox(data_sf)
  roads_crop <- st_crop(roads,bb)
  
  logger.info("crss running")
  crss <- st_intersection(roads_crop,data_sf) #for each road section one feature with crossings
  logger.info("crss finished")
  dimcrss <- dim(crss)
  crss <- st_cast(crss,to="MULTIPOINT") #change object type,else error in merge() below
  
  if (dimcrss[1]==0) 
  {
    logger.info("There is no intersection of your track(s) with any road in the Y2Y region. Returning input data set.")
    result <- data
  } else
  {
    if (is.null(colour_name) | length(colour_name)==0 | colour_name %in% names(roads_crop)==FALSE)
    {
      logger.info("Your road colour name does not exist or has been chosen to be NULL. Therefore all roads have the same colour, not indicating road type or any other property.")
      
      map <- ggplot() + 
        geom_sf(data=data_sf,colour="black",aes(alpha= "Tracks")) +
        geom_sf(data=roads_crop,aes(alpha= "Roads"), colour="red",size=2) +
        geom_sf(data=crss,aes(alpha="Road intersections"),colour="orange") +
        ggtitle("Road intersections") +
        scale_alpha_manual(name = NULL, # here a "title" could be added
                           values = c(1, 1, 1), # setting all to 1 as no transparency is wanted
                           breaks = c("Roads","Tracks", "Road intersections"),
                           guide = guide_legend(override.aes = list(linetype = c(1,1, 0),
                                                                    shape = c(NA,NA, 16),
                                                                    color = c("red","black", "orange") ))) 
    } else
    {
      eval(parse(text=paste0("class(roads_crop$",colour_name,") <- 'character'")))

      map <- ggplot() + 
        geom_sf(data=data_sf,colour="black",aes(alpha= "Tracks")) +
        geom_sf(data=roads_crop,aes(col=as.factor(.data[[colour_name]])),size=2) + # aes_string is deprecated
        geom_sf(data=crss,aes(alpha="Road intersections"),colour="orange") +
        guides(colour = guide_legend(title = "Road type")) +
        ggtitle("Road intersections") +
        scale_alpha_manual(name = NULL, # here a "title" could be added
                           values = c(1, 1), # setting all to 1 as no transparency is wanted
                           breaks = c("Tracks", "Road intersections"),
                           guide = guide_legend(override.aes = list(linetype = c(1, 0),
                                                                    shape = c(NA, 16),
                                                                    color = c("black", "orange") ))) 
    }
    
    crss_df <- data.frame("roadID"=1:dimcrss[1],data.frame(crss)[,1:(dimcrss[2]-1)])
    
    crss_detail <- merge(crss_df,st_coordinates(crss),by.x="roadID",by.y="L1")
    names(crss_detail)[names(crss_detail)=="animalName"] <- "trackId"
    names(crss_detail)[names(crss_detail)=="X"] <- "location.long"
    names(crss_detail)[names(crss_detail)=="Y"] <- "location.lat"
    
    # add timestamp when animal was closest to each intersection
    data.split <- move::split(data)
    
    len <- dim(crss_detail)[1]
    
    logger.info(paste("The algorithm has detected", len, "intersections of your tracks(s) with", dimcrss[1],"roads in the Y2Y region."))
    
    timestamp.near <- animalID <- species <- sensor <- character(len)
    long.near <- lat.near <- numeric(len)
    for (i in seq(along=crss_detail[,1])) #for each crossing point
    {
      #print(i)
      datai <- data.split[[which(names(data.split)==crss_detail$trackId[i])]]
      #dists2crssi <- distVincentyEllipsoid(coordinates(datai),crss_detail[i,c("location.long","location.lat")]) #takes too long
      dists2crssi <- distGeo(coordinates(datai),crss_detail[i,c("location.long","location.lat")]) #meter
      ixmin <- min(which(dists2crssi==min(dists2crssi)))
      timestamp.near[i] <- as.character(timestamps(datai)[ixmin]) #timestamp of location of this track that is closest to crossing
      loc_neari <- coordinates(datai)[ixmin,]
      long.near[i] <- loc_neari[1]
      lat.near[i] <- loc_neari[2]
      sensor[i] <- as.character(sensor(datai))[1]
      
      iddata <- idData(datai)
      names(iddata) <- make.names(names(iddata),allow_=FALSE)
      if (any(names(iddata)=="individual.taxon.canonical.name")) {
        species[i] <- iddata$individual.taxon.canonical.name[1]
      } else if (any(names(iddata)=="taxon.canonical.name")) {
        species[i] <- iddata$taxon.canonical.name[1]
      } else {
        species[i] <- NA
      }
      
      if (any(names(iddata)=="individual.local.identifier")) {
        animalID[i] <- iddata$individual.local.identifier[1]
      } else if (any(names(iddata)=="local.identifier")) {
        animalID[i] <- iddata$local.identifier[1]
      } else {
        animalID[i] <- NA
      }
    }
    
    crss_detail <- data.frame("roadID"=crss_detail[,1],animalID,crss_detail[,-1],timestamp.near,long.near,lat.near,species,sensor)
    
    write.csv(crss_detail,file=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"road_crossings_table.csv"),row.names=FALSE)
    ggsave(map, file = paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"road_crossings_map.png"),width=8, height=8)
    
    zeit <- as.POSIXct(crss_detail$timestamp.near,tz="UTC") + c(1:len)
    o <- order(zeit)
    roadcross <- move(x=crss_detail$location.long[o],y=crss_detail$location.lat[o],time=zeit[o], data = crss_detail[o,], proj=projection(data))
    
    result <- moveStack(data,"road_crossing"=roadcross,forceTz="UTC")
  } 
  
  
  return(result)
}

