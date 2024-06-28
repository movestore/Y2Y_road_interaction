# Road Intersections (Y2Y)
MoveApps

Github repository: *github.com/movestore/Y2Y_road_interaction*

## Description
Extract intersections of tracking data with roads, as provided in a shapefile in WGS84, or (as fallback) the Global Roads Inventory Project (GRIP) dataset for the Yellowstone-to-Yukon region, which will only provide results within this region. Note that the GRIP data are good for large-scale analyses, but not navigation-quality.

## Documentation
The input Movement data set is transformed into an sf MULTILINES object, i.e., a set of trajectories with straight lines connecting subsequent locations. These trajectories are overlapped with either (1) a shapefile of roads uploaded by the App user or (2) a shapefile extract of the [Global Roads Inventory Project (GRIP) dataset](https://www.globio.info/download-grip-dataset) of the study region for the [Room to Roam: Y2Y Wildlife Movements project](https://ceg.osu.edu/Y2Y_Room2Roam) (fallback). To include a local roads shapefile in this App, make sure it is projected in WGS84 and that the files are called 1. `roads.cpg`, 2. `roads.dbf`, 3. `roads.prj`, 4. `roads.shp`, 5. `roads.shx` (see description in Settings). 

**Be aware that the analysis will be sensitive to the accuracy and resolution of the input datasets (both tracking data and roads).** The GRIP dataset provided as fallback is intended for 'global environmental and biodiversity modelling projects' and not for navigation. Therefore, please upload your own, high-quality roads dataset to the App for local analyses. If you do not have a shapefile of roads for your region of interest, you can complete exploratory analysis using data from GRIP or [Natural Earth](https://www.naturalearthdata.com/). To improve handling of large datasets, you can extract data for a specific bounding box or polygon using the [ECODATA Subsetter App](https://ecodata-apps.readthedocs.io/en/latest/user_guide/subsetter.html).

The App extracts the intersection locations of the linear approximations of individual tracks. Attributes of each intersection are a random roadID, the animalID of the track and road properties as described in the table below, from Meijer JR, Huijbregts MAJ, Schotten KCGJ, Schipper AM. 2018. Global patterns of current and future road infrastructure. Environmental Research Letters. 13(6):064006. [https://doi.org/10.1088/1748-9326/aabd42](https://doi.org/10.1088/1748-9326/aabd42).

The intersections and related properties are summarized in a .csv file. In addition, a map showing roads, tracks and intersection points is provided as .png file. Note that colouring of the roads is by default road type ("GP_RTP" in the fallback data set), but can be defined by the setting "Column name for street colouring". The output data includes the input data set and an additional (fictive) individual called "road_crossing", including all road crossing locations, so that they can be visualised together in subsequent Apps, such as interactive maps and the [Write Shapefile App](https://www.moveapps.org/apps/browser/47e46a4f-8839-48c7-bfce-cbd70b478d98).

Calculations assume that the animal travels at a consistent speed in a straight line between consecutive locations. Note that the accuracy of the results will depend on the accuracy and resolution of the input tracking and roads datasets. You can use the [Track Summary Statistics App](https://www.moveapps.org/apps/browser/8ca03c5a-d61a-466d-860b-11beb6bf6404) to obtain a summary of fix rates and sensor types within the tracking data. To assess possible missing roads or other infrastructure, you can view the results with basemaps showing satellite imagery and/or physical infrastructure, such as the [Interactive Map (leaflet) App](https://www.moveapps.org/apps/browser/163c11bf-bd2c-4984-9fa6-96acdf5ac8b3). 

The GRIP documentation explains that the dataset is for 'global environmental and biodiversity modelling projects. The dataset is not suitable for navigation.' 

#### Intersection attributes 
The following attributes describing road intesections are added to the output dataset and summarized in the output file road_crossings_table.csv.

One group of attributes comes from your tracking data (those that are included in the output .rds file and passed on to subsequent Apps).

A second group of attributes is specific to the road intersection analysis regardless of input data, including

`location.long`: longitude of intersection location

`location.lat`: latitude of intersection location

`timestamp.near`: timestamp of closest location of the same animal to the intersection (with random seconds added for uniqueness of timestamp)

`long.near`: longitude of closest location of the same animal to the intersection

`lat.near`: latitude of closest location of the same animal to the intersection

`species`: species of animal of the intersection

`sensor`: sensor used to collect locations of animal of the intersection

`roadID`: random ID for road

`animalID`: individual.local.identifier of the animal crossing the road

A third group of attributes comes from the roads data source used in the analysis. If you use the default GRIP dataset, this will include the attributes listed below. See details in Table `GRIP4_AttributeDescription.xlsx` at [https://zenodo.org/record/6420961#.Ymft39PP2Um](https://zenodo.org/record/6420961#.Ymft39PP2Um) and the related [publication](https://doi.org/10.1088/1748-9326/aabd42).

`GP_RTP`: road type (1 = highways, 2 = primary roads, 3 = secondary roads, 4 = tertiary roads, 5 = local roads, 0 = unspecified)

`GP_REX`: road existance (1 = open, 2 = restricted, 3 = closed, 4 = under construction/repair, 0 = unspecified) 

`GP_RAV`: road availability (1 = yes, 2 = no, 0 = unspecified)

`GP_RRG`: road region (see file in Zenodo at the link above)

`GP_RCY`: road county (ISO1 code, see file in Zenodo at the link above)

`GP_RSE`: road surface (1 = paved, 2 = gravel, 3 = dirt/sand, 4 = steel, 5 = wood, 6 = grass, 0 = unspecified)

`GP_RSI`: road source ID (see file in Zenodo at the link above)

`GP_RSY`: year the data source describes the road

`Shape_Leng`: total length of the road in the grid cell (unit: km; see related [paper]( https://doi.org/10.1088/1748-9326/aabd42))

`gp_gripreg`: aggregated region for the GLOBIO website downloads

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
`road_crossings_table.csv`: Overview of the extracted intersections with animalID, roadID, the closest location estimate, the animal and its timestamp, and road properties (see above).
 
`road_crossings_map.png`: Map of roads (blue gradient) of the tracking area, with tracks shown as lines (dark red) and intersections as points (orange). Roads will be colored based on the setting "Column name for street colouring". If no value is provided, the default `GP_RTP`, displayed as "Road property", will show darker colors to indicate more major roads (see details above).

### Settings
**Column name for street colouring (`colour_name`):** Variable of the street data set indicating colouring of roads in output map. Defaults to "GP_RTP" which is road type in the fallback GRIP roads data set.

**Road files (`road_files`):** Metadata allowing the local upload of a roads shapefile in WGS 84 that overlaps with the handled tracking data set.

### Most common errors
*Please describe shortly what most common errors of the App can be, how they occur and best ways of solving them.*

### Null or error handling:
**Setting `colour_name`:** If the selected column name of the road data set does not exist, all roads are coloured in the same colour `blue`. A warning is given.

**Data:** The full input data set with an additional (fictive) individual called "road_crossing" is returned for further use in a next App.
