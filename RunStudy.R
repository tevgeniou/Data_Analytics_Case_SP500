
# Project Name: "S&P500 Daily Stock Returns Analysis"

rm(list = ls()) # clean up the workspace

######################################################################

# SELECT THE PROJECT PARAMETERS NEEDED TO GENERATE THE REPORT

# When running the case on a local computer, modify this in case you saved the case in a different directory 
# (e.g. local_directory <- "C:/user/MyDocuments" )
# type in the Console below help(getwd) and help(setwd) for more information
local_directory <- getwd()

# Please ENTER the name of the file with the data used. The file should contain a matrix with one row per observation (e.g. person) and one column per attribute. THE NAME OF THIS MATRIX NEEDS TO BE ProjectData (otherwise you will need to replace the name of the ProjectData variable below with whatever your variable name is, which you can see in your Workspace window after you load your file)
datafile_name <- "DefaultData" # this is the default name of the data for a project

# this loads the selected data
load(paste("data", datafile_name, sep = "/")) # this contains only the matrix ProjectData

# Please ENTER the time period to use (default is 1 to nrow(ProjectData), namely all the days)
start_date <- 1
end_date <- nrow(ProjectData)

# Please ENTER the stocks to use (default is 1:ncol(ProjectData), namely all of them)
# Notice: this is not an input to the Web App. You may need to use a different data file
stocks_used <- 1:ncol(ProjectData)

# Please ENTER the number of principal components to eventually use for this report
numb_components_used <- 3

# Please ENTER 0 or 1 to de-mean or not the data in the regression estimation of the report (Default is 0)
use_mean_alpha <- 0

###########################
# Would you like to also start a web application on YOUR LOCAL COMPUTER once the report and slides are generated?
# Select start_webapp <- 1 ONLY if you run the case on your local computer
# NOTE: Running the web application on your LOCAL computer will open a new browser tab
# Otherwise, when running on a server the application will be automatically available
# through the ShinyApps directory

# 1: start application on LOCAL computer, 0: do not start it
# SELECT 0 if you are running the application on a server 
# (DEFAULT is 0). 
start_local_webapp <- 0

################################################
# Now run everything
source("R/library.R")
source("R/runcode.R")

if (start_local_webapp)
  runApp("tools")

