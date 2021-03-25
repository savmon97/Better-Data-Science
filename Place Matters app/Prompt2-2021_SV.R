#--------------------------------------------------------------------
# Prompt 2
#--------------------------------------------------------------------


# 1. Recreate the Place Matters map : Due Monday at 10:30am
# On Canvas, you will find:

# a. Data from the Place Matters report
# b. A shapefile for zip codes in Philadelphia

# Get as close to the map in the app as possible - look up
# the HTML color codes, format the pop-ups as closely as you can

# Turn into Canvas:
# 1. R script with your code to create the map
# 2. A png or jpeg of your finished map

###setwd("Wherever your prompt 2 folder is)

##### Installing and Librarying proper packages
  install.packages("leaflet")
  library(leaflet)
  install.packages("rgdal")
  library(rgdal)
  install.packages("mapview")
  library(mapview)

##### Load Place data from working directory  
  place_data<- read.csv("place_data.csv")

##### Establish bins for color map  
  place_data$riskbin <- with(place_data, 
                             ifelse(place_data$Risk >=75 & place_data$Risk <99, 4, (
                               ifelse(place_data$Risk >=50 & place_data$Risk <75, 3,(
                                 ifelse(place_data$Risk <50 & place_data$Risk >=25, 2,(
                                   ifelse(place_data$Risk <25, 1, place_data$Risk)
                                 )
                               ))) )))



#################### read shape files onto object 
  philly <- readOGR("Zipcodes_Poly", layer = "Zipcodes_Poly", encoding = "UTF-8")
  names(philly@data)
  
  ##### Set up as close a palette you can to Place Matters Map
  pal <- colorFactor(c("#ffe4a8","#ffa45e","#eb7373","#bf3041"), philly@data$riskbin)
################### match data to shape file 
  philly@data <- data.frame(philly@data, place_data[match(philly@data$CODE, place_data$CODE),])

################### have pop ups display correct information 
  philly_popup <- paste("<b style='font-weight: 900;'>Zip Code: </b>",
                        philly@data$CODE,
                        "<br>",
                        "<br><b style='font-weight: 900;'>Risk Index: </b>",
                        philly@data$Risk, "%",
                        "<br><b style='font-weight: 900;'>Poverty: </b>",
                        philly@data$Poverty, "%",
                        "<br><b style='font-weight: 900;'>Education: </b>",
                        philly@data$Education, "%",
                        "<br><b style='font-weight: 900;'>Unemployment: </b>",
                        philly@data$Unemployment, "%",
                        "<br><b style='font-weight: 900;'>Crime: </b>",
                        philly@data$Crime, "%",
                        "<br><b style='font-weight: 900;'>ACEs: </b>",
                        philly@data$ACEs, "%"
                        )

###### set up philly leaflet
  place_map <- leaflet(philly) %>% 
    clearBounds() %>% #### center in on Philadelphia bounds
    addProviderTiles("CartoDB.Positron") %>% #### choose map styke
    addPolygons(stroke = TRUE, ###### include borders
                color = "#c4c4c4", ####### bordor color that matches place matter
                weight = 1, # thickness of borders
                smoothFactor = 0.1, #### smoothness of border
                fillOpacity = 0.9, #### the opacity (how see through) the shape is
                fillColor = ~pal(riskbin), ####### how to fill which zipcode by what information
                popup = philly_popup) %>% ######## allow pop ups to show up
  addLegend("bottomright", ####location of legend in leaflet app
            colors = c("#ffe4a8","#ffa45e","#eb7373","#bf3041"), #### legend colors to match zip code colors
            labels = c("0 - 24", "25 - 49", "50 - 74", "75 - 98"),#### Bin percentage ranges
            title = "Risk: Lowest to Highest", ###### legend title
            opacity = 1) #### whether the legend will be see through
  place_map

##### save screenshot of leaflet app
mapshot(place_map, 
        file ="place_map.png",
        remove_controls = c("zoomControl", "layersControl", "homeButton", "scaleBar",
                            "drawToolbar", "easyButton"))




