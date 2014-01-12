
source("R/library.R")
source("R/heatmapOutput.R")

ProjectData = ProjectData[start_date:end_date, stocks_used]

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

##########################

