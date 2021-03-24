library(survey)
library(shiny)

# The lecture video has got all of the bells and whistles you could possibly
# have for the regression

# In this script, we're going to scale it back and talk about
# the 'key features'


# Want to test yourse?
# - pull out the relevant parts of the UI
# and then the server into a new script
# and then compare to this script!


# Loading in my dataframe
load("finaldata2.rda")


# svydesign from survey package adds weights to my observations
comp42.design <- svydesign(id= ~idnumr, data = data, weights = data$nschwt)


server <- function(input, output) {
  #creating a reactive regression forumula that uses inputs from the check list
  #as independent variables to predict the variable ACE_BI
  regFormula <- reactive({
    as.formula(paste("ACE_BI", " ~ ", paste(input$iv1, collapse = "+")))
  })
  
  # then, put that formula into the svyglm() from survey package which outputs
  # a weighted regression
  model <- reactive({
    svyglm(regFormula(), family= quasibinomial, comp42.design)
    
  })
  
  #Create nice regression table output
  #stargazer() comes from the stargazer package
  output$regTab <- renderText({
    stargazer(model(), type = "html", dep.var.labels = "Risk Prediction")
  })
  
  
}




# Notice there is no function here, just the fluidPage()
ui <- shinyUI(fluidPage(tabPanel(
  "Analyzing ACEs",
  headerPanel("ACEs Prediction Model"),
  #The sidebar allows me to select
  #multiple independent variables
  sidebarLayout(
    position = "right",
    sidebarPanel(
      h2("Build your model"),
      br(),
      checkboxGroupInput(
        "iv1",
        label = "Select any of the independent variables below to calculate your model. You can change your selection at any time.",
        c("Race"="Race", 
          "Absent 11 or more days"="Absence", 
          "School contacted home"="Contact",
          "Child rarely completes homework"="Homework",
          "Child receives free lunch"="Lunch", 
          "Child has repeated a grade" = "Retained"), # c
        selected = "Race"
        #Note Race is selected when the app starts
      ) # checkboxGroupInput
    ), #sidebarpanel
    
    
    
    mainPanel(br(),
              #create a 1st tab panel
              tabsetPanel(
                type = "tabs",
                #first panel shows regression table
                tabPanel(
                  "Regression Table",
                  h3("Table of Regression Coefficients"),
                  HTML('</br>'),
                  tableOutput("regTab"),
                  HTML('</br>'),
                  helpText("Describe the model")
                )# tab panel
              )# tabset
    )# mainpanel
  ) #sidebarlayout
) # tab panel
) # fluidpage
) #shinyUI
# This is our new code to merge the server and ui objects into an app!
shinyApp(ui = ui, server = server)
