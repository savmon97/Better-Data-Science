#-----------------------------------#
# User-interface Script             #
# Mapping I                         #
#-----------------------------------#

# Your UI script should contain your library
library(shinythemes)
library(shiny)
library(rgdal)
library(plyr)
library(leaflet)
library(dplyr)
library(mapview)


# This line is necessary for a ui script. The arument theme = "x", is optional. 
# It determines if you are using a pre-made theme design - just like themes in ggplot.
# Here, I am using the flatly theme. We will explore theme options later on 
# in the course. 
shinyUI(fluidPage(theme = shinytheme("darkly"),
                  
                                      # Set the style for the header
                                      tags$head(
                                        tags$style("h2 {color: #00000}
                                                   h4 {color: #95fcaa}; }
                                                   ")),
                                      # Create a title
                                      headerPanel("Mapping Philadelphia Zip Codes by Perceived Risk"),
                                      br(), # br() is borrowed from html. It creates a space, called a break
                                      h4("Statistical analysis (multivariate logistic regression) used data from the 2013 
                                         Philadelphia Expanded Adverse Childhood Experience (ACE) 
                                         Survey to test the impact of perceived neighborhood trust 
                                         and safety during childhood, witnessing violence during childhood, 
                                         and overall adverse childhood experiences on the reported mental 
                                         health of Philadelphia adults. "), # Another way to create a space is to add an empty text space. If there were 
                                              # text inside those parenthesis, it would be printed in the app. Try it!
                  
                                      # This line controls the size of the map. I have set the width to 100% - this will
                                      # adjust the map to the size of any screen it is displayed on. 
                                      # The height is measured in px because I do want to control that length 
                                      # Most importantly, notice "map" is coming from the server script
                                      leafletOutput("map", width = "100%", height = "800px")
                                      
                                      
                             ))
