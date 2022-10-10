# Y2Y Road Intersection
MoveApps

Github repository: *github.com/movestore/Y2Y_road_interaction*

## Description
Extract intersections of your tracks with the your own roads data (shapefile in WGS 84) or (as fallback) the Y2Y GRIP dataset. Note that the fallback works only for tracks in the the area between Yukon and Yellowstone!

## Documentation
The input Movement data set is transformed into an sf MULTILINES object that is overlapped with either (1) a shapefile of roads uploaded by the App user or (2) a shapefile extract of the GRIP global roads database (https://www.globio.info/download-grip-dataset) of the Y2Y area (fallback). It is required that the roads shapefile is provided in WGS 84 an that the files are called 1. `roads.cpg`, 2. `roads.dbf`, 3. `roads.prj`, 4. `roads.shp`, 5. `roads.shx` (see description in Settings).

The App extracts the intersection locations of the linear approximations of individual tracks. Attributes of each intersection are a random roadID, the animalID of the track and road properties as described in the table below (from Meijer, J. R., Huijbregts, M. A., Schotten, K. C., & Schipper, A. M. (2018). Global patterns of current and future road infrastructure. Environmental Research Letters, 13(6), 064006.).

A map of the region with roads, tracks and intersection points is provided as .png file. Note that colouring of the roads is by default road type ("GP_RTP" in the fallback data set), but can be defined by the parameter "colour_name". An overview of the intersections with properties is created as .csv file. The output data file is constructed of the input data set and an additional (fictive) individual called "road_crossing", including all road crossing locations, so that they can be visualised together in further Apps like e.g. the Simple Leaflet Map App.

#### Intersection attributes 
- file headings road_crossings_table.csv

- see details in Table `GRIP4_AttributeDescription.xlsx` here: https://zenodo.org/record/6420961#.Ymft39PP2Um

`roadID`: random ID for road

`animalID`: individual.local.identifier of the animal crossing the road

`GP_RTP`: road type (1-highways, 2-primary roads, 3-secondary roads, 4-tertiary roads, 5-local roads, 0-unspecified)

`GP_REX`: road existance (1-open, 2-restricted, 3-closed, 4-under construction/repair, 0-unspecified) 

`GP_RAV`: road availability (1-yes, 2-no, 0-unspecified)

`GP_RRG`: road region (see file in zenodo - link above)

`GP_RCY`: road county (ISO1 code, see file in zenodo - link above)

`GP_RSE`: road surface (1-paved, 2-gravel, 3-dirt/sand, 4-steel, 5-wood, 6-grass, 0-unspecified)

`GP_RSI`: road source ID (see file in zenodo - link above)

`GP_RSY`: year the data source describes the road

`Shape_Leng`: total length of the road

`gp_gripreg`: aggregated region for the GLOBIO website downloads

`location.long`: longitude of intersection location

`location.lat`: latitude of intersection location

`timestamp_near`: timestamp of closest location of the same animal to the intersection (with random seconds added for uniqueness of timestamp)

`long_near`: longigute of closest location of the same animal to the intersection

`lat_near`: latitude of closest location of the same animal to the intersection

`species`: species of animal of the intersection

`sensor`: sensor used to collect locations of animal of the intersection


### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`road_crossings_table.csv`: Overview of the extracted intersections with animalID, roadID, closest true location of the animal and its timestamp, and road properties (see above).
 
`road_crossings_map.png`: Map of roads (blue) of the tracking area, with tracks (dark red) and intersections as points (orange).

### Parameters 
`road_names`: Variable of the street data set indicating colouring of roads in output map. Defaults to "GP_RTP" which is road type in the fallback GRIP roads data set.

`road_files`: Metadata allowing the local upload of a roads shapefile in WGS 84 that overlaps with the handled tracking data set.

### Null or error handling:
**Parameter `road_names`:** If the selected column name of the road data set does not exist, all roads are coloured in the same colour `blue`. A warning is given.

**Data:** The full input data set with an additional (fictive) individual called "road_crossing" is returned for further use in a next App.
