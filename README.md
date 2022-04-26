# Y2Y Road Intersection
MoveApps

Github repository: *github.com/movestore/Y2Y_road_interaction*

## Description
Extract intersections of your tracks with the Y2Y road network (GRIP dataset). Note that this App works only for tracks in the the area between Yukon and Yellowstone!

## Documentation
The input Movement data set is transformed into an sf MULTILINES object that is overlapped with a shapefile extract of the GRIP global roads database (https://www.globio.info/download-grip-dataset) of the Y2Y area. 

The App extracts the intersection locations of the linear approximations of individual tracks. Attributes of each intersection are a random roadID, the animalID of the track and road properties as described in the table below (from Meijer, J. R., Huijbregts, M. A., Schotten, K. C., & Schipper, A. M. (2018). Global patterns of current and future road infrastructure. Environmental Research Letters, 13(6), 064006.).

A map of the region with roads, tracks and intersection points is provided as .png file. An overview of the intersections with properties is created as .csv file. The output data file is constructed of the input data set and an additional (fictive) individual called "road_crossing", including all road crossing locations, so that they can be visualised together in further Apps like e.g. the Simple Leaflet Map App.

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
no parameters

### Null or error handling:
**Data:** The full input data set with an additional (fictive) individual called "road_crossing" is returned for further use in a next App.
