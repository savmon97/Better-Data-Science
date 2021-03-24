#-----------------------------------------------------------
# Basic Statistics with R
#-----------------------------------------------------------

# We are going to introduce basic inferential statistics
# in a very 'applied' way. We are not going to dig deep
# into these topics. 

# I see this script as serving two purposes:

# 1. For those who have not had a stats class: a very
# basic introduction to tools that are available. 
# Goal: if you read about these techniques in an article that
# uses them, you can get the 'gist' but no necessarily
# 100% know how to use the technique faultlessly 

# 2. For those who have had a stats class: if you took
# the class in R, this is a refresher. If you didn't take
# the call using R, these are the most common functions. 

# I do intend to have a class on methods where we 
# can talk about the sampling distribution and actually
# understand what is going on if that is something
# you are interested in!  


# What is inferential statistics? 
# Basically, it is using math and probability and R
# to make your best guess about something that is true
# in the world, based on having a 'sample' of data. 

# For example, let's say I want to know how many
# hours each night students at penn sleep. (population: Penn Students)
# I want to know the average! 

# Now, there is certainly a 'true' number: last night happened.
# students did something last night concerning sleeping 
# (or didn't sleep whatever still counts)
# And if I had unlimited time and resources I could in theory ask each and
# every one of you and find the average hours you all slept last night

# But that would be terrible. I do not want to talk to every penn student. 

# What's a gal to do? I can take a sample: I could ask 100 students
# and random, and then use the information i learn about those
# 100 students (sample)

# In the public sector, we do this with polls/surveys
# and also non-survey data to check for regulations/equity/reporting


#-----------------------------------------------------------
# Creating a confidence interval
#-----------------------------------------------------------
# What is a confidence interval? 
# Basic definition: a confidence interval is this survey's best
# guess at what the true value is. It is not a singular 
# point, but a range. The true value is likely 
# somewhere within that range. 

# This can absolutely be wrong (and 5% of the time, it is 
# definitely wrong!) but we really don't know if a result is 
# right or not. We're just doing our best! 

# You create a confidence interval around a mean to show 
# the survey's best guess. This range can also tell a reader
# how much 'guessing room' is in the data based on how wide
# the range is

# A small range is good! It indicates that there are only
# a few values that could be the true value!

# A large range isn't necessarily 'bad' but it does create some
# problems: a large range means we're not too sure what the
# true value could be. 

# Let's see an example! 


load("nlsw88.rda")

# Let's first find the actual mean of this data:

# mean
mean <- mean(nlsw88$wage)
mean

#---
# If you've taken a stats class before, we could do all of the following
# 'by hand' by calculated the standard error and the sd

# We can calculate each individually
#standard error
stdError <- sd(nlsw88$wage)/sqrt(length(nlsw88$wage))

# standard dev
sd <- sqrt(var(nlsw88$wage)) # standard deviation alternative to sd(nlsw88$wage)


#---

# To find a CI in R, we can use the t.test() function
t.test(nlsw88$wage)

#--
# For those with some stats, here's what's happening:
# We can run a 1 sample hypothesis test on the wage column of our data
# with this test, we're setting the null hypothesis as: the true mean
# of wages is 0, and the alternative as not zero

# R then returns not only the p-value that would help us
# determine an answer (in this case, p is so small, we
# can reject the null that the true parameter =0!) 
# but also lots of useful info!
# Check out the confidence interval!


# The function is programmed to automatically use the 95% confidence
# level and run a two sided hypothesis test

# We can change both!

# first, let's change the confidence level to 90%
# so that we get a confidence interval for alpha =.10
t.test(nlsw88$wage, conf.level = .90)
#--

# Above, we were using a mean
# but sometimes, we might want to get an estimate of the percentage 
# of respondents who believe 'x'

# That is technically proportional data (it follows a different distribution
# and thus the math is ever so slightly different)
# For proportional data, we use the prop.test() function:
library(mosaic)
prop.test(nlsw88$never_married)

