#########################################
# Place Matters App - Map + graph       #
# Created By: Salomon Villatoro         #
# 3.24.2021                             #
#########################################

setwd("C:/Users/svillatoro/Desktop/Better Data Science/Place Matters app")
library(shinythemes)
library(shiny)
library(rsconnect)
library(mfx)
library(ggplot2)
library(survey)
library(foreign)
library(ggplot2)
library(stargazer)
library(rgdal)
library(plyr)
library(leaflet)
library(dplyr)
library(mapview)
library(tidyverse)
  
#------------------------------------
# Beginning Shiny Code
#------------------------------------
  
  # This line creates the object server
  server <- function(input, output){
    
    #------------------------------------
    # Setting up Place Matters Data
    #------------------------------------
    
    # Load Place data from working directory  
    place_data<- read.csv("place_data.csv")
    
    # Establish bins for color map  
    place_data$riskbin <- with(place_data, 
                               ifelse(place_data$Risk >=75 & place_data$Risk <99, 4, (
                                 ifelse(place_data$Risk >=50 & place_data$Risk <75, 3,(
                                   ifelse(place_data$Risk <50 & place_data$Risk >=25, 2,(
                                     ifelse(place_data$Risk <25, 1, place_data$Risk)
                                   )
                                   ))) )))
    
    # Set up as close a palette you can to Place Matters Map
    pal <- colorFactor(c("#ffe4a8","#ffa45e","#eb7373","#bf3041"), philly@data$riskbin)
    
    # Read shape files onto object 
    philly <- readOGR("Zipcodes_Poly", layer = "Zipcodes_Poly", encoding = "UTF-8")
    names(philly@data)
    
    # Match data to shape file 
    philly@data <- data.frame(philly@data, place_data[match(philly@data$CODE, place_data$CODE),])
    
    # Have pop ups display correct information 
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
    
    #------------------------------------
    # Setting up Philly Leaflet
    #------------------------------------
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
      addLegend("topright", ####location of legend in leaflet app
                colors = c("#ffe4a8","#ffa45e","#eb7373","#bf3041"), #### legend colors to match zip code colors
                labels = c("0 - 24", "25 - 49", "50 - 74", "75 - 98"),#### Bin percentage ranges
                title = "Risk: Lowest to Highest", ###### legend title
                opacity = 1) #### whether the legend will be see through
    
    #------------------------------------
    # Setting up Facet Plot
    #------------------------------------
    facet_data <- as_tibble(read.csv("place_data.csv")) %>% 
      rename("Zipcode" = CODE) #%>% filter(Zipcode == 19103 | Zipcode == 19133)
    
    facet_data$Zipcode <- as.character(facet_data$Zipcode)
    
    facet_columns <- colnames(facet_data)
    
    facet_expanded<- facet_data %>% 
      pivot_longer(c(Risk, Poverty, Education, Unemployment, Crime, ACEs), 
                   names_to = "var", values_to = "percent")

    facet_expanded$var = factor(facet_expanded$var, 
                                levels=c("Risk", "Poverty", "Education", "Unemployment", "Crime", "ACEs"))                     
    facet_averages<- facet_expanded %>% 
      group_by(var) %>% 
      summarise(percent = round(sum(percent, na.rm = TRUE)/length(percent[!is.na(percent)]), 
                                digits = 2),
                Zipcode = "Average"
      )
    facet_averages <- facet_averages[,c(3,1,2)]
    
    phillyZipcodes <- sort(facet_data$Zipcode)
    #------------------------------------
    # Setting up Reactive
    #------------------------------------
    aceRiskA <- reactive({
      if (input$CODE1 != "19104")
      {
        facet1 <- filter(facet_expanded, Zipcode == input$CODE1)
      }
      else {
        facet1 <- filter(facet_expanded, Zipcode == "19104")
      }
    })
    
    aceRiskB <- reactive({
      if (input$CODE2 != "Average")
      {
        facet2 <- filter(facet_expanded, Zipcode == input$CODE2)
      }
      else {
        facet2 <- facet_averages
      }
    })
    
    #------------------------------------
    # Outputs for UI
    #------------------------------------
    output$map <- renderLeaflet(place_map)
    
    output$placeFacet <- renderPlot({
      faceted <- as_tibble(rbind(aceRiskA(), aceRiskB()))
      placeFacet <- ggplot(data = faceted) +
        geom_bar(mapping = aes(x = Zipcode, y = percent, fill = Zipcode), stat = "identity") +
        facet_wrap(~var) + 
        ylab("Percent")+
        ylim(0,100)+
        theme_bw() +
        theme(legend.position = "none") +
        scale_fill_manual(values = c("#554f66", "#c2d1a4")) +
        theme(strip.background = element_rect(fill="#d9d9d9"))
      print(placeFacet)
    })
    }
  
#-----------------------------------#
# UI                                #
#                                   #
#                                   #
#-----------------------------------#
  
  ui <- fluidPage(theme = shinytheme("flatly"),
                  navbarPage("Place Matter App",
                             tabPanel("Welcome",
                                      tags$head(
                                      tags$style("h1 {color: #04B4AE;}
                                                 h4 {color: #04B4AE};}")),#Creates a space, called a break
                                      h1("Place Matters"),
                                      h3("A GIS analysis of children's population health needs and resources in Philadelphia"),
                                      h4("Statistical analysis (multivariate logistic regression) used data from the 2013 
                                           Philadelphia Expanded Adverse Childhood Experience (ACE) 
                                           Survey to test the impact of perceived neighborhood trust 
                                           and safety during childhood, witnessing violence during childhood, 
                                           and overall adverse childhood experiences on the reported mental 
                                           health of Philadelphia adults. ")),
                             #first tab showing the map
                             tabPanel("Mapping Risk & Resilience",
                                      leafletOutput("map", width = "100%", height = "800px")),
                             
                             #second tab showing the graph
                             tabPanel("Analyzing Risk in Philadelphia",
                                      headerPanel("Compare Risk Index Factors Across Zip Codes"),
                                      br(),
                                      h2(""),
                                      #creating the sidebar
                                      sidebarLayout(
                                        sidebarPanel(
                                          selectInput(
                                            "CODE1",
                                            "Zip Code of Interest",
                                            c(phillyZipcodes, "Average")
                                          ),
                                          selectInput(
                                            "CODE2",
                                            "Benchmark Zip Code",
                                            c(phillyZipcodes, "Average")),
                                          h5("Horizontal lines indicate national averages")
                                        ),
                                        mainPanel(
                                          plotOutput("placeFacet")
                                        )
                                      ),
                                      h5("Risk : A composite index of measures of poverty, education, unemployment, crime and ACEs",
                                         "Poverty : Percent of families with children below the poverty level",
                                         "Education : Percent with less than 9th grade education",
                                         "Unemployment : Percent of unemployed",
                                         "Crime : Shooting victims per 10,000",
                                         "ACEs : Percent with at least one Adverse Childhood Experience")
                             )
                  )
  )

  #-----------------------------------#
  # Final Shiny App                   #
  #                                   #
  #                                   #
  #-----------------------------------#
  shinyApp(ui = ui, server = server)
  










































