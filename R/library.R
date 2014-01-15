# Required R libraries (need to be installed - it can take a few minutes the first time you run the project)

# installs all necessary libraries from CRAN
get_libraries <- function(filenames_list) { 
  lapply(filenames_list,function(thelibrary){    
    if (do.call(require,list(thelibrary)) == FALSE) 
      do.call(install.packages,list(thelibrary)) 
    do.call(library,list(thelibrary))
  })
}

libraries_used=c("devtools","knitr","graphics","reshape2","RJSONIO","grDevices","xtable","FactoMineR")
get_libraries(libraries_used)

if (require(slidifyLibraries) == FALSE) 
  install_github("slidifyLibraries", "ramnathv")
if (require(slidify) == FALSE) 
  install_github("slidify", "ramnathv") 
if (require(rCharts) == FALSE) 
  install_github('rCharts', 'ramnathv')


########################################################

sharpe <- function(x, exclude_zero = (x != 0))
  round( 16 * mean( drop( x[exclude_zero] ) ) / sd( drop( x[exclude_zero] ) ),digits = 1 )
bps <- function(x, exclude_zero = (x != 0))
  round(100*mean( drop( x[exclude_zero] ) ), digits = 1 )
gain_ratio <- function(x)
  round( sum( x > 0 )/sum( x != 0), digits = 2 )
drawdown <- function(x)
  round( max( cummax( cumsum( x ) ) - cumsum( x ) ), digits= 2 )

pnl_stats <- function(x){
  if (class(x) == "matrix")
    if (ncol(x) > 1)
      x <- x[,1]
  c( sum = round( sum( x ), digits = 2), bps = bps( x ), sharpe = sharpe( x ), dd = drawdown( x ), gain_ratio = gain_ratio( x ) )
}

pnl_plot <- function(x,...){
  ylab <- deparse( substitute( x ) )
  if (class(x) == "matrix")
    if (ncol(x) > 1)
      x <- x[,1, drop = FALSE]
  if (class(x) != "matrix") 
    x <- matrix(x, ncol = 1, dimnames = list(names( x ), NULL))
  assetname = ifelse (is.null(colnames( x )), "", paste(colnames( x ), ": ", sep=""))
  main <- paste(assetname, paste(names(pnl_stats( x )), pnl_stats( x ), sep=":", collapse=" "), sep=" ")
  plot(cumsum( x ), type = "l", ylab = "Percent Return", xlab = "Date", main = main, axes = FALSE,...)
  if (!is.null(rownames( x ))){
    axis(1, at = seq(1, nrow( x ), length.out = 5), labels = rownames( x )[seq(1,nrow( x ), length.out = 5)])
    axis(2)
  } else { 
    axis(1)
    axis(2)
  }
}


norm1 <- function(x)
  if (sum( abs( x ) ) > 0) {
    return( x / sum( abs( x ) ) ) 
  } else { 
    return( x )
  }

shift <- function(a, n = 1, filler = 0){
  x <- switch(class(a), matrix=a, matrix(a, ncol=1, dimnames = list(names( a ),NULL)))
  if( n == 0 )
    return( x )
  if( n > 0 ){
    rbind(matrix(filler, ncol=ncol( x ), nrow = n), head(x, -n)) 
  } else {
    rbind(tail( x, n ), matrix(filler, ncol = ncol( x ), nrow = abs( n )))
  }
}

non_zero_mean<-function(x,n)ifelse(sum(x!=0)<n,0,mean(x[x!=0]))

month_names<-c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")

datestring2year<-function(x)as.POSIXlt(x,format="%Y-%m-%d")$year+1900

datestring2month<-function(x)month_names[as.POSIXlt(x,format="%Y-%m-%d")$mon+1]

xlapply<-function(x,y,fun,...){
  i<-as.vector(row(matrix(0,nrow=length(x),ncol=length(y))))
  j<-as.vector(col(matrix(0,nrow=length(x),ncol=length(y))))
  matrix(simplify2array(mapply(function(a,b)fun(x[[a]],y[[b]],...),i,j)),nrow=length(x),ncol=length(y),dimnames=list(names(x),names(y)))
}

pnl_matrix<-function(perf, digits = 1, geometric = FALSE){
  if(geometric)
    f <- function(v) prod(1+v)-1
  else
    f <- function(v) sum(v)
  
  if(any(class(perf) %in% c("matrix"))) x<-apply(perf,1,non_zero_mean,1) else x<-perf
  years<-as.list(unique(datestring2year(names(x))))
  names(years)<-years
  names(month_names)<-month_names
  monthly_returns<-lapply(split(x,list(datestring2month(names(x)),datestring2year(names(x)))), f)
  res <- xlapply(years,month_names,function(y,m)monthly_returns[[paste(m,y,sep=".")]])
  round(cbind(res,Year = apply(res,1, f))*100, digits) 
}
