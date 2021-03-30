#---------------------------------------------
# Googlesheets4 
#---------------------------------------------


#----------------------------------------------
# steps to be taken before running this script

# 1. create a gmail account if you don't have one 
# already

# 2. create a googlesheet to read in



# It is important for you to create a new folder
# for session and set your working directory to that
# folder. Don't skip this step!
setwd("C:/Users/svillatoro/Desktop/Better Data Science/Intro to automation/googlesheets lecture")


#----------------------------------------------

# We're going to focus on how to use googlsheets4 to integrate
# with Shiny, but before that, let's see how the package
# works with a regular R script.


# install.packages("googlesheets4")
library(googlesheets4)

# simplest way to read in a googlesheet
# is with read_sheet() 

# you can read in a sheet via its URL or its 'sheet ID'
# sheets_get() returns information about the sheet

# When you run this line, you will be asked to authenticate yourself 
# as a specific google user - basically, you're letting Google know who
# you are and what you're doing. This is an important step
# that we'll discuss in detail a little later in this script. 
sheets_get("https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022")

# read in the sheet
# This sheet contains your answers to the GAFL 531 survey that I sent out earlier
gafl <- read_sheet("https://docs.google.com/spreadsheets/d/1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ/edit#gid=896338022", sheet = 1, col_types = "c", na = "")


# how to find sheet ID:

# in the URL above, the ID is "1pqDBVbSxUdZ5-WvDY7-GQm0DBbPEPm8Ni-3aLqR46SQ"


# If you're familiar with the googledrive package, you can
# also use drive_get()



#----------------------------------------------
# Integrate with a Shiny app
#----------------------------------------------

# Notice how you had to perform an interactive action
# in order to read in the sheet (authenticate yourself as
# a specific google user)

# This action won't work for a shiny app that is on a server

# We can get around it by creating a 'permission' - a secret
# file that will live in your app folder that will
# recognize the shiny app as you when it tries to access
# the google sheet


#-------------------------------
# Step 1: Create a permission

# We're going to use the googledrive
# package to set up some preferences

# install.packages("googledrive")
library(googledrive)

#----
# SET YOUR WORKING DIRECTORY TO YOUR APP SCRIPT

# your permission is going to 'save' to wherever 
# your working diretory is set to

#---

# We're going to obtain a toke for noninteractive use -
# meaning, we're going to tell googledrive we want
# to save a secret file that will contain 
# a permission we can use 'noninteractively' 

# Its sort of like saving your password for a website
# so that you don't have to type it in everytime

# designate project-specific cache
options(gargle_oauth_cache = ".secrets")

# we've told the package that we're using 
# the specified cache 
gargle::gargle_oauth_cache()

# Next, we'll trigger an authentication
# on purpose and store that authentication token
# in the specified cache

# The authentication process will pop up interactively
# and you will need to follow the prompt to paste your token
# into console
drive_auth(use_oob = TRUE)


# Run this function to see if your authentication token has 
# succesfully saved - if it has, you will see your 
# token followed by your email address
list.files(".secrets/")


#--------------------------------------------
# Seeing secret files
#--------------------------------------------

# At this point, open up your working directory folder

# We've saved your authetication in the secrets cache

# You probably don't have your computer set up to see 
# secret files. 

# To view secret files on a mac, go into the folder
# and press 'command+shift+.'

# on a PC, try:
# 
# Select the Start button, 
# then select Control Panel > 
#   Appearance and Personalization. 
# Select Folder Options, then select the
# View tab. Under Advanced settings, select 
# Show hidden files, folders, and drives, 
# and then select OK.

# You may need to look up the PC steps for different
# versions of windows


# Once you have changed your options to see your hidden files,
# you should see a folder called ".secrets"

# if you go into that folder, you should see a file that
# is your authentication. 

# pretty cool!


# Now, just like saving a password for a website
# has some pros and cons, so does saving your authentication.

# If you choose to create a file like this, be very careful
# about how you share this file - just like how you wouldn't
# let just anyone use your computer that has your 
# password saved for your online banking. 


#--------------------------------------------
# Integrating with a Shiny app
#--------------------------------------------

# At this point, we should be ready to use 
# our saved authentication with a Shiny app


