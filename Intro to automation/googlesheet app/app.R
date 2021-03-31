# App for 531 googlesheets

# Library
library(shiny)
library(data.table)
library(ggplot2)
library(shinythemes)
library(rgdal)
library(plyr)
library(leaflet)
library(dplyr)
library(ggthemes)
library(tidyr)
library(leaflet)
library(rsconnect)
library(googlesheets4)
library(googledrive)


server <- function(input, output) {
  # read in data from google sheet
  # Tell R that you are going to use a permission that
  # is saved in the file 'secrets'
  options(gargle_oauth_cache = ".secrets",
          gargle_oauth_email = TRUE)
  
  # authorize the scope to 'read only' - for privacy!
  sheets_auth(token = drive_token(),
              scopes = "https://www.googleapis.com/auth/spreadsheets.readonly")
  
  # Now we can open up that sheet
  sheets_get(
    "https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022"
  )
  
  # Bring it into the object gafl
  gafl <-
    read_sheet(
      "https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022",
      sheet = 1,
      col_types = "c",
      na = ""
    )
  
  
  #-------------------
  # Presenter Map
  #-------------------
  
  gafl$School <-
    factor(
      gafl$School,
      levels = c(
        "Penn Engineering",
        "School of Arts and Sciences",
        "The School of Design",
        "The School of Nursing",
        "The Wharton School"
      )
    )
  levels(gafl$School)
  
  table(gafl$School) #cool!
  
  
  # Now we can define some color codes for these schools
  # Set factor levels for
  table(gafl$School)
  factpal <- colorFactor(c("#990000",
                           "#011F5B",
                           "#000000",
                           "#b2df8a",
                           "#7570b3"),
                         gafl$School)
  
  
  
  map <- leaflet()  %>%
    addTiles('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png') %>%
    addCircleMarkers(
      ~ as.numeric(Longitude),
      ~ as.numeric(Latitude),
      data = gafl,
      color =  ~ factpal(School),
      radius = 8,
      weight = 1,
      fillOpacity = 1,
      popup = paste(
        "Name:",
        gafl$Name,
        "<br>",
        "Graduation:",
        gafl$`What year do you intend to graduate from Penn?`
      )
    ) %>%
    addLegend(
      "bottomright",
      colors = c("#990000",
                 "#011F5B",
                 "#000000",
                 "#b2df8a",
                 "#7570b3"),
      labels = c(
        "Engineering",
        "Arts and Sciences",
        "Design",
        "Nursing",
        "Wharton"
      ),
      title = "Penn Family",
      opacity = 1
    )
  
  
  output$map <- renderLeaflet(map)
  
  
  #-------------------
  # Data Table - Presentations
  #-------------------
  
  
  
  output$table2 <- DT::renderDataTable(DT::datatable({
    data4 <- gafl[, c(2, 3, 4, 7)]
    colnames(data4) = c('Name', 'School', 'Birth place', 'Graduation')
    return(data4)
  }))
  
  
  
  
}


#-----------------------------------#
# UI #
#-----------------------------------#
library(shinythemes)
library(leaflet)

ui <- shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  navbarPage(
    "GAFL 531 Class of 2020",
    tabPanel("Map",
             leafletOutput(
               "map", width = "100%", height = "600px"
             )),
    tabPanel(
      "Presentations Data",
      headerPanel("Examine the Presentation Data"),
      # Create a new Row in the UI for selectInputs
      fluidRow(DT::dataTableOutput("table2"))
    )
  )
))

shinyApp(ui = ui, server = server)
