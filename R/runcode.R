

######################################################################
# generate the report, slides, and if needed start the web application

unlink( "TMPdirReport", recursive = TRUE )      
dir.create( "TMPdirReport" )
setwd( "TMPdirReport" )
file.copy( paste(local_directory,"doc/SP500_Report.Rmd", sep="/"),"SP500_Report.Rmd", overwrite = T )
knit2html( 'SP500_Report.Rmd', quiet = TRUE )
file.copy( 'SP500_Report.html', paste(local_directory,"doc/SP500_Report.html", sep="/"), overwrite = T )
setwd( "../" )
unlink( "TMPdirReport", recursive = TRUE )      



unlink( "TMPdirSlides", recursive = TRUE )      
dir.create( "TMPdirSlides" )
setwd( "TMPdirSlides" )
file.copy( paste(local_directory,"doc/SP500_Slides.Rmd", sep="/"),"SP500_Slides.Rmd", overwrite = T )
file.copy( paste(local_directory,"doc/All3.png", sep="/"),"All3.png", overwrite = T )
slidify( "SP500_Slides.Rmd" )
file.copy( 'SP500_Slides.html', paste(local_directory,"doc/SP500_Slides.html", sep="/"), overwrite = T )
setwd( "../" )
unlink( "TMPdirSlides", recursive = TRUE )      


