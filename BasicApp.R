# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------
# Grayson Peters
# 02/03/2020
# GAFL 531: Data Science for Public Policy
# In-class Shiny Exercise
# -----------------------------------------------------------------------------------
# -----------------------------------------------------------------------------------

# Show this app first!


library(tidyverse)
library(shiny)
library(shinythemes)
library(rgdal)
library(leaflet)
library(rio)
library(fresh)


philly <- readOGR("Zipcodes_Poly", layer = "Zipcodes_Poly")
phl_data <- import("place_matters.csv")
phl_data_untouched <- phl_data

phl_data[47,1] <- "City Average"

for(i in 2:7){
  phl_data[47, i] <- mean(phl_data[,i], na.rm = T)

}

phl_data2 <- gather(phl_data,
                    variable,
                    measure, -1)

philly@data <- data.frame(philly@data, phl_data[match(philly@data$CODE, phl_data$CODE),])

philly@data$RiskF <- factor(philly@data$RiskF)



ui <- shinyUI(
  fluidPage(navbarPage("Place Matters App",
                       tabPanel("Mapping Risk and Resilience",
                                br(),
                         leafletOutput("map"),
                               br()),
                       tabPanel("Analyzing Risk in Philadelphia",
                                sidebarLayout(sidebarPanel(width = 2, selectInput("ZIP1",
                                                                       label = "Zip Code of Interest",
                                                                       choices = phl_data$CODE,
                                                                       selected = "19133"),
                                                           selectInput("ZIP2",
                                                                       label = "Benchmark Zip Code",
                                                                       choices = phl_data$CODE,
                                                                       selected = "City Average"),
                                                           br(),
                                                           "Horizontal lines indicate national averages."),
                                              mainPanel(plotOutput("plot",
                                                                   width = "125%",
                                                                   height = "500px"),
                                                        h4(br(),
                                                        strong("Risk:"),"A composite index of measures of poverty, education, unemployment, crime and ACEs",
                                                        br(),
                                                        strong("Poverty:"), "Percent of families with children below the poverty level",
                                                        br(),
                                                        strong("Education:"), "Percent with less than 9th grade education",
                                                        br(),
                                                        strong("Unemployment:"), "Percent unemployed",
                                                        br(),
                                                        strong("Crime:"), "Shooting victims per 10,000",
                                                        br(),
                                                        strong("ACEs:"), "Percent with at least 1 Adverse Childhood Experience",
                                                        br(),
                                                        br())))),
                       tabPanel("Explore the Risk Index Data",
                                dataTableOutput("datatable")))

)
)

server <- shinyServer(function(input, output) {

  ## Make the popup:

  philly_popup <- paste0("<strong>ZIP Code: </strong>",
                         philly@data$CODE,
                         "<br><br><strong>Risk Index: </strong>",
                         paste0(philly@data$Risk, "%"),
                         "<br><strong>Poverty: </strong>",
                         paste0(philly@data$Poverty, "%"),
                         "<br><strong>Education: </strong>",
                         paste0(philly@data$Education, "%"),
                         "<br><strong>Unemployment: </strong>",
                         paste0(philly@data$Unemployment, "%"),
                         "<br><strong>Crime: </strong>",
                         paste0(philly@data$Crime, "%"),
                         "<br><strong>ACEs: </strong>",
                         paste0(philly@data$ACEs, "%"))

  # Make a color palette using a divergent from RColorBrewer

  phl_pal <- colorFactor(c("#FFFF44", "orange", "red1", "red4"), philly@data$RiskF)

  ## Make the map:

  map <- leaflet(philly) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(stroke = T,
                fill = T,
                fillColor = ~phl_pal(RiskF),
                color = "white",
                weight = 0.75,
                fillOpacity = 0.75,
                popup = philly_popup) %>%
    addLegend("bottomright",
              colors = c("#fefe71", "#fe733e", "#fe3f3e", "#a63f3e"),
              labels= c("0 - 24", "25 - 49","50 - 74","75 - 98"),
              title= "Risk: Lowest to Highest",
              opacity = 1)

  output$map <- renderLeaflet(map)

  # -----------------------------------------------------------------------------------



  output$plot <- renderPlot({

    phl_filtered <- phl_data2 %>%
      filter(CODE == input$ZIP1 | CODE == input$ZIP2)

    phl_filtered$variable <- factor(phl_filtered$variable, levels = c("RiskF", "Risk", "Poverty", "Education", "Unemployment", "Crime", "ACEs"))
    phl_filtered$CODE <- factor(phl_filtered$CODE, levels = c(input$ZIP1, input$ZIP2))
    hline.data <- tibble(variable = c("Risk", "Poverty", "Education", "Unemployment", "Crime", "ACEs"),
                         line = c(0, 17.6, 5.8, 5, 3.7, 63.9))
    hline.data$variable <- factor(hline.data$variable)

    ggplot() +
      geom_bar(data = phl_filtered %>% filter(variable != "RiskF"),
               mapping = aes(x = CODE, y = measure, fill = CODE),
               stat = "identity") +
      facet_wrap(~variable) +
      geom_hline(data = hline.data, mapping = aes(yintercept = line)) +
      labs(x = element_blank(),
           y = "Percent") +
      theme_bw() +
      theme(legend.position = "none",
            text = element_text(color = "black"),
            axis.text = element_text(size = 14, color = "black"),
            axis.title = element_text(size = 18),
            strip.text = element_text(size = 14)) +
      scale_fill_manual(values = c("#574c67", "#bdd5a3"))

  })

  output$datatable <- renderDataTable({

    dta <- phl_data_untouched[1:7]
    dta

  })


})

shinyApp(ui, server)
