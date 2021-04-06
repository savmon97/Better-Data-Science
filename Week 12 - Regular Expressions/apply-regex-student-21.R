#-------------------------
# Apply Regex
#-------------------------

#Let's use regular expressions in a dataset

# Read in Clery crime log data from University of Oregon
# and examine the variables
df <- read.csv("clerylog.csv", header = TRUE, sep=",")
View(df)


# Problem 1: 
# Clean up classifications in the nature variable
# by removing the level of offenses (ie. the numbers 1, 2)
df$Nature <- gsub('[0-9]', '',df$Nature)



# Problem 2: 
# A. Create a dummy variable that indicates if each row
# is a theft or not. 
df$isTheft <- with(df, ifelse(grepl('Theft', Nature) == TRUE, 1,0))

# B. Create a dummy variable that indicates if each row is a DUI
df$isDUI <- with(df, ifelse(grepl('DUI', Nature) == TRUE, 1,0))

# C. Create a dummy variable that indicates if each row is a drug offense
df$isDrug <- with(df, ifelse(grepl('(Drug|Heroin|Marijuana|Meth)', Nature) == TRUE, 1,0))



# Problem  3: Use gregexpr() to  find observations that are associated
# with either heroin, marijuana, or meth

gregexpr()



# Problem 4: Create a new column with JUST the date (or date range) the crime occurred