# Notice, however, that t.test will give you the exact same answer:
t.test(nlsw88$never_married)


#----------------------------------------------------------
# Running a hypothesis test 

# What is a hypothesis test?
# A hypothesis test helps us determine if a result is 'statistically significant'

# Which basically means- is the number that we calculated in our 
# data likely due to chance? Or, is it likely that we might have actually
# picked up on something real in our sample. 

# This can be very helpful to us when we are interested in differences
# between groups, for example: are democrats more likely to indicate
# that they will get the COVID vaccine than republicans?

# in any given sample, the numbers will likely vary
# a hypothesis test uses probability to let us know 
# if a difference we find is likely a real, true difference
# or if its just 'noise' 



# Suppose we now want to run a two sample t-test determining whether
#union workers have a different average wage than non-union workers
t.test(wage ~ union, data = nlsw88)

# We say the difference is real 
# if the p value is less than 0.05


#-----------------------------------------------------------
# Running a basic linear regression 
#-----------------------------------------------------------
# What is regression?
# A regression function takes data and uses it to describe
# relationships between datapoints (variables) and allows us
# to predict outcomes based off of those variables

# For example, if I surveyed people about their education,
# politics, gender and also about whether or not they will get the vaccine,
# i could predict based off that information, what a person
# who WAS NOT A PART OF THAT SAMPLE would do about the vaccine
# if i knew their education, politics, and gender. 

# if you remember y = mx + b from high school, this is
# honestly the exact same thing just on steriods. 


# Let's see an example!
head(nlsw88)

# We're going to try to predict a person's wage
# based only on their tenure (how long they've worked
# at their job) and whether or not they graduated
# from college. 

# before we begin: what would you 'directionally' expect?

# Let's see what the data says:
fit1 <- lm(wage ~ tenure + collgrad, data = nlsw88)
summary(fit1)

# The most important part of this table:
# is the estimate attached to each variable
# So, that's 0.16292 for tenure
# and 3.43025 for collegegrad 

# This table is telling you "for a 1 unit increase
# in our variable, how much should we expect our wage
# to increase or decrease?" 

# For tenure (which let's say is measured in years)
# This table is saying, that for each year a person stays at their 
# job, on average, their average hourly wage goes up by rougly
# 16 cents. 

# For collgrade, this table is saying that 'for each 1 unit increase
# in collegegrad' a persons wage goes up, on average, by
# $3.43
# But wait! what does '1 unit increase' mean for a categorical
# variable??
# Simple! It just means that you get the 3.43$ increase if you graduated 
# college. You only graduate college or you don't. so you only get 
# the 3.43 if you do! (this is a binary variable 0 = didn't graduate, 1 = grad)


# Now all this is helpful for comparison! but what about if we want to estimate
# average hourly wage for a person given their tenure and graduate status?

# WAY SIMPLE

# That intercept estimate is going to represent the average hourly wage
# for someone with 0 years of tenure, and who did not graduate college. 

# So, the AHW for a person who is brand new to their job who didn't
# graduate college is about $6

# For someone with 5 years of tenure and who did graduate college,
# you need to do some simple math:


# baseline + tenure * years + a bump if they graduated
6.00365 + (0.16292 *5) + (3.43025 *1)

# For someone who didn't graduate but has 5 years of tenure:
6.00365 + (0.16292 *5) + (3.43025 *0)

# R can actually do this math for you with the predict() function

# two steps: first, create a dataframe with your info
example <- data.frame(tenure = 5,
                      collgrad = factor("college grad", 
                                        levels = c("not college grad",
                                                   "college grad")))

# second, place that data into the predict function and predict
# will calculate your prediction! 
predict(fit1, newdata=example)


# There is a lot more to know here! But this is a good start


#-----------------------------------------------------------
# Survey Weights
#-----------------------------------------------------------

