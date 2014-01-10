
# Project Name: "S&P500 Daily Stock Returns Analysis"

rm(list = ls()) # clean up the workspace

######################################################################

# THESE ARE THE PROJECT PARAMETERS NEEDED TO GENERATE THE REPORT

# Please ENTER the name of the file with the data used. The file should contain a matrix with one row per observation (e.g. person) and one column per attribute. THE NAME OF THIS MATRIX NEEDS TO BE ProjectData (otherwise you will need to replace the name of the ProjectData variable below with whatever your variable name is, which you can see in your Workspace window after you load your file)
datafile_name <- "DefaultData" # this is the default name of the data for a project
###########
# DEFAULT PROJECT DATA FORMAT: File datafile_name must have a matrix called ProjectData of 
# D rows and S columns, where D is the number of days and S the number of stocks
###########

# this loads the selected data
load(paste("data", datafile_name, sep = "/")) # this contains only the matrix ProjectData
cat("\nVariables Loaded:", ls(), "\n")

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

# Would you like to also start a web application once the report and slides are generated?
# 1: start application, 0: do not start it. 
# Note: starting the web application will open a new browser 
# with the application running
start_webapp <- 1


######################################################################
# Define the data used in the slides and report, and run all necessary libraries 

ProjectData = ProjectData[start_date:end_date, stocks_used]

source("R/library.R")
source("R/heatmapOutput.R")

######################################################################
# generate the report, slides, and if needed start the web application

unlink( "TMPdirSlides", recursive = TRUE )      
dir.create( "TMPdirSlides" )
setwd( "TMPdirSlides" )
file.copy( "../doc/SP500_Slides.Rmd","SP500_Slides.Rmd", overwrite = T )
slidify( "SP500_Slides.Rmd" )
file.copy( 'SP500_Slides.html', "../doc/SP500_Slides.html", overwrite = T )
setwd( "../" )
unlink( "TMPdirSlides", recursive = TRUE )      

unlink( "TMPdirReport", recursive = TRUE )      
dir.create( "TMPdirReport" )
setwd( "TMPdirReport" )
file.copy( "../doc/SP500_Report.Rmd","SP500_Report.Rmd", overwrite = T )
knit2html( 'SP500_Report.Rmd', quiet = TRUE )
file.copy( 'SP500_Report.html', "../doc/SP500_Report.html", overwrite = T )
setwd( "../" )
unlink( "TMPdirReport", recursive = TRUE )      

if (start_webapp){
  # load all files in the data directory to have them available locally
  load("data/FinancialsData")
  FinancialsData <- ProjectData
  load("data/TechData")
  TechData <- ProjectData
  load("data/DefaultData")
  MarketData <- ProjectData
  
  runApp("tools")
}
  