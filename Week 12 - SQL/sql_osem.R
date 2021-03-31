#-------------------------------------------
# Script on SQL                     
# Purpose: Introduce SQL databases  
# and SQL inquires in R             
#-------------------------------------------

# This lessons introduces you to SQL
# or structured queries languages in R

# Install the sqldf package
library(sqldf)

# We will use occupational employment statistics data
# The file is somewhat large (N > 430,000)

# For details, see http://www.bls.gov/oes/current/oes_stru.htm

# Peek at the first few rows of the dataset 
read.table("oesm.csv", sep=";", header = TRUE, fill = TRUE, nrows = 5)

#-------------------------------------------
# Making SQL Databases/Tables 
#-------------------------------------------

# Begin SQL processing by creating a new database
# Then add tables - THOR - we need to create a bifrost, but it will remain temporary

{
  # connect to or create a new SQlite database
  conemp <- dbConnect(SQLite(), dbname = "oesm2015.db")
  # remove a oesm tables if they already exist
  if(dbExistsTable(conemp, "oesm")) dbRemoveTable(conemp, "oesm")
  
  # import the cleaned data file into RSQLite
  dbWriteTable(conemp, "oesm", 
               "oesm.csv", sep = ";", header = TRUE,
               row.names = FALSE) #" RSQLite doesn't handle commas in quotes
  # find what fields exist in your new table
  # dbListFields(conemp, "oesm")
  # disconnect from a database after session
  dbDisconnect(conemp)
}

# Now let's check that our connection is working properly. 
# We'll run some code to check if we have data for all columns
# and display first 10 rows

# All columns is given by *
conemp <- dbConnect(SQLite(), dbname = "oesm2015.db")
res <- dbSendQuery(conemp, "
                   SELECT *
                   FROM oesm")
fetch(res, n = 10)

# after fetching result, clear it
dbClearResult(res)

# Then select subset of columns
res <- dbSendQuery(conemp, "
                   SELECT occtitle,grouping,h_mean 
                   FROM oesm")
fetch(res, n = 10)
dbClearResult(res)

#-------------------------------------------
# Running SQL Inquiries 
#-------------------------------------------

# WHERE filters the rows we want

res <- dbSendQuery(conemp, "
                   SELECT occtitle, h_mean, area_title
                   FROM oesm
                   WHERE (GROUPING=='major')")
fetch(res, n = 10)
dbClearResult(res)

# Use AND or OR as '&' and '|'
res <- dbSendQuery(conemp, "
                   SELECT occtitle, h_mean, naics_title, year 
                   FROM oesm
                   WHERE (naics=='541380') AND (GROUPING=='broad') AND (occtitle=='Market Research Analysts and Marketing Specialists')
                   ")
# We can use '-1' to fetch all results
fetch(res, n = -1)
dbClearResult(res)


# DISTINCT operates like unique() (no duplicates)
res <- dbSendQuery(conemp, "
                   SELECT DISTINCT naics
                   FROM oesm")
fetch(res, n = -1)
dbClearResult(res)
# Here we have 470 distinct industry classifications
# If we didn't use DISTINCT, fetch would return 
# all of the rows from the naics column!


# AVG MIN MAX COUNT and SUM are aggregating functions
# Find the average of all median hourly wages
res <- dbSendQuery(conemp, "
                   SELECT AVG(h_median)
                   FROM oesm
                   WHERE (grouping=='total')
                   ")
fetch(res, n = -1)
dbClearResult(res)

# Count number of observations for each year
# You must also add the group by option
res <- dbSendQuery(conemp, "
                   SELECT COUNT(*) AS annualwagecount,year
                   FROM oesm
                  GROUP BY year
                   ")
fetch(res, n = -1)
dbClearResult(res)

# Find minimum and maximum of median annual salary
res <- dbSendQuery(conemp, "
   SELECT MIN(a_median) AS min_salary,
                   MAX(a_median) AS max_salary, year
                   FROM oesm
                   GROUP BY year
                   ORDER BY year")
fetch(res, n = -1)
dbClearResult(res)
# Uh oh! what happened?



# SQL can ignore NAs similar to R! Just with more words
res <- dbSendQuery(conemp, "
   SELECT MIN(a_median) AS min_salary,
                   MAX(a_median) AS max_salary
                   FROM oesm
                  WHERE (a_median IS NOT 'NA')
                   GROUP BY year
                   ORDER BY year")
fetch(res, n = -1)
dbClearResult(res)
# Uh oh! What's up with this?

# SQL doesn't have the same data classes as R
# We can perform math functions on 
# columns with numbers and characters!
# This website does a nice job of laying out more info:
# https://www.w3schools.com/sql/sql_datatypes.asp

# Let's get rid of that '#'

# UPDATE will update the values in your SQL table
res <- dbSendQuery(conemp, "
   UPDATE oesm SET a_median='187200' 
   WHERE (a_median='#')
                   ")
dbClearResult(res)

res <- dbSendQuery(conemp, "
   SELECT MIN(a_median) AS min_salary,
                   MAX(a_median) AS max_salary
                   FROM oesm
                  WHERE (a_median IS NOT 'NA')
                   GROUP BY year
                   ORDER BY year")
fetch(res, n = -1)
dbClearResult(res)

#-------------------------------------------
# Using multiple tables 
#-------------------------------------------
# Create new tables from same database
res <- dbSendQuery(conemp, "
                   CREATE TABLE occup As
                   SELECT DISTINCT occcode,occtitle
                    FROM oesm
                   ")
dbClearResult(res)

# See that have another table added
dbListTables(conemp)

dbListFields(conemp,"occup")

# Check if have distinct occupation codes
res <- dbSendQuery(conemp, "
                   SELECT occcode
                   FROM occup")
fetch(res, n = 20)
dbClearResult(res)


# Add another table about areajobs
# Distinct will apply to all columns that follow (unique area & area_title_occcode, etc)
res <- dbSendQuery(conemp, "
                   CREATE TABLE areajobs AS
                   SELECT DISTINCT area, area_title, occcode, tot_emp, jobs_1000, year
                   FROM oesm
                   ")
dbClearResult(res)

res <- dbSendQuery(conemp, "
                   SELECT *
                   FROM areajobs")
fetch(res, n = 20)


############################################
####### Using JOINS #############
############################################

# Find total number of people employed
# by area who are math/stat 
# using the occupation table
# and the area jobs table

res <- dbSendQuery(conemp, "
                   SELECT SUM(tot_emp),area_title
                   FROM areajobs
                      INNER JOIN occup
                      ON areajobs.occcode = occup.occcode
                   WHERE occup.occtitle=='Mathematicians' OR
                         occup.occtitle=='Statisticians'
                   GROUP BY areajobs.area")
data <- fetch(res, n = -1)
dbClearResult(res)
# show first ten results
data[1:10,]
# show results in PHL area
data[134,]

# find the average number of total employed people
# by occupation title
# in the PHL area
res <- dbSendQuery(conemp, "
                   SELECT AVG(tot_emp) AS totalemp, occtitle
                   FROM areajobs
                   INNER JOIN occup
                   ON areajobs.occcode=occup.occcode
                   WHERE (areajobs.area_title=='Philadelphia-Camden-Wilmington, PA-NJ-DE-MD')
                  GROUP BY occup.occtitle
                    ")
# save result in R
data <- fetch(res, n = -1)

# find minimum number of people employed in sector
min(data$totalemp)
# which minimum is observation found
which.min(data$totalemp)
# Find the occupation-- agricultural engineers
data[13,]

