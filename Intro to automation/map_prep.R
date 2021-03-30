# Leaflet map for googlesheets4 app
library(googlesheets4)
library(googledrive)

# SET YOUR WORKING DIRECTORY TO WHERE YOUR PERMISSION IS

# Now, we need some code to read in our data

# Tell R that you are going to use a permission that
# is saved in the file 'secrets'
options(
  gargle_oauth_cache = ".secrets",
  gargle_oauth_email = TRUE
)

# authorize the scope to 'read only' - for privacy!
sheets_auth(token = drive_token(),
            scopes="https://www.googleapis.com/auth/spreadsheets.readonly")

# Now we can open up that sheet 
sheets_get("https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022")

# Bring it into the object gafl
gafl <- read_sheet("https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022", sheet = 1, col_types = "c", na = "")


# And now we're ready to make our map like normal!

head(gafl)

# Set up the colors for the different schools
table(gafl$School)
factpal <- colorFactor(c("#990000", 
                         "#011F5B",
                         "#000000"
                         ), gafl$School)



leaflet()  %>% 
  addTiles('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png') %>%
  addCircleMarkers(~as.numeric(Longitude), 
                   ~as.numeric(Latitude), 
                   data = gafl, 
                   color =  ~factpal(School), 
                   radius = 8, 
                   weight = 1, 
                   fillOpacity = 1, 
                   popup = paste("Name:", gafl$Name, "<br>",
                                 "Graduation:", gafl$`What year do you intend to graduate from Penn?`
                                 ))%>%
  addLegend("bottomright", 
            colors =c("#990000", 
                      "#011F5B",
                      "#000000"),
            labels= c("Engineering", 
                      "Arts and Sciences", 
                      "Design"),  
            title= "Penn Family",
            opacity = 1) 



# BUT WAIT
# We need to check - what could go wrong? 

# This map is made only with data that is currenlty in our dataset,
# it does not anticipate possible additional answers

# For example:

# We currenlty have 3 schools represented
table(gafl$School)

# But there are actually 4 answer choices on the survey!
# no one has selected Wharton so far

# If someone did select wharton, this code would
# not define a color for Wharton, so their circle
# would show up as gray or NA

# How do you think we would code for this scenario?










# Define a factor level!

gafl$School <- factor(gafl$School)
levels(gafl$School)


# Instead, do:
gafl$School <- factor(gafl$School, levels = c("Penn Engineering", "School of Arts and Sciences", "The School of Design", "The School of Nursing", "The Wharton School"))
levels(gafl$School)

table(gafl$School) #cool!


# Now we can define some color codes for these schools
# Set factor levels for 
table(gafl$School)
factpal <- colorFactor(c("#990000", 
                         "#011F5B",
                         "#000000",
                         "#b2df8a",
                         "#7570b3"
), gafl$School)



leaflet()  %>% 
  addTiles('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png') %>%
  addCircleMarkers(~as.numeric(Longitude), 
                   ~as.numeric(Latitude), 
                   data = gafl, 
                   color =  ~factpal(School), 
                   radius = 8, 
                   weight = 1, 
                   fillOpacity = 1, 
                   popup = paste("Name:", gafl$Name, "<br>",
                                 "Graduation:", gafl$`What year do you intend to graduate from Penn?`
                   ))%>%
  addLegend("bottomright", 
            colors =c("#990000", 
                      "#011F5B",
                      "#000000",
                      "#b2df8a",
                      "#7570b3"),
            labels= c("Engineering", 
                      "Arts and Sciences", 
                      "Design", 
                      "Nursing", 
                      "Wharton"),  
            title= "Penn Family",
            opacity = 1) 

# And now we're ready to move this code into an app!