# What are survey weights? 
# When you conduce a survey, you are trying to use a sample to 
# tell you something about a population. 

# You want that sample to match your population as much as possible

# For example, let's say we wanted to know what Americans think about
# Joe Biden. BUT we ended up getting a sample of only Americans
# who graduated college. We missed a key demographic: we now can't say
# anything about non-college grads because we don't know anything about them!

# That's a problem! So, most surveys adjust their sampling frame to 
# make sure to include key demographics

# Survey weights are a way to fine tune this even more!  
# Let's we got a sample that's 61% women and 37% men

# but we know from the census that America is 52% female and 47% male
# We can use survey weights to 'discount' some of the female respondents
# and at the same time "boost" some of the men, to more 
# accurately reflect what is true in the US. 

# if your survey weights are designed correctly, this should lead to a more 
# accurate final product.*** 


#-----------------------------------------------
# Statistics with the survey package
#-----------------------------------------------
library(survey)

# Read in the data
load("data.rda")

names(data)



#-----------------------------------------------
# Summary Statistics & Regression review
#-----------------------------------------------

# A frequency table of ACEs scores
table(data$acescore1)

# A frequency table of ACEs scores as a binary variable
table(data$bi_score)

# Percentage
prop.table(table(data$bi_score))*100

# Cool math fact: the mean of a dummy variable is the percentage of 1s
mean(data$bi_score)


#-----------------------------------------------
# Using the Survey Package to use Weights
#-----------------------------------------------

# Let's generate some stats

# To use the survey package, we need to set a design matrix. 
# we include an "id" which is just a unique variable for each row (like a serial number)
# the strata variable (if the survey is a stratified design, otherwise leave blank)
# and the individual level weight variable. 
# This information is usually found in the codebook. Sometimes the survey
# providers will even suggest a svydesign code for you!
svydesign.brfss <- svydesign(id= ~0, strata=~`_state`, weight=~`_finalwt`, data=data)

# By far the absolute most common design is to simply use a 
# weight column provided and not use strata 

# Now we'll need to use our design matrix to generate stats

svyciprop(~prihealthcare, design=hartweight)
svyby(~prihealthcare, by = ~female, design=hartweight, svyciprop, na.rm=TRUE)

#Mean ACE score
svymean(~acescore1, svydesign.brfss) 

#Estimated proportion of pop with score above 0
svyciprop(~bi_score, design=svydesign.brfss)

#compare to unweighted data
mean(data$bi_score)

#two or higher score
svyciprop(~doublescore, design=svydesign.brfss)



# Let's look into ACEs by demographics

# Race
# Average ACE score by race 
svyby(~acescore1, ~racelab, svydesign.brfss, svymean)



##Sex
#Proportion of women with 2 or more ACEs vs.
# proportion of men with 2 or more ACEs 
# 0 = male, 1 = female
svyby(~bi_score, ~sexd, svydesign.brfss, svyciprop)


# Education level
svyby(~bi_score, ~education, svydesign.brfss, svyciprop)


# options(scipen=99) will turn off sci notation


# Marital status
# married=1, 2=divorce, 3=wid, 4=sep, 5=never married, 6=unmarried couple
svyby(~bi_score, ~marriage, svydesign.brfss, svyciprop)



# Whew! That's a lot of information. Now let's try using regression
# to make some predictions

fit1 <-svyglm(acescore1 ~ marriage, svydesign.brfss)
summary(fit1)


#--------------------------------------------------------
# Stargazer
#--------------------------------------------------------
library(stargazer)

stargazer(fit1, type="html")
stargazer(fit1, type="text")

# you can add labels
stargazer(fit1, type="text", dep.var.labels = "ACE Score")

stargazer(fit1, type="text", 
          dep.var.labels = "ACE Score", 
          covariate.labels = c("Married", 
                               "Never Married", 
                               "Partnered", 
                               "Separated", 
                               "Widowed"))











#***: in theory.